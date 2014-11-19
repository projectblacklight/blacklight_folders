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
end
