'use strict';
/* global window, $, document, humanize, console, alert, google */
/* eslint-disable no-alert, no-console */

$(document).ready(function() {
  var pickerOptions = {
    theme: 'dark',
    minDate:'2016/01/01',
    maxDate:'+1970/01/02',
    allowTimes:['09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00'],
    closeOnDateSelect:true
  };
  $('#datetimepicker').datetimepicker(pickerOptions);
  $('#datetimepicker1').datetimepicker(pickerOptions);
  $('#datetimepicker2').datetimepicker(pickerOptions);
  var d = new Date();
  var fromDate = d.getFullYear() + '/' +  (d.getMonth() + 1) + '/' + d.getDate() + ' 09:00';
  var toDate = d.getFullYear() + '/' +  (d.getMonth() + 1) + '/' + d.getDate() + ' 17:00'
  $('#datetimepicker').val(toDate);
  $('#datetimepicker1').val(fromDate);
  $('#datetimepicker2').val(toDate);
  onDateChange(true);
  $('#datetimepicker').change(function() {
    onDateChange();
  });
  $('#reload').click(function() {
    onDateChange(true);
  });
  $('#range').change(function() {
    onDateChange(true);
  });



  function onDateChange(reload_chart) {
    $('#count_res').val("hi")
    var url = window.location.protocol + "//" + window.location.host + '/home/track'
    var atTime = $('#datetimepicker').val();
    var fromTime = $('#datetimepicker1').val();
    var toTime = $('#datetimepicker2').val();
    var range = $('#range').val();
    var payload = { at_time: atTime, from_time: fromTime, to_time: toTime, reload_chart: reload_chart, range: range }

    $.ajax({
      type: 'GET',
      xhrFields: { withCredentials: true },
      url: url,
      data: { event: payload },
      dataType: 'html',
      success: function (data) {
        // console.log("visitor events data ----------", data);
        //  $('#visitor_count').val(data.count);
        //  $('#chart1').remove();
         console.log("In success", data);
         $('#charts').html(data);
         // $('charts').append('<%= line_chart(data.chart2_data, xtitle: "Last 10 days", ytitle: "Number of Users", width: "700px", height: "250px", discrete: true, id: 'chart1') %>');

      },
      error: function(data, status, error) {
        console.log("In error 1",data);
        console.log(data);
        console.log("In error 2",status);
        console.log("In error 3",error);
      }
    });
  }
});
