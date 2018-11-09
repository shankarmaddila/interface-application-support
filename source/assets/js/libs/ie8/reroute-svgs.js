$(document).ready(function() {
  var $useEL = $('body').find('svg img');
  $.each($useEL, function(i, el) {
    var currentName = $(el).attr('src');
    $(el).attr('src', '/assets/img/svgs/png/'+currentName);
    console.log($(el).attr('src'));
  });
});
