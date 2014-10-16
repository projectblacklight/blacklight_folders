require 'rails_helper'

describe Blacklight::Folders::Folder do

  it 'belongs to a user' do
    subject.user = User.create
  end

end
