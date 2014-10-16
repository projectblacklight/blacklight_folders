require 'rails_helper'

describe Blacklight::Folder do

  it 'belongs to a user' do
    subject.user = User.create
  end

end
