(function(){

  $.get( '/surfline', function( content ){
    $('#surfline-report-wrapper').html( content );


    var $spot_conditions_report = $('.spot-conditions-report');

    if( $spot_conditions_report.hasClass('seen-it-already') ) {
      $spot_conditions_report.hide();
    }

    $('#surfline-report-wrapper').click(function(){
      $spot_conditions_report.slideToggle('fast');
      return false;
    });

  });

  $.get( '/cflsurf', function( content ){
    $('#cflsurf-report-wrapper').html( content );
  });


  $.get( '/freeman', function( content ){
    $('#freeman-report-wrapper').html( content );
  });

  $.get( '/checkthewaves', function( content ){
    $('#checkthewaves-report-wrapper').html( content );
  });
})();
