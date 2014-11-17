require 'rails_helper'

describe Blacklight::Folders::CrudLinksHelper do
  describe "#action_label" do
    it "should return the label for an action on a model" do
      some_model = double
      expect(helper).to receive(:action_default_value).with(some_model, :action).and_return "xyz"
      expect(helper.action_label(some_model, :action)).to eq "xyz"
    end
  end

  describe "#action_default_value" do
    let(:some_model) { Blacklight::Folders::Folder.new }

    context "when the model is persisted" do
      before do
        allow(some_model).to receive(:persisted?).and_return(true)
      end

      it "should attempt i18n lookups for models" do
        expect(I18n).to receive(:t).with(:'helpers.action.blacklight/folders/folder.edit', model: some_model.class.model_name.human, default: [:'helpers.action.edit', 'Edit Folder'])
        expect(helper.send(:action_default_value, some_model))
      end
    end

    context "when the model is unpersisted" do
      it "should attempt i18n lookups for models" do
        expect(I18n).to receive(:t).with(:'helpers.action.blacklight/folders/folder.create', model: some_model.class.model_name.human, default: [:'helpers.action.create', 'Create Folder'])
        expect(helper.send(:action_default_value, some_model))
      end
    end

    it "should attempt i18n lookups for models with an explicit action" do
      expect(I18n).to receive(:t).with(:'helpers.action.blacklight/folders/folder.custom_action', model: some_model.class.model_name.human, default: [:'helpers.action.custom_action', 'Custom action Folder'])
      expect(helper.send(:action_default_value, some_model, :custom_action))
    end

    it "should attempt i18n lookups for symbols" do
      expect(I18n).to receive(:t).with(:'helpers.action.my_thing.custom_action', model: :my_thing, default: [:'helpers.action.custom_action', 'Custom action my_thing'])
      expect(helper.send(:action_default_value, :my_thing, :custom_action))

    end
  end
end
