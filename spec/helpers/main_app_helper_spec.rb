require 'rails_helper'

describe Blacklight::Folders::MainAppHelper do
  describe "#options_for_folder_select" do
    before do
      allow(helper).to receive(:current_or_guest_user).and_return(user)
      allow(helper).to receive(:current_ability).and_return(Ability.new(user))
    end

    context "when a user is signed in" do
      let(:user) { create(:user) }
      let!(:beta) { create(:folder, user: user, name: 'Beta') }
      let!(:alpha) { create(:folder, user: user, name: 'Alpha') }
      let!(:sigma) { create(:folder, name: "Someone else's folder") }

      context "including everything" do
        subject { helper.options_for_folder_select }
        it { is_expected.to eq "<option value=\"1\">Default folder</option>\n" +
                               "<option value=\"3\">Alpha</option>\n" +
                               "<option value=\"2\">Beta</option>" }
      end

      context "with exclusions" do
        let(:item) { create(:folder_item, folder: alpha) }
        let(:solr_doc) { double("SolrDocument", id: item.bookmark.document_id) }
        subject { helper.options_for_folder_select(without: solr_doc) }
        it { is_expected.to eq "<option value=\"1\">Default folder</option>\n" +
                               "<option value=\"2\">Beta</option>" }
      end
    end
  end

  describe "#truncated_options_for_select" do
    let(:alpha) { build(:folder, name: 'Alpha is good', id: 1) }
    let(:beta) { build(:folder, name: 'Beta is so long', id: 2) }
    subject { helper.truncated_options_for_select([alpha, beta], :name, :id, length: 9, separator: ' ') }
    it { is_expected.to eq "<option value=\"1\">Alpha...</option>\n" +
                             "<option value=\"2\">Beta...</option>" }
  end
end
