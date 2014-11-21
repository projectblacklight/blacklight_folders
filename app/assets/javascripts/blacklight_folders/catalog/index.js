// This is for the catalog index page
BlacklightFolders.CatalogIndexController = function(elem) {
  if (elem.length == 0) {
    return null;
  }

  this.$element = elem
  this.$checkboxes = $('input[type=checkbox][name="folder_ids[]"]', elem);
  this.$form = $('form[data-behavior=move-to-folder]', elem);
  this.$select = $('select', this.$form);
  this.$hidden = $('input[name="document_ids"]', this.$form);

  this.addControls();
  this.addAutocomplete();
  this.attachEvents();
}

BlacklightFolders.CatalogIndexController.prototype = {
  addControls: function() {
    this.$checkboxes.show();
  },

  addAutocomplete: function() {
    // Remove the bootstrap class so that select2 can apply its own styles
    this.$select.removeClass('form-control');
    // The first element has a prompt. We remove it from the list.
    var element = $('option:first-child', this.$select);
    var label = element.text();
    element.empty();
    this.$select.select2({placeholder: label});
  },


  showForm: function() {
    this.$form.show();
  },

  hideForm: function() {
    this.$form.hide();
  },

  showOrHideForm: function () {
    if (this.$checkboxes.is(":checked")) {
      this.showForm();
    } else {
      this.hideForm();
    }
  },

  submit: function(event) {
    var folder_id = $(event.currentTarget).val();
    var vals = $.map(this.$checkboxes.filter(':checked'), function(e) { return $(e).val(); })
    this.$hidden.val(vals.join());
    this.$form.submit();
  },

  attachEvents: function() {
    that = this;
    this.$checkboxes.on('change', function() { that.showOrHideForm(); });
    this.$select.on('change', function(event) { that.submit(event); });
  }

}

Blacklight.onLoad(function() { new BlacklightFolders.CatalogIndexController($('.blacklight-catalog-index')) });
