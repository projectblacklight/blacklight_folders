// This is for the catalog show page
BlacklightFolders.CatalogShowController = function(elem) {
  if (elem.length == 0) {
    return null;
  }

  this.$element = elem
  this.$form = $('.show-tools .folder form', elem);
  this.$select = $('select', this.$form);

  this.addAutocomplete();
}

BlacklightFolders.CatalogShowController.prototype = {
  addAutocomplete: function() {
    // Remove the bootstrap class so that select2 can apply its own styles
    this.$select.removeClass('form-control');
    // The first element has a prompt. We remove it from the list.
    var element = $('option:first-child', this.$select);
    var label = element.text();
    element.empty();
    this.$select.select2({placeholder: label});
  }
}

Blacklight.onLoad(function() { new BlacklightFolders.CatalogShowController($('.blacklight-catalog-show')) });

