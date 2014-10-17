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

  end  # user is logged in

end
