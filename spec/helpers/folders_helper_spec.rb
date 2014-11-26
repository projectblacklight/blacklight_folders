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

  describe 'folders_selection_for_doc' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:doc) { SolrDocument.new(id: '123') }

    let!(:folder_a) { FactoryGirl.create(:folder, name: 'A folder', user: user) }
    let!(:folder_b) { FactoryGirl.create(:folder, name: 'B folder', user: user) }
    let!(:folder_c) { FactoryGirl.create(:folder, name: 'C folder', user: user) }

    it 'sorts folders alphabetically, except adds default folder to the front of the list' do
      folders = helper.folders_selection_for_doc(doc, user)
      expect(folders).to eq [user.default_folder, folder_a, folder_b, folder_c]
    end
  end
end
