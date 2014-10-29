require 'rails_helper'

describe Blacklight::Folders::FolderItemsController do
  routes { Blacklight::Folders::Engine.routes }

  let(:user) { FactoryGirl.create(:user) }
  let(:my_folder) { FactoryGirl.create(:folder, user: user) }
  let(:doc_id) { 'id:123' }


  describe 'not logged in' do
    describe '#create' do
      it 'denies access' do
        post :create, folder_item: { folder_id: my_folder.id,
                                     document_id: doc_id }
        expect(response).to redirect_to(main_app.user_session_path)
      end
    end
  end  # not logged in


  describe 'user is logged in' do
    before do
      sign_in user
      @request.env['HTTP_REFERER'] = 'http://test.com'
    end

    describe '#create' do
      it 'adds the item to the folder' do
        post :create, folder_item: { folder_id: my_folder.id,
                                     document_id: doc_id }
        expect(response).to redirect_to :back
        expect(assigns(:folder_item)).to_not be_nil
        expect(my_folder.items.count).to eq 1
        expect(my_folder.items.first.document_id).to eq doc_id
      end
    end

    describe '#create with bad inputs' do
      before do
        allow_any_instance_of(Blacklight::Folders::FolderItem).to receive(:save).and_return(false)
      end

      it 'renders the form' do
        expect {
          post :create, folder_item: { folder_id: my_folder.id,
                                       document_id: doc_id }
        }.to change{ Blacklight::Folders::FolderItem.count }.by(0)
        expect(assigns(:folder_item)).to_not be_nil
        expect(response).to render_template(:new)
      end
    end
  end  # user is logged in
end
