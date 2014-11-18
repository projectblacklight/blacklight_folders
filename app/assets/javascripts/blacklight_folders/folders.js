var FolderController = function(elem) {
  if (elem.length == 0) {
    return null;
  }

  this.$element = elem
  this.$checkboxes = $('input[type=checkbox][name="folder_ids[]"]', elem);
  this.$form = $('form[data-behavior=move-to-folder]', elem);
  this.$select = $('select', this.$form);
  this.$hidden = $('input[name="document_ids"]', this.$form);

  this.addControls(elem);
  this.attachEvents();
}

FolderController.prototype = {
  addControls: function(elem) {
    this.$checkboxes.show();
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

Blacklight.onLoad(function() { new FolderController($('.blacklight-catalog-index')) });
