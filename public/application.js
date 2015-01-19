$(document).ready(function(){
  $(document).on('click', '#hit_form', function(){
    $.ajax({
      type: 'POST',
      url: '/hit'
    }).done(function(message){
      //alert("hit ajax trigger");
      $('#game').replaceWith(message);
    });
    return false;
  });
  
  $(document).on('click', '#stay_form', function(){
    $.ajax({
      type: 'POST',
      url: '/stay'
    }).done(function(message){
      //alert("stay ajax trigger");
      $('#game').replaceWith(message);
    });
    return false;
  });  

  $(document).on('click', '#dealer_form', function(){
    $.ajax({
      type: 'POST',
      url: '/ask_dealer'
    }).done(function(message){
      //alert("dealer ajax trigger");
      $('#game').replaceWith(message);
    });
    return false;
  });
  
});