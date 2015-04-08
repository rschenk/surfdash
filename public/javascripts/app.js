(function(){

  $.get( '/surfline', function( content ){
    $('#surfline-report-wrapper').html( content );
  });

})();
