function updateDerivation()
{
	endTime=Date.now() / 1000 | 0;
	var problemID = $_GET['problemID'];
	var conditionID = $_GET['conditionID'];
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
	xmlhttp.open("POST","updateDerivation.php",true);
	xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    xmlhttp.send("attemptID="+attemptID+"&userID="+userID+"&problemID="+problemID+"&conditionID="+conditionID+"&startTime="+startTime+"&endTime="+endTime+"&stepCount="+steps+"&totalSteps="+totalSteps+"&attempts="+totalAttempts+"&report="+stepsTaken+"&derivationReport="+derivationReport);
}
            function solvedTouchProblem()
            {
				 endTime=Date.now() / 1000 | 0;
				 clearTimeout(hintTimer);
				 clearTimeout(skipTimer);
				 clearTimeout(derivationInterval);
				 var problemID = $_GET['problemID'];
				 var conditionID = $_GET['conditionID'];
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
						closeProblem();
                    }
                 }	
                 xmlhttp.open("POST","updateDerivation.php",true);
                 xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
                 xmlhttp.send("attemptID="+attemptID+"&userID="+userID+"&problemID="+problemID+"&conditionID="+conditionID+"&startTime="+startTime+"&endTime="+endTime+"&stepCount="+steps+"&totalSteps="+totalSteps+"&attempts="+totalAttempts+"&report="+stepsTaken+"&derivationReport="+derivationReport);
            }
var attemptID = 0;
var derivationInterval;
var stepsTaken = "";
var steps = 0;
var totalSteps = 0;
var totalAttempts = 1;
var finalScore=0;
var derivationReport = "";
gmath.ui = gmath.ui || {};
gmath.ui.Pill = (function() {
	var GMPill = function(container, settings) {
	this.events = d3.dispatch('done', 'reset');
	this.eq = settings.eq;
	this.correctAnswers = new gmath.AlgebraModel(settings.correctAnswers);
	this.answerArray = this.correctAnswers.to_ascii().split(",");
	this.userID = settings.userID;
	this.problemID = settings.problemID;
	this.minimumSteps = settings.minimumSteps;
	this.maximumSteps = settings.maximumSteps;
	this.experimentID = settings.experimentID;
	this.conditionID = settings.conditionID;
	this.conditionName = settings.conditionName;
	this.problemType = settings.problemType;
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
		var displayGoal=new gmath.AlgebraModel(this.correctAnswers).to_ascii();
		var svg = d3.select('#goalState').append('svg').style('margin-top', '-5px').style('margin-left', '100px');
		var model = new gmath.AlgebraModel(this.correctAnswers.to_ascii());
		var view = new gmath.AlgebraView(model, svg, {interactive: false, "inactive_color": $("#goalState").css("color"), "auto_resize_container":true, "font_size": 50, "normal_font":{"family":"Kalam","id":"_8a041c46eb608104"},"italic_font":{"family":"Kalam","id":"_8a041c46eb608104"}, pos: [150, 75]})
		view.init();
}

GMPill.prototype.init = function() {
	derivationReport = encodeURIComponent(new gmath.AlgebraModel(this.eq).to_ascii())+","+(Date.now() / 1000 | 0)+";";
	var div = this.container.append('div');
	this.gestureData.options.pos = ['auto', 'auto'];
	if (this.eq) {
		this.dl_div = div.append('div').classed('largeChoice', true).style('position','relative');

		var options = gmath.deepCopy(this.gestureData.options);
		options.inactive_color = $(".largeChoice").css("color");
		options.color = $(".largeChoice").css("color");
		options.font_size = 75;
		options.pos = {'x':'center','y':'center'};
		
		var logging_options = {
			experiment_id: this.experimentID
		  , enabled: true
		  };
		
		gmath.setupLogging(logging_options);		
		var custom_fields = {
			userID: this.userID,
			conditionID: this.conditionID,
			conditionName: this.conditionName,
			problemID: this.problemID,
			url: this.url
		  };
		console.log(custom_fields);
		var idx = 1;
		gmath.TrialLogger.startTrial(idx, custom_fields);
		
		this.canvas = new gmath.ui.CanvasFactory( this.dl_div.node()
		, { minimal: true, identification_interval: false, use_toolbar: false, use_keyboard: true
                    , keyboard_max_width: 800, log_mouse_trajectories: true } );
		gmath.DerivationList.defaultOptions.draggable = false;
		gmath.DerivationList.defaultOptions.no_handles = true;
		
		this.dl = this.canvas.model.createElement('derivation', options);
		
		//this.dl.events.on('added_line', this.canvas.focusOnDL.bind(this.canvas, this.dl)) 

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

GMPill.prototype.wrongTransition = function(sel, delay) {
		this.dl_div.append('span').classed('smallLabel', true).text('Incorrect. Try again!').classed('light', true).style({'opacity': 1, 'top': '0', 'height': '100%', 'width':'100%', 'background':'rgba(69, 70, 67, 0.5)'})
			.on('click', function() {
				self.reset();
			}).style({'opacity': 1,'height': '100%', 'line-height': '100px'});
		this.neutralTransition(this.dl_div, 200)
		this.dl.getLastView().interactive(true);
}

GMPill.prototype.timeTransition = function(sel, delay) {
	if(this.answered)
	return;
	var self = this;
	this.answered=true;
	this.dl.getLastView().interactive(false);
	this.draggable=false;

	if (this.reset_btn) {
		this.reset_btn.remove();
	}
	sel.append('span').classed('smallLabel', true).text('Time is up!').style({'opacity': 1.0, 'height': '50%', 'left': 0, 'top':0, 'right':0, 'background':'none', 'margin':'auto', 'line-height': '100px'});
	
	derivationReport += "OUT OF TIME,"+(Date.now() / 1000 | 0)+";";
	this.canvas.logger.logCustomInteraction('Ran out of time with '+(steps)+' steps and ' + totalAttempts + ' attempts.', {time: Date.now()});
	$("#answerPanel").remove();
	$("#resetPanel").remove();
	stepsTaken=stepsTaken + "Ran out of time with " +(steps) + " steps and " + totalAttempts + " attempts.";
	finalScore=0;
 	this.answered = true;
	gmath.TrialLogger.endTrial({completed: 1});
	solvedProblem();

	var ts = this.chainTransition(sel, delay).duration(500);
	ts.style('background', 'rgb(255,83,83)');
	ts.select('span').style('opacity', 1);
	ts.selectAll('div').style('opacity', 1);
	return ts;
}

GMPill.prototype.stepTransition = function(sel, delay) {
	if(this.answered)
	return;
	//this.answered=true;

	var self = this;
		
	this.dl.getLastView().interactive(false);
	this.draggable=false;

	if (this.reset_btn) {
		this.reset_btn.remove();
	}
	sel.append('span').classed('smallLabel', true).text('Too many steps!').style({'opacity': 1.0, 'height': '50%', 'left': 0, 'top':0, 'right':0, 'background':'none', 'margin':'auto', 'line-height': '100px'});
	
	derivationReport += "TOO MANY STEPS,"+(Date.now() / 1000 | 0)+";";
	this.canvas.logger.logCustomInteraction('Used too many steps.', {time: Date.now()});
	$("#answerPanel").remove();
	$("#resetPanel").remove();
	stepsTaken=stepsTaken + "Used too many steps.";
	finalScore=0;
 	this.answered = true;
	gmath.TrialLogger.endTrial({completed: 1});
	solvedProblem();
	var ts = this.chainTransition(sel, delay).duration(500);
	ts.style('background', 'rgb(255,83,83)');
	ts.select('span').style('opacity', 1);
	ts.selectAll('div').style('opacity', 1);
	return ts;
}

GMPill.prototype.skipTransition = function() {
	if(this.answered)
	return;
	//this.answered=true;

	var self = this;
		
	this.dl.getLastView().interactive(false);
	this.draggable=false;

	if (this.reset_btn) {
		this.reset_btn.remove();
	}
	this.dl_div.append('span').classed('smallLabel', true).text('Skipped!').style({'opacity': 1.0, 'height': '50%', 'left': 0, 'top':0, 'right':0, 'background':'none', 'margin':'auto', 'line-height': '100px'});
	
	derivationReport += "SKIPPED,"+(Date.now() / 1000 | 0)+";";
	this.canvas.logger.logCustomInteraction('Problem skipped.', {time: Date.now()});
	$("#answerPanel").remove();
	$("#resetPanel").remove();
	stepsTaken=stepsTaken + "Problem skipped.";
	finalScore=0;
 	this.answered = true;
	gmath.TrialLogger.endTrial({completed: 1});
	solvedProblem();
	var ts = this.chainTransition(this.dl_div, 200).duration(500);
	ts.style('background', 'rgb(255,83,83)');
	ts.select('span').style('opacity', 1);
	ts.selectAll('div').style('opacity', 1);
	return ts;
}

GMPill.prototype.correctTransition = function(sel, delay) {
	var self = this;

	if (this.reset_btn) {
		this.reset_btn.remove();
	}
	sel.append('span').classed('smallLabel', true).text('Nice job!').style({'opacity': 1, 'height': '50%', 'left': 0, 'top':0, 'right':0, 'background':'none', 'margin':'auto', 'line-height': '100px'});
	/*sel.append('div').classed('smallLabel', true).style({'opacity': 0.0001, 'height': '50%', top: '100px', 'float':'right'})
		.append('button').text('reset').style({'margin-top': '35px'}).on('click', function() {
			self.reset();
		})*/

	var ts = this.chainTransition(sel, delay).duration(500);
	ts.style('background', '#A8E0B3');
	ts.select('span').style('opacity', 1);
	ts.selectAll('div').style('opacity', 1);
	return ts;
}


GMPill.prototype.checkAnswer = function() {
	steps++;
	totalSteps++;

	if(steps>0)
	{
		document.getElementById("resetPanel").style.display="block";
	}
	if(this.answered || this.problemType==1)
	return;
	this.dl.getLastView().interactive(false);
	var ans = this.dl.getLastModel().to_ascii()
	if (this.answerArray.indexOf(ans) !== -1)
	{
		derivationReport+= "SOLVED " + encodeURIComponent(this.dl.getLastModel().to_ascii())+","+(Date.now() / 1000 | 0)+";";
		this.canvas.logger.logCustomInteraction('Solved in '+(steps)+' steps and ' + totalAttempts + ' attempts.', {time: Date.now()});
		stepsTaken=stepsTaken + "Solved in " +(steps) + " steps and " + totalAttempts + " attempts.";
		finalScore=1;
 		this.answered = true;
		gmath.TrialLogger.endTrial({completed: 1});
		solvedTouchProblem();
		this.correctTransition(this.dl_div, 200)
		  .each('end', this.events.done);
		$("#resetPanel").remove();
  	} 
	else
	{
		derivationReport+=encodeURIComponent(this.dl.getLastModel().to_ascii())+","+(Date.now() / 1000 | 0)+";";
		this.dl.getLastView().interactive(true);
	}
	document.getElementById("stepCount").innerHTML=steps;
}


GMPill.prototype.checkSubmittedAnswer = function(submittedAnswer) {
	if(this.answered || this.problemType==0)
	return;
	stepsTaken=stepsTaken+"Answered " + submittedAnswer + " at " + (steps+1) + " steps. ";
	this.dl.getLastView().interactive(false);
	if ((this.answerArray.indexOf(submittedAnswer)!==-1) && (steps>=this.minimumSteps || this.minimumSteps==0) && (steps<=this.maximumSteps || this.maximumSteps==0)) 
	{
		derivationReport += "SOLVED "+encodeURIComponent(submittedAnswer)+","+(Date.now() / 1000 | 0)+";";
		this.canvas.logger.logCustomInteraction('Solved in '+(steps)+' steps and ' + totalAttempts + ' attempts.', {time: Date.now()});
		//document.getElementById("answerPanel").style.display="none";
		//document.getElementById("resetPanel").style.display="none";
		stepsTaken=stepsTaken + "Solved in " +(steps) + " steps";
		finalScore=1;
 		this.answered = true;
		gmath.TrialLogger.endTrial({completed: 1});
		solvedTouchProblem();
		this.correctTransition(this.dl_div, 200)
		  .each('end', this.events.done);
		$("#answerPanel").remove();
		$("#resetPanel").remove();
	} 
	else 
	{
		derivationReport += "ANSWERED "+encodeURIComponent(submittedAnswer)+","+(Date.now() / 1000 | 0)+";";
		this.canvas.logger.logCustomInteraction('Answered ' + submittedAnswer + ' at '+(steps+1)+' steps. ', {time: Date.now()});
		this.dl.getLastView().interactive(true);
		this.wrongTransition(this.dl_div, 200);
		if(steps>this.maximumSteps && this.maximumSteps>0)
		{
			this.stepTransition(this.dl_div, 200);
		}		
	}
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

	document.getElementById("resetPanel").style.display="none";
	stepsTaken=stepsTaken+"Reset at " + (steps+1) + " steps. ";	
	steps = 0;
	totalAttempts++;
	this.dl.initPosition();
}



GMPill.prototype.stop = function() {
	this.player.stop_animation();
}


return GMPill;
})();

