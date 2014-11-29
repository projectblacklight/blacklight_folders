// This is for the catalog show page
BlacklightFolders.FolderEditController = function(elem) {
  this.$form = $('form.folder-actions', elem);
  this.$select = $('select', this.$form);

  var addAutocomplete = this.addAutocomplete;
  $.each(this.$select, function(_, select){
    addAutocomplete(select);
  });
}

BlacklightFolders.FolderEditController.prototype = {
  addAutocomplete: function(select) {
    select = $(select);

    // Remove the bootstrap class so that select2 can apply its own styles
    select.removeClass('form-control');

    // The first element has a prompt. We remove it from the list.
    var element = $('option:first-child', select);
    var label = element.text();
    element.empty();

    select.select2({placeholder: label});
  }
}

Blacklight.onLoad(function() { new BlacklightFolders.FolderEditController($('.blacklight-folders-edit')) });
