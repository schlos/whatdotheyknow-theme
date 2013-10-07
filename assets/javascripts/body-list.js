$(document).ready(function() {
  var $heading = $('select#public_body_heading');
  var $tag = $('select#tag');
  $heading.change(function() {
    $tag.empty().append(function() {
      var output = '<option value="all">All subcategories</option>';
      var tagValues = tagsByHeading[$heading.val()];
      if (tagValues != undefined) {
        $.each(tagValues, function(key, value) {
          output += '<option value ="'+ value[0] + '">' + value[1] + '</option>';
        });
        return output;
      }
    });
  })
});
