require 'rails_helper'

describe Blacklight::Folders::FoldersController do
  routes { Blacklight::Folders::Engine.routes }

  let(:user) { FactoryGirl.create(:user) }
  let(:my_private_folder) { FactoryGirl.create(:private_folder, user: user) }
  let(:my_public_folder)  { FactoryGirl.create(:public_folder, user: user) }


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
  end  # not logged in


  describe 'user is logged in' do
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
      it 'displays the folder' do
        get :show, id: my_private_folder.id
        expect(response).to be_successful
        expect(response).to render_template(:show)
        expect(assigns(:folder)).to eq my_private_folder
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
    end

    describe '#update with bad inputs' do
      it 'renders the form' do
        my_private_folder
        invalid_name = nil
        patch :update, id: my_private_folder.id, folder: { name: invalid_name }
        expect(assigns(:folder)).to eq my_private_folder
        expect(response).to render_template(:edit)
      end
    end
  end  # user is logged in

end
