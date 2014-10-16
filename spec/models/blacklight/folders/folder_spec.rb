require 'rails_helper'

describe Blacklight::Folders::Folder do
  let(:user) { User.create }

  it 'belongs to a user' do
    subject.user = user
    expect(subject.user).to eq user
  end

end
