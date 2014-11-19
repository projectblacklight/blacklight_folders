require 'rails_helper'

describe User do
  context "when a user is created" do
    let(:user) { create(:user) }
    subject { user.folders }
    it "should create a new default folder" do
      expect(subject.map(&:name)).to eq ['Default folder']
    end
  end
end
