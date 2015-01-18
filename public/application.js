$(document).ready(function(){
  $(document).on('click', '#hit_horm', function(){
    $.ajax({
      type: 'POST',
      url: '/hit'
    }).done(function(message){
      $('#game').replaceWith(message);
    });
    return false;
  });
});