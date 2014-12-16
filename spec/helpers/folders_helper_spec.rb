require 'rails_helper'

describe Blacklight::Folders::FoldersHelper do
  describe "human_friendly_visibility" do
    subject { helper.human_friendly_visibility(visibility) }
    context "for public" do
      let(:visibility) { 'public' }
      it { is_expected.to eq "<span class=\"glyphicon glyphicon-unlock\"></span> Anyone" }
      it { is_expected.to be_html_safe }
    end

    context "for private" do
      let(:visibility) { 'private' }
      it { is_expected.to eq "<span class=\"glyphicon glyphicon-lock\"></span> Only me" }
      it { is_expected.to be_html_safe }
    end
  end

  describe "#folder_export_url" do
    let(:folder) { build(:folder, id: '999') }
    let(:user) { build(:user, id: '77') }

    before do
      allow(folder).to receive(:persisted?).and_return(true)
      controller.singleton_class.include Blacklight::TokenBasedUser
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:encrypt_user_id).with(user.id).and_return('ABCD')
    end
    subject { helper.folder_export_url(folder, :refworks_marc_txt) }
    it { is_expected.to eq "http://test.host/blacklight/folders/999.refworks_marc_txt?encrypted_user_id=ABCD" }
  end
end
