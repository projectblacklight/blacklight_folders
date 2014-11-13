/*
 * Sort the list of folders when the dropdown is changed
 *
 */

Blacklight.onLoad(function() {
  $('#order_by').change(function() {
    $(this).closest('form').submit();
  });
});
