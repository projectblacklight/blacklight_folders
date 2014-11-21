module Blacklight::Folders
  module CrudLinksHelper
    def action_label model, action=nil
      action_default_value model, action
    end

    private
    def action_default_value object, key = nil
      object_model = convert_to_model(object)

      key ||= object_model ? (object_model.persisted? ? :edit : :create) : :view

      case object_model
      when Symbol, String
        model = object_model
        object_name = object_model
      else
        model = object_model.class.model_name.human
        object_name = object_model.class.model_name.i18n_key
      end

      defaults = []
      defaults << :"helpers.action.#{object_name}.#{key}"
      defaults << :"helpers.action.#{key}"
      defaults << "#{key.to_s.humanize} #{model}"
      I18n.t(defaults.shift, model: model, default: defaults)
    end
  end
end
