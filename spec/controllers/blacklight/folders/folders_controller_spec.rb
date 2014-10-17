require 'rails_helper'

describe Blacklight::Folders::FoldersController do
  routes { Blacklight::Folders::Engine.routes }

  let(:user) { FactoryGirl.create(:user) }
  let(:my_folder) { FactoryGirl.create(:folder, user: user) }


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
        get :show, id: my_folder.id
        expect(response).to be_successful
        expect(response).to render_template(:show)
        expect(assigns(:folder)).to eq my_folder
      end
    end

    describe '#edit' do
      it 'displays the form' do
        get :edit, id: my_folder.id
        expect(response).to be_successful
        expect(response).to render_template(:edit)
        expect(assigns(:folder)).to eq my_folder
      end
    end

    describe '#destroy' do
      it 'destroys the folder' do
        my_folder
        expect {
          delete :destroy, id: my_folder.id
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
        my_folder
        new_name = 'New Name'
        patch :update, id: my_folder.id, folder: { name: new_name }
        expect(assigns(:folder)).to eq my_folder
        expect(response).to redirect_to folder_path(my_folder)
        expect(my_folder.reload.name).to eq new_name
      end
    end

    describe '#update with bad inputs' do
      it 'renders the form' do
        my_folder
        invalid_name = nil
        patch :update, id: my_folder.id, folder: { name: invalid_name }
        expect(assigns(:folder)).to eq my_folder
        expect(response).to render_template(:edit)
      end
    end

  end  # user is logged in

end
