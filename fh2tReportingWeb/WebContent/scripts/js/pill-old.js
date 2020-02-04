var stepsTaken = "";
var steps = 0;
var totalSteps = 0;
var totalAttempts = 1;
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
		/*var displayGoal=new gmath.AlgebraModel(this.correctAnswers).to_ascii();
		var svg = d3.select('#goalState').append('svg').style('margin-top', '-5px').style('margin-left', '100px');
		var model = new gmath.AlgebraModel(this.correctAnswers.to_ascii());
		var view = new gmath.AlgebraView(model, svg, {interactive: false, "inactive_color": $("#goalState").css("color"), "auto_resize_container":true, "font_size": 50, "normal_font":{"family":"Kalam","id":"_8a041c46eb608104"},"italic_font":{"family":"Kalam","id":"_8a041c46eb608104"}, pos: [150, 75]})
		view.init();
		*/
		var displayGoal=new gmath.AlgebraModel(this.correctAnswers).to_ascii();
		var div = d3.select('#goalState').append('div').style('margin-top', '65px').style('margin-left', '350px');
		var model = new gmath.AlgebraModel(this.correctAnswers.to_ascii());
		var goal_color = $("#goalState").css("color");
		var view = new gmath.AlgebraView(model, div.node(),
		  {interactive: false, inactive_color: goal_color, "font_size": 50, pos: [150, 75]});
		view.init();
}

GMPill.prototype.init = function() {
/*	derivationReport = encodeURIComponent(this.eq)+","+(Date.now() / 1000 | 0)+";";
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
		
	}
*/

	gmath.options.actions.allow_non_equivalent_keyboard_rewrite = false;
	derivationReport = encodeURIComponent(this.eq)+","+(Date.now() / 1000 | 0)+";";
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
			experiment_id: "wpi_fh2t"
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
		gmath.Derivation.defaultOptions.show_bg = false;

		this.canvas = new gmath.Canvas(this.dl_div.node()
		, { use_toolbar: false
			, keyboard_max_width: 800
      , log_mouse_trajectories: true
      , show_action_names: false
      , show_trigger_hints: true
      , show_destination_hints: true
      , use_hold_menu: false
      , vertical_scroll: false
      , disable_notifications: true
	  , ask_confirmation_on_closing: false
    });

    gmath.ui.Keyboard().layout('simple').position('left');

		this.dl = this.canvas.model.createElement('derivation', options);
		this.dl.events.on('end-of-interaction', this.checkAnswer.bind(this));
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
	steps++;
	totalSteps++;
	derivationReport+=encodeURIComponent(this.dl.getLastModel().to_ascii())+","+(Date.now() / 1000 | 0)+";";
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
	totalAttempts++;
	document.getElementById("stepCount").innerHTML=steps;
	document.getElementById("stepCount").className="";	
	this.dl.initPosition();
}

return GMPill;
})();

