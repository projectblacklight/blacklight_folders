require 'rails_helper'

describe User do
  let(:user) { create(:user) }

  context "when a user is created" do
    subject { user.folders }
    it "should create a new default folder" do
      expect(subject.map(&:name)).to eq ['Default folder']
    end
  end

  it 'finds the default folder' do
    expect(user.folders.count).to eq 1
    expect(user.default_folder).to eq user.folders.first
  end
end
