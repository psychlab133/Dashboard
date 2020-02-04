function updateDerivation()
{
	if(gmPill.answered)
	return;
	
	endTime=Date.now() / 1000 | 0;
	var problemID = $_GET['problemID'];
	var xmlhttp;
	if (window.XMLHttpRequest)
	{
	   xmlhttp=new XMLHttpRequest();
	}
	else
	{
	   xmlhttp=new ActiveXObject("Microsoft.XMLHTTP"); 
	}
	xmlhttp.onreadystatechange=function()
	{
	   if (xmlhttp.readyState==4 && xmlhttp.status==200)
	   {
			attemptID=xmlhttp.responseText;
	   }
	}	
	xmlhttp.open("POST","updatederivation.php",true);
	xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    xmlhttp.send("attemptID="+attemptID+"&problemID="+problemID+"&canvasID="+canvasID+"&trialID="+trialID+"&startTime="+startTime+"&endTime="+endTime+"&hintTime="+hintTime+"&stepCount="+steps+"&totalSteps="+totalSteps+"&errorCount="+errors+"&totalErrors="+totalErrors+"&mouseReport="+mouseReport+"&attempts="+totalAttempts+"&report="+stepsTaken+"&derivationReport="+derivationReport);
}
var attemptID = 0;
var canvasID = "";
var trialID = "";
var derivationInterval;
var stepsTaken = "";
var steps = 0;
var errors = 0;
var totalSteps = 0;
var totalErrors = 0;
var totalAttempts = 1;
var derivationReport = "";
var mouseReport="";
var lastStep="";

GMPill = function(container, settings) {
	this.events = d3.dispatch('done', 'reset');
	this.eq = settings.eq;
	this.correctAnswers = new gmath.AlgebraModel(settings.correctAnswers);
	this.answerArray = this.correctAnswers.to_ascii().split(",");
	this.userID = settings.userID;
	this.problemID = settings.problemID;
	this.conditionID = settings.conditionID;
	this.experimentID = settings.experimentID;
	this.url = window.location.href;
	this.gestureData = settings.gestureData;
	this.container = d3.select(container);
	this.dl_div = null;
	this.dl = null;
	this.answered = false;

	this.init();
	this.loadSettings();
}

GMPill.prototype.loadSettings = function()
{
		var div = d3.select('#goalState').append('div').style('position', 'absolute').style('margin-top', '65px').style('right', '350px');
		//var model = new gmath.AlgebraModel(this.correctAnswers.to_ascii());
		var model = new gmath.AlgebraModel(this.correctAnswers.to_ascii());
		//var model = new gmath.AlgebraModel("(2x+2+3+1+2+3+14+5)/2x");
		//var model = new gmath.AlgebraModel("2/4");
		var goal_color = "#000";//$("#goalState").css("color");
		var view = new gmath.AlgebraView(model, div.node(),
		  {interactive: false, inactive_color: goal_color, "font_size": 40});
		view.init();
		
		setTimeout(function(){
		 var rightSize=(div[0][0].childNodes[1].childNodes[0].style.width.replace("px","")/2);
		 div.style('left', 250+rightSize+"px"); 
		 console.log((div[0][0].style.right));
		 document.getElementById("goalPanel").style.width=((((div[0][0].style.left.replace("px","")*2)-150)<600)?600:((div[0][0].style.left.replace("px","")*2)-150))+"px";
		 }, 100);
}

GMPill.prototype.init = function() {
	
	
	
	
	
	
	
	gmath.options.actions.allow_non_equivalent_keyboard_rewrite = false;
	derivationReport = encodeURIComponent(this.eq)+","+(Date.now() / 1000 | 0)+";";
	lastStep=this.eq;
	var div = this.container.append('div');
	this.gestureData.options.pos = ['auto', 'auto'];
	if (this.eq) {
		this.dl_div = div.append('div').classed('largeChoice', true).style('position','relative');
		console.log(this.eq.length);
		var options = gmath.deepCopy(this.gestureData.options);
		options.inactive_color = $(".largeChoice").css("color");
		options.color = $(".largeChoice").css("color");
		options.font_size = (this.eq.length > 20)?(75-(Math.floor(this.eq.length/6)*5)):75;
		options.pos = {'x':'center','y':'center'};

		var logging_options = {
			experiment_id: "fh2t_testbed"
		  , enabled: true
		};

		gmath.setupLogging(logging_options);
		var custom_fields = {
			userID: this.userID,
			conditionID: this.conditionID,
			problemID: this.problemID,
			url: this.url
		};
		console.log(custom_fields);
		var idx = 1;
		gmath.TrialLogger.startTrial(idx, custom_fields);

		gmath.Derivation.defaultOptions.draggable = false;
		gmath.Derivation.defaultOptions.no_handles = true;

		this.canvas = new gmath.Canvas(this.dl_div.node()
		, { use_toolbar: false
			, keyboard_max_width: 800
      , log_mouse_trajectories: true
      , show_action_names: false
      , show_trigger_hints: false
      , show_destination_hints: false
      , use_hold_menu: false
      , vertical_scroll: false
      , horizontal_scroll: false
      , disable_notifications: true
	  , ask_confirmation_on_closing: false
    });
	console.log(this.canvas);
	canvasID = this.canvas.id;
	trialID = gmath.TrialLogger.trial.id;

    gmath.ui.Keyboard().layout('simple').position('left');

		this.dl = this.canvas.model.createElement('derivation', options);
		this.dl.events.on('end-of-interaction', this.checkAnswer.bind(this));
		derivationInterval = setInterval(function() { updateDerivation();}, 5000);
	}
}

GMPill.prototype.chainTransition = function(sel, delay) {
	if (sel.node().__transition__ && sel.id && sel.node().__transition__[sel.id]) {
		var transition = sel.node().__transition__[sel.id];
		//console.log('extra delay', transition.delay + transition.duration);
		delay += transition.delay + transition.duration;

	}
	if (this.step_span) {
		this.step_span.remove();
		this.step_span = sel.append('div').classed('smallLabel', true).classed('light', true).style('opacity', 1).style('right','0px').style('left','auto').style('bottom','0').style('top','auto')
			.append('p').text('step : ' + steps).style({'margin-top': '35px'});
	}
	return sel.transition().delay(delay);
}

GMPill.prototype.neutralTransition = function(sel, delay){
	var ts = this.chainTransition(sel, delay).duration(500);
	ts.style('background', $(".largeChoice").css("background-color"));
	ts.select('span').remove();
	ts.select('.smallLabel').remove();
	this.reset_btn = null;
	this.step_span = null;
	return ts;
}

GMPill.prototype.correctTransition = function(sel, delay) {
	var self = this;

	if (this.reset_btn) {
		this.reset_btn.remove();
	}
	sel.append('span').classed('smallLabel', true).text('Nice job!').style({'opacity': 0, 'height': '50%', 'left': 0, 'top':0, 'right':0, 'background':'none', 'margin':'auto', 'line-height': '100px'});
	/*sel.append('div').classed('smallLabel', true).style({'opacity': 0.0001, 'height': '50%', top: '100px', 'float':'right'})
		.append('button').text('reset').style({'margin-top': '35px'}).on('click', function() {
			self.reset();
		})*/

	var ts = this.chainTransition(sel, delay).duration(500);
	ts.style('color', '#A8E0B3');
	ts.select('span').style('opacity', 1);
	ts.selectAll('div').style('opacity', 1);
	return ts;
}


GMPill.prototype.checkAnswer = function() {
	if(lastStep!=this.dl.getLastModel().to_ascii())
	{
		steps++;
		totalSteps++;
		lastStep=this.dl.getLastModel().to_ascii();
	}
	else
	{
		errors++;
		totalErrors++;	
	}
	derivationReport+=encodeURIComponent(this.dl.getLastModel().to_ascii())+","+(Date.now() / 1000 | 0)+";";
	mouseReport+=mouseCoordinates+"|";
	mouseCoordinates="";
	if(this.answered)
	return;
	this.dl.getLastView().interactive(false);
	var ans = this.dl.getLastModel().to_ascii()
	if (this.answerArray.indexOf(ans) !== -1)
	{
		this.canvas.logger.logCustomInteraction('Solved in '+(steps)+' steps and ' + totalAttempts + ' attempts.', {time: Date.now()});
		stepsTaken=stepsTaken + "Solved in " +(steps) + " steps";
 		this.answered = true;
		gmath.TrialLogger.endTrial({completed: 1});
		solvedProblem();
		//this.correctTransition(this.dl_div, 200)
		  //.each('end', this.events.done);
  	}
	else
	{
		this.dl.getLastView().interactive(true);
	}
	if(steps>bestStep)
	{
		document.getElementById("stepCount").className="overStepLimit";
	}
	document.getElementById("stepCount").innerHTML=steps;
}


GMPill.prototype.resetPill = function() {
	if(this.answered==true)
	{
		document.getElementById("resetPanel").style.display="none";
		return;
	}
	derivationReport += "RESET,"+(Date.now() / 1000 | 0)+";";
	var self = this;
	this.neutralTransition(this.dl_div, 0)
		.each('end', function() {
			self.dl.getLastView().interactive(true);
			self.dl.setExpression(self.eq);
			self.events.reset();

		});
	this.canvas.logger.logCustomInteraction('Reset at '+steps+' steps', {time: Date.now()});
	this.answered = false;

	stepsTaken=stepsTaken+"Reset at " + (steps+1) + " steps. ";
	steps = 0;
	errors = 0;
	totalAttempts++;
	document.getElementById("stepCount").innerHTML=steps;
	document.getElementById("stepCount").className="";
	this.dl.initPosition();
}