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

  $.get( '/surfline-county', function( content ){
    $('#surfline-county-report-wrapper').html( content );
  });

  $.get( '/weather', function( content ){
    $('#weather-report-wrapper').html( content );
  });

  $.get( '/buoy_41113', function( content ){
    $('#buoy-41113-report-wrapper').html( content );
    initializeBuoy('buoy_41113')
  });

  $.get( '/buoy_41009', function( content ){
    $('#buoy-41009-report-wrapper').html( content );
    initializeBuoy('buoy_41009')
  });
})();

function initializeBuoy(domSlug){
  const jsonNode = document.getElementById(`${domSlug}-chart-data`)
  const jsonText = jsonNode.textContent;
  const jsonData = JSON.parse(jsonText);

  BuoyChart(`#${domSlug}-buoy-chart`, jsonData)
}
