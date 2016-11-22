$( document ).ready(function() {
    $('.button-collapse').sideNav();
    $('div.switch').click(function(){
      $(this).prev().click();
      var target = $( event.target );
      console.log(target);
    });
    $('#config').click(function(){
      AHK('openConfig');
    });
    $('.tabs input').change(function(){
      if($(this).is(':checked')){
        $(this).parent().prev().click();
      }
    });
    $('.switch').tooltip({delay: 50});
    $('.lever').click(function(){
      if($(this).parents('#gtab').length)
      {
        if($("#garden-switch").prop("checked"))
          Materialize.toast('Disable with CTRL+SHIFT+5', 4000);
        else
          Materialize.toast('Enable with CTRL+SHIFT+4', 4000);
      }
      if($(this).parents('#atab').length)
      {
        if($("#afk-switch").prop("checked"))
          Materialize.toast('Disable with CTRL+SHIFT+1', 4000);
        else
          Materialize.toast('Enable with CTRL+SHIFT+1', 4000);
      }
      if($(this).parents('#ttab').length)
      {
        if($("#trampoline-switch").prop("checked"))
          Materialize.toast('Disable with CTRL+SHIFT+3', 4000);
        else
          Materialize.toast('Enable with CTRL+SHIFT+2', 4000);
      }
    });
    var transitionEnd = transitionEndEventName();
    $('.switch label .lever:after,.switch label .lever').each(function(){
      this.addEventListener(transitionEnd, ended, false);
    });
    function ended() {
        $('.tabs').attr("data-transitioning",false);  // Transition has ended.
        console.log("TRANS " + $('.tabs').attr("data-transitioning"));
    }
    var afkSwitch = $('#afk-switch');
    var trampSwitch = $('#trampline-switch');
    var gardenSwitch = $('#garden-switch');

    $('#water, #interval').mouseup(function(){
    AHK('updateSetting',$(this).attr('name'), $(this).val());
    });
    $('#replant, #repeat').change(function(){
    AHK('updateSetting',$(this).attr('name'), $(this).prop('checked'));
    });
  }); // end of document ready
  window.onerror = function(msg, url, linenumber, colnumber, error) {
  updateConsole('Javascript Error: '+msg+'\nError: '+error+'\nLine:'+linenumber+' Column:'+colnumber+' \nURL:'+url+' \n',"#error-console")
  AHK('verifyError')
  return true;
}
var canvas = document.getElementById('updating-chart'),
    ctx = canvas.getContext('2d'),
    $canvas = $('#updating-chart'),
    startingData = {
      labels: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40],
      datasets: [
        {},
          {
              fillColor: "#ff8a80",
              pointColor: "#ff8a80",
              pointStrokeColor: "rgba(0,0,0,0)",
              data: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
          }
      ]
    },
    latestLabel = startingData.labels[39];
canvas.setAttribute("height", 200);
// Reduce the animation steps for demo clarity.
var myLiveChart = new Chart(ctx).Line(startingData,{
  animationSteps: 20,
  responsive: true,
  pointDotRadius: 0,
//  bezierCurve: false,
toolTipContent: null,
showTooltips: false,
  scaleOverride : true,
        scaleSteps : 10,
        scaleStepWidth : 32,
        scaleStartValue : 0,
        showScale: false
});

var afkCanvas = document.getElementById('afk-chart'),
    afkctx = afkCanvas.getContext('2d'),
    $afkCanvas = $('#afk-chart'),
    afkStartingData = {

labels: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,296,297,298,299],
      datasets: [
        {},
          {
              fillColor: "#ff8a80",
              pointColor: "#ff8a80",
              pointStrokeColor: "rgba(0,0,0,0)",
              data: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
          }
      ]
    },
    afklatestLabel = afkStartingData.labels[39];
afkCanvas.setAttribute("height", 200);
var myLiveAFKChart = new Chart(afkctx).Line(afkStartingData,{
  animationSteps: 20,
  responsive: true,
  pointDotRadius: 0,
  bezierCurve: false,
toolTipContent: null,
showTooltips: false,
  scaleOverride : true,
        scaleSteps : 1,
        scaleStepWidth : 30,
        scaleStartValue : 0,
        showScale: false
});

var previous = "";
function plotAFK(data,txt){
  // Add two random numbers for each dataset
  myLiveAFKChart.addData([data,data], ++afklatestLabel);
  // Remove the first point so we dont just add values forever
  myLiveAFKChart.removeData();
  if(previous != data)
  {
    updateConsole("Plotting graph at " + data,"#afk-console");
  }
  previous = data;
}
function plotTrampoline(data,txt){
  // Add two random numbers for each dataset
  myLiveChart.addData([data,data], ++latestLabel);
  // Remove the first point so we dont just add values forever
  myLiveChart.removeData();
  updateConsole(txt);
}
var ct = 0;
function updateConsole(text,cons,clear){
  var text = text === undefined? null: text;
  var cons = cons === undefined? "#trampoline-console":cons;
  var clear = clear === undefined? false: clear;
  if(clear)
    $(cons).empty();
  $(cons).prepend(text +"\n");
  ct++;
}
function transitionEndEventName () {
    var i,
        undefined,
        el = document.createElement('div'),
        transitions = {
            'transition':'transitionend',
            'OTransition':'otransitionend',  // oTransitionEnd in very old Opera
            'MozTransition':'transitionend',
            'WebkitTransition':'webkitTransitionEnd'
        };

    for (i in transitions) {
        if (transitions.hasOwnProperty(i) && el.style[i] !== undefined) {
            return transitions[i];
        }
    }

    //TODO: throw 'TransitionEnd event is not supported in this browser';
}
function updateStatus(control,status){
  if($('.tabs').attr("data-transitioning") == "true"){
    setTimeout(function(){Materialize.toast("timed out, " + $('.tabs').attr("data-transitioning"), 4000);}, 1000);
  }
    if(control == "t"){
      $('.tabs').attr("data-transitioning", true);
      console.log("TRANS" + $('.tabs').attr("data-transitioning"));
      $('#ttab input').prop("checked", true);
      $("#ttab div").attr("data-tooltip", "Disable with CTRL+SHIFT+3");
      $('.switch').tooltip({delay: 50});
    }else if(control == "a"){
      $('.tabs').attr("data-transitioning", true);
      console.log("TRANS" + $('.tabs').attr("data-transitioning"));
      $('#atab input').prop("checked", true);
      $("#atab div").attr("data-tooltip", "Disable with CTRL+SHIFT+1");
      $('.switch').tooltip({delay: 50});
    }else if(control == "g"){
      $('.tabs').attr("data-transitioning", true);
      console.log("TRANS" + $('.tabs').attr("data-transitioning"));
      $('#gtab input').prop("checked", true);
      $("#gtab div").attr("data-tooltip", "Disable with CTRL+SHIFT+5");
      $('.switch').tooltip({delay: 50});
    }else{
      console.log("$('" + control + "').prop('checked'," + status + ")");
      $(control).prop("checked",status);
    }
}
function clearStatus(){
  $('.tabs').attr("data-transitioning", false);
  console.log("TRANS" + $('.tabs').attr("data-transitioning"));
  $('.tabs input').removeAttr('checked');
  $("#ttab div").attr("data-tooltip", "Enable with CTRL+SHIFT+2, Disable with CTRL+SHIFT+3");
  $("#atab div").attr("data-tooltip", "Enable with CTRL+SHIFT+1, Disable with CTRL+SHIFT+1");
  $("#gtab div").attr("data-tooltip", "Enable with CTRL+SHIFT+4, Disable with CTRL+SHIFT+5");
  $('.switch').tooltip({delay: 50});
}
