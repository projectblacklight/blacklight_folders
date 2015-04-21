require 'rails_helper'

describe Blacklight::Folders::FoldersController do
  routes { Blacklight::Folders::Engine.routes }

  let(:user) { create(:user) }
  let(:my_private_folder) { create(:private_folder, user: user) }
  let(:my_public_folder)  { create(:public_folder, user: user, name: "My First Folder") }


  describe 'not logged in' do
    describe '#new' do
      it 'denies access' do
        get :new
        expect(response).to redirect_to(main_app.user_session_path)
      end
    end

    describe '#show' do
      it 'displays public folders' do
        get :show, id: my_public_folder.id
        expect(response).to be_successful
        expect(response).to render_template(:show)
        expect(assigns(:folder)).to eq my_public_folder
      end

      it 'denies access to private folders' do
        get :show, id: my_private_folder.id
        expect(response).to redirect_to(main_app.user_session_path)
      end

      it 'redirects to home page for invalid folder id' do
        get :show, id: 100000000000
        expect(response).to redirect_to(main_app.root_path)
      end
    end

    describe '#edit' do
      it 'denies access' do
        get :edit, id: my_public_folder.id
        expect(response).to redirect_to(main_app.user_session_path)
      end
    end

    describe '#destroy' do
      it 'denies access' do
        delete :destroy, id: my_public_folder.id
        expect(response).to redirect_to(main_app.user_session_path)
      end
    end

    describe '#create' do
      it 'denies access' do
        post :create, folder: { name: 'My Folder' }
        expect(response).to redirect_to(main_app.user_session_path)
      end
    end

    describe '#update' do
      it 'denies access' do
        patch :update, id: my_public_folder.id, folder: { name: 'hello' }
        expect(response).to redirect_to(main_app.user_session_path)
      end
    end

    describe '#index' do
      it 'shows just the default (unsaved) folder' do
        get :index
        expect(response).to be_successful
        expect(assigns(:folders).size).to eq 1
        expect(assigns(:folders).first).to be_kind_of Blacklight::Folders::Folder
        expect(assigns(:folders).first).not_to be_persisted
        expect(response).to render_template(:index)
      end

      context "when the user is a persisted guest with a persisted folder" do
        let(:current_user) { create(:guest_user) }
        let!(:folder) { current_user.folders.create(name: 'Default') }
        before do
          sign_in current_user
        end

        it "should show the persisted folder" do
          get :index
          expect(response).to be_successful
          expect(assigns(:folders)).to eq [folder]
        end
      end
    end

    describe '#add_bookmarks' do
      context "to someone elses folder" do
        it 'denies access' do
          patch :add_bookmarks, folder: { id: my_public_folder.id }, document_ids: '123'
          expect(response).to redirect_to(main_app.user_session_path)
        end
      end

      context "to a default folder" do
        it 'adds bookmarks to the folder and persists the user' do
          @request.env['HTTP_REFERER'] = 'http://test.com'
          # the '0' folder is the default folder
          patch :add_bookmarks, folder: { id: 0 }, document_ids: '123, 456'

          expect(response).to redirect_to :back
          expect(assigns(:folder).user).to be_persisted
          expect(assigns(:folder).user).to be_guest
          expect(flash[:notice]).to eq "Added documents to Default folder"
          expect(assigns(:folder).bookmarks.map(&:document_id)).to match_array ['123', '456']
        end
      end
    end

    describe '#remove_bookmarks' do
      it 'denies access' do
        patch :remove_bookmarks, folder: { id: my_public_folder.id }, item_ids: '123'
        expect(response).to redirect_to(main_app.user_session_path)
      end
    end
  end  # not logged in

  describe "when the user is identified by a token" do
    context "exporting refworks" do
      render_views
      let(:document1) { SolrDocument.new(id: 'doc1', marc_display: ['First title']) }
      let(:document2) { SolrDocument.new(id: 'doc2', marc_display: ['Second title']) }
      let(:mock_response) { Blacklight::Folders::SolrResponse.new(nil, nil) }
      before do
        allow(mock_response).to receive(:documents).and_return([document1, document2])
        allow_any_instance_of(Blacklight::Folders::Folder).to receive(:response).and_return(mock_response)
        allow(document1).to receive(:export_as_refworks_marc_txt).and_return('one')
        allow(document2).to receive(:export_as_refworks_marc_txt).and_return('two')
        expect(controller).to receive(:decrypt_user_id).with('ABCD').and_return(user.id)
      end

      it 'displays the folder' do
        get :show, id: my_private_folder.id, format: :refworks_marc_txt, encrypted_user_id: 'ABCD'
        expect(response).to be_successful
        expect(response.body).to eq "one\ntwo"
      end
    end
  end

  describe 'when the user is logged in' do
    before { sign_in user }

    describe '#new' do
      it 'displays the form' do
        get :new
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(assigns(:folder)).to be_a_new(Blacklight::Folders::Folder)
      end
    end

    describe '#show' do
      context "as html" do
        it 'displays the folder' do
          get :show, id: my_private_folder.id
          expect(response).to be_successful
          expect(response).to render_template(:show)
          expect(assigns(:folder)).to eq my_private_folder
        end
      end

      context "exporting formats from blacklight-marc" do
        render_views
        let(:document1) { SolrDocument.new(id: 'doc1', marc_display: ['First title']) }
        let(:document2) { SolrDocument.new(id: 'doc2', marc_display: ['Second title']) }
        let(:mock_response) { Blacklight::Folders::SolrResponse.new(nil, nil) }
        before do
          allow(mock_response).to receive(:documents).and_return([document1, document2])
          allow_any_instance_of(Blacklight::Folders::Folder).to receive(:response).and_return(mock_response)
        end

        context "as endnote" do
          before do
            allow(document1).to receive(:export_as_endnote).and_return('one')
            allow(document2).to receive(:export_as_endnote).and_return('two')
          end

          it 'displays the folder' do
            mock_response.order = ['doc1', 'doc2']
            get :show, id: my_private_folder.id, format: :endnote
            expect(response).to be_successful
            expect(response.body).to eq "one\ntwo\n\n"
          end
        end

        context "as refworks" do
          before do
            allow(document1).to receive(:export_as_refworks_marc_txt).and_return('one')
            allow(document2).to receive(:export_as_refworks_marc_txt).and_return('two')
          end

          it 'displays the folder' do
            get :show, id: my_private_folder.id, format: :refworks_marc_txt
            expect(response).to be_successful
            expect(response.body).to eq "one\ntwo"
          end
        end
      end
    end

    describe '#edit' do
      it 'displays the form' do
        get :edit, id: my_private_folder.id
        expect(response).to be_successful
        expect(response).to render_template(:edit)
        expect(assigns(:folder)).to eq my_private_folder
      end
    end

    describe '#destroy' do
      it 'destroys the folder' do
        my_private_folder
        expect {
          delete :destroy, id: my_private_folder.id
        }.to change{ Blacklight::Folders::Folder.count }.by(-1)
        expect(response).to redirect_to main_app.root_path
      end
    end

    describe '#create' do
      it 'creates a folder with current user as owner' do
        expect {
          post :create, folder: { name: 'My Folder' }
        }.to change{ Blacklight::Folders::Folder.count }.by(1)
        expect(assigns(:folder)).to_not be_nil
        expect(assigns(:folder).user).to eq user
        expect(response).to redirect_to folder_path(assigns(:folder))
      end
    end

    describe '#create with bad inputs' do
      it 'renders the form' do
        invalid_name = nil
        expect {
          post :create, folder: { name: invalid_name }
        }.to change{ Blacklight::Folders::Folder.count }.by(0)
        expect(assigns(:folder)).to_not be_nil
        expect(response).to render_template(:new)
      end
    end

    describe '#update' do
      it 'updates the folder' do
        my_private_folder
        new_name = 'New Name'
        patch :update, id: my_private_folder.id, folder: { name: new_name }
        expect(assigns(:folder)).to eq my_private_folder
        expect(response).to redirect_to folder_path(my_private_folder)
        expect(my_private_folder.reload.name).to eq new_name
      end

      context "when the folder has items" do
        context "in order" do
          let!(:folder_item1) { create(:folder_item, position: '1', folder: my_private_folder) }
          let!(:folder_item2) { create(:folder_item, position: '2', folder: my_private_folder) }
          let!(:folder_item3) { create(:folder_item, position: '3', folder: my_private_folder) }
          let!(:folder_item4) { create(:folder_item, position: '4', folder: my_private_folder) }

          it 'updates the folder items' do
            patch :update, id: my_private_folder.id,
              folder: { items_attributes:
                [
                  { id: folder_item1, position: '3' },
                  { id: folder_item2, position: '1' },
                  { id: folder_item3, position: '2' },
                  { id: folder_item4, position: '4', _destroy: 'true' }
                ]
              }

            expect(my_private_folder.item_ids).to eq [folder_item2.id, folder_item3.id, folder_item1.id]
          end
        end

        context "with gaps" do
          let!(:folder_item1) { create(:folder_item, position: '1', folder: my_private_folder) }
          let!(:folder_item2) { create(:folder_item, position: '2', folder: my_private_folder) }

          it 'renumbers the folder items and sorts by integer (not string)' do
            patch :update, id: my_private_folder.id,
              folder: { items_attributes:
                [
                  { id: folder_item1, position: '30' },
                  { id: folder_item2, position: '200' }
                ]
              }

            expect(my_private_folder.items.pluck(:position)).to eq [1, 2]
            expect(my_private_folder.item_ids).to eq [folder_item1.id, folder_item2.id]
          end
        end

        context "with non-integers" do
          let!(:folder_item1) { create(:folder_item, position: '1', folder: my_private_folder) }
          let!(:folder_item2) { create(:folder_item, position: '2', folder: my_private_folder) }

          it 'renumbers the folder items and sorts by integer (not string)' do
            patch :update, id: my_private_folder.id,
              folder: { items_attributes:
                [
                  { id: folder_item1, position: '7' },
                  { id: folder_item2, position: 'first' }
                ]
              }

            expect(my_private_folder.items.pluck(:position)).to eq [1, 2]
            expect(my_private_folder.item_ids).to eq [folder_item2.id, folder_item1.id]
          end
        end

        describe "moving the item to another folder" do
          let!(:folder_item1) { create(:folder_item, position: '1', folder: my_private_folder) }
          let!(:folder_item2) { create(:folder_item, position: '2', folder: my_private_folder) }
          let!(:folder_item3) { create(:folder_item, position: '1', folder: my_public_folder) }
          let!(:folder_item4) { create(:folder_item, position: '2', folder: my_public_folder) }

          it 'puts the moved item at the end of the destination list' do
            patch :update, id: my_private_folder.id,
              folder: { items_attributes:
                [
                  { id: folder_item1, position: '1', folder_id: ''},
                  { id: folder_item2, position: '2', folder_id: my_public_folder.id }
                ]
              }

            expect(my_private_folder.reload.item_ids).to eq [folder_item1.id]
            expect(my_public_folder.item_ids).to eq [folder_item3.id, folder_item4.id, folder_item2.id]
          end
        end

        describe "change order with position collisions" do
          let!(:folder_item1) { create(:folder_item, position: '1', folder: my_public_folder) }
          let!(:folder_item2) { create(:folder_item, position: '2', folder: my_public_folder) }
          let!(:folder_item3) { create(:folder_item, position: '3', folder: my_public_folder) }
          let!(:folder_item4) { create(:folder_item, position: '4', folder: my_public_folder) }
          let!(:folder_item5) { create(:folder_item, position: '5', folder: my_public_folder) }

          it "gives priority to items that were changed but keeps the order of unchanged items" do
            patch :update, id: my_public_folder.id,
              folder: { items_attributes:
                [
                  { id: folder_item1, position: '1', folder_id: my_public_folder.id },
                  { id: folder_item2, position: '2', folder_id: my_public_folder.id },
                  { id: folder_item3, position: '2', folder_id: my_public_folder.id },
                  { id: folder_item4, position: '1', folder_id: my_public_folder.id },
                  { id: folder_item5, position: '3', folder_id: my_public_folder.id }
                ]
              }

            expect(my_public_folder.reload.item_ids).to eq [
              folder_item4.id,
              folder_item3.id,
              folder_item5.id,
              folder_item1.id,
              folder_item2.id
            ]
          end
        end
      end

      context 'with bad inputs' do
        it 'renders the form' do
          my_private_folder
          invalid_name = nil
          patch :update, id: my_private_folder.id, folder: { name: invalid_name }
          expect(assigns(:folder)).to eq my_private_folder
          expect(response).to render_template(:edit)
        end
      end
    end

    describe '#index' do
      let!(:my_default_folder) { user.folders.first }
      before do
        my_private_folder
        my_public_folder
      end

      it 'displays the folders' do
        get :index

        expect(assigns(:folders)).to eq [my_default_folder, my_private_folder, my_public_folder]
        expect(response).to render_template(:index)
        expect(response).to be_successful
      end

      context "with sorting" do
        let!(:aaa_folder)  { create(:public_folder, user: user, name: 'AAA') }
        let!(:bbb_folder)  { create(:public_folder, user: user, name: 'BBB') }

        it 'displays the folders in order' do
          get :index, order_by: 'name'

          expect(assigns(:folders)).to eq [aaa_folder, bbb_folder, my_default_folder,  my_private_folder, my_public_folder]
          expect(response).to render_template(:index)
          expect(response).to be_successful
        end

        it 'displays the folders in descending date order' do
          get :index, order_by: 'created_at'

          expect(assigns(:folders)).to eq [aaa_folder, bbb_folder, my_default_folder,  my_private_folder, my_public_folder].sort_by(&:created_at).reverse
          expect(response).to render_template(:index)
          expect(response).to be_successful
        end
      end
    end

    describe '#add_bookmarks' do
      context "when it's successful" do
        it 'adds bookmarks to the folder' do
          @request.env['HTTP_REFERER'] = 'http://test.com'
          patch :add_bookmarks, folder: { id: my_public_folder.id }, document_ids: '123, 456'

          expect(response).to redirect_to :back
          expect(assigns(:folder)).to eq my_public_folder
          expect(flash[:notice]).to eq "Added documents to My First Folder"
          expect(my_public_folder.bookmarks.count).to eq 2
          expect(my_public_folder.bookmarks.map(&:document_id).sort).to eq ['123', '456'].sort
        end
      end

      context 'failure path' do
        before do
          allow_any_instance_of(Blacklight::Folders::Folder).to receive(:save) { false }
          @request.env['HTTP_REFERER'] = 'http://test.com'
        end

        it 'prints an error' do
          patch :add_bookmarks, folder: { id: my_public_folder.id }, document_ids: '123, 456'
          expect(response).to redirect_to :back
          expect(flash[:alert]).to eq 'Unable to save bookmarks.'
        end
      end
    end


    describe '#remove_bookmarks' do
      before do
        my_public_folder.bookmarks.build({document_id: '123', document_type: 'SolrDocument', user_id: my_public_folder.user_id })
        my_public_folder.save!
        @item = my_public_folder.items.first
        @request.env['HTTP_REFERER'] = 'http://test.com'
      end

      it 'removes the bookmarks' do
        expect(my_public_folder.bookmarks.count).to eq 1
        patch :remove_bookmarks, folder: { id: my_public_folder.id }, item_ids: @item.id
        my_public_folder.reload
        expect(response).to redirect_to :back
        expect(assigns(:folder)).to eq my_public_folder
        expect(my_public_folder.bookmarks.count).to eq 0
      end

      it "doesn't let you delete someone else's bookmark" do
        not_my_item = create(:folder_item)
        count = Blacklight::Folders::FolderItem.count
        patch :remove_bookmarks, folder: { id: my_public_folder.id }, item_ids: not_my_item.id
        expect(Blacklight::Folders::FolderItem.count).to eq count
      end
    end
  end  # user is logged in

end
