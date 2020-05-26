// Here is the original design document from Jenny:
// https://docs.google.com/spreadsheets/d/15CwI5QJQTWVnj_VMRZodJxanuArfZzLyKzBl_gXotG8/edit#gid=1148256851

// The intent is to turn a series of events of GM interaction data into some value that describes the
// interaction. There are many different aspects to measure, many of which depend on several events
// in a given interaction sequence. To avoid looping over the events for each measure, we define a class
// for each measure. That class will be fed a stream of sequential events from a GM trial, from which
// it must determine the result of its measure.
class Measure {
    constructor(name) {
        this.name = name;
        this.measure = null;
    }
    feed(data) {
        throw "[Measure] Called an abstract method."
    }
    check(data) {
        throw "[Measure] Called an abstract method."
    }
    getMeasure() {
        return this.measure;
    }
}

// There are two "default" values for measures: 0 (zero) and N/A. Those that default to zero are "boolean,"
// and if a certain condition passes, the measure will be set to 1 (one). Those that default to N/A are
// counts or other values. In these cases, "N/A" refers to a value that should not contribute to the average,
// as the user did not "see" this problem. However, if that value is set to zero, then it will contribute as
// a zero. 
class BooleanMeasure extends Measure {
    constructor(name) {
        super(name);
        this.measure = 0;
    }
    feed(data) {
        if (this.check(data)) this.measure = 1;
        // End the feed when the boolean measure has been set to true.
        return this.measure === 1;
    }
    setTrue() {
        this.measure = 1;
    }
}
class CountMeasure extends Measure {
    constructor(name) {
        super(name);
        this.measure = 'N/A';
    }
    isSeen() {
        return typeof this.measure !== 'string';
    }
    feed(data) {
        if (this.check(data)) this.increment();
        // Never end the feed, as we are counting something.
        return false;
    }
    increment() {
        this.start();
        this.measure++;
    }
    start() {
        if (!this.isSeen()) {
            this.measure = 0;
        }
    }
}
class TotalMeasure extends CountMeasure {
    constructor(name, valueField) {
        super(name);
        this.field = valueField;
    }
    feed(data) {
        if (this.check(data)) this.add(data[this.field]);
        // Never end the feed, as we are counting something.
        return false;
    }
    check(data) {
        return checkBooleanMeasure(data, this.field);
    }
    add(value) {
        this.start();
        this.measure += value;
    }
}
class PercentMeasure extends CountMeasure {
    constructor(name, valueField) {
        super(name);
        this.field = valueField;
        this.total = 0;
    }
    feed(data) {
        if (this.check(data)) this.increment();
        this.total++;
        return false;
    }
    check(data) {
        return checkBooleanMeasure(data, this.field);
    }
    getMeasure() {
        if (this.isSeen()) {
            return this.measure/this.total;
        }
        else {
            return this.measure;
        }
    }
}
class AverageMeasure extends CountMeasure {
    constructor(name, valueField) {
        super(name);
        this.field = valueField;
        this.total = 0;
    }
    feed(data) {
        if (this.check(data)) {
            this.add(data[this.field]);
            this.total++
        }
        // Never end the feed, as we are counting something.
        return false;
    }
    check(data) {
        return checkBooleanMeasure(data, this.field);
    }
    add(value) {
        this.start();
        this.measure += value;
    }
    getMeasure() {
        if (this.isSeen()) {
            if (this.total > 0) {
                return this.measure/this.total;
            }
            return 0;
        }
        else {
            return this.measure;
        }
    }
}

// p#_seen
// Problems	
// Boolean
// Per Problem
// "did the problem show up on the screen? By seen, we mean whether this problem was ever presented to the user. If  the  problem was presented, enter 1. If the problem was not presented, enter 0. For instance, if a student completed world 1 problem 14, and then decided to go to world 2 problem 1 instead of world 1 problem 15 and never visited world 1 problem 15, then world 1 problem 15 should have 0 in this column. 
// All cells in this column should be either 1 or 0. there should be no cases of NA."
// 1=yes, 0=no
class PSeenMeasure extends BooleanMeasure {
    constructor() {
        super('seen');
    }
    check(event) {
        return checkCustomType(event, 'visit');
    }
}

class PTriedMeasure extends BooleanMeasure {
    constructor() {
        super('tried');
    }
    check(event) {
        return event.type === 'interaction' && (event.subtype === 'rewrite' || event.subtype === 'mistake');
    }
}

class PNumVisitMeasure extends CountMeasure {
    constructor() {
        super('num_visit');
    }
    check(event) {
        return checkCustomType(event, 'visit');
    }
}

class PCompletedMeasure extends BooleanMeasure {
    constructor() {
        super('completed');
    }
    check(event) {
        return checkCustomType(event, 'complete');
    }
}

class PFirstCompletedMeasure extends BooleanMeasure {
    constructor() {
        super('first_completed');
        
    }
    feed(event) {
        const isCompleteEvent = checkCustomType(event, 'complete');
        if (isCompleteEvent) {
            this.setTrue();
        }
        // End the feed on reset because it is no longer the first attempt.
        return isCompleteEvent || checkCustomType(event, 'reset');
    }
}

class PCompletionsMeasure extends CountMeasure {
    constructor() {
        super('completions');
    }
    check(event) {
        return checkCustomType(event, 'complete');
    }
}

class PGoBacksMeasure extends BooleanMeasure {
    constructor() {
        super('goback');
        this.completeCount = 0;
    }
    feed(event) {
        if (checkCustomType(event, 'complete')) {
            this.completeCount++;
        }
        if (this.completeCount > 1) {
            this.setTrue();
            // End the feed when we've detected multiple completions.
            return true;
        }
        return false;
    }
}

class PNumGoBacksMeasure extends CountMeasure {
    constructor() {
        super('num_gobacks');
    }
    check(event) {
        return checkCustomType(event, 'complete');
    }
    getMeasure() {
        if (this.isSeen()) {
            return this.measure - 1;
        }
        else {
            return this.measure;
        }
    }
}

class PResetMeasure extends BooleanMeasure {
    constructor() {
        super('reset');
    }
    check(event) {
        return checkCustomType(event, 'reset');
    }
}

class PNumResetMeasure extends CountMeasure {
    constructor() {
        super('num_reset');
    }
    check(event) {
        return checkCustomType(event, 'reset');
    }
}

class PNumAttemptsMeasure extends CountMeasure {
    constructor() {
        super('num_attempts');
        this.triedMeasure = new PTriedMeasure();
        this.tried = false;
    }
    feed(event) {
        // The result of this measure cares whether or not the user
        // interacted with the expression.
        if (!this.tried) {
            this.tried = this.triedMeasure.feed(event);
        }
        // End the feed when we normally would, which is never.
        return super.feed(event);
    }
    check(event) {
        return checkCustomType(event, 'reset');
    }
    getMeasure() {
        if (this.tried) {
            return this.measure + 1;
        }
        else {
            return 0;
        }
    }
}

class PUseHintMeasure extends BooleanMeasure {
    constructor() {
        super('use_hint');
    }
    check(event) {
        return checkCustomType(event, 'hint');
    }
}

class PCloverFirstMeasure extends CountMeasure {
    constructor() {
        super('clover_first');
    }
    feed(event) {
        if (checkCustomType(event, 'complete')) {
            this.measure = event.score;
            // End the feed on the first completion.
            return true;
        }
        return false;
    }
}

class PCloverLastMeasure extends CountMeasure {
    constructor() {
        super('clover_last');
    }
    feed(event) {
        if (checkCustomType(event, 'complete')) {
            this.measure = event.score;
        }
        // Never end the feed, as we want the last possible completion.
        return false;
    }
}

class PCloverHighestMeasure extends CountMeasure {
    constructor() {
        super('clover_highest');
    }
    feed(event) {
        if (checkCustomType(event, 'complete') && (!this.isSeen() || event.score > this.measure)) {
            this.measure = event.score;
        }
        // Never end the feed, as we want every possible score.
        return false;
    }
}

class PTimeInteractionMeasure extends CountMeasure {
    constructor() {
        super('time_interaction');
        this.visitTime = null;
        this.heartbeatMeasure = new PTimeHeartbeatMeasure();
        this.firstEvent = null;
        this.lastEvent = null;
        this.foundLeave = false;
    }
    feed(event) {
        this.heartbeatMeasure.feed(event);
        if (!this.firstEvent) {
            this.firstEvent = event;
        }
        if (!this.lastEvent || event.time > this.lastEvent.time) {
            this.lastEvent = event;
        }
        if (checkCustomType(event, 'visit')) {
            if (this.visitTime !== null) {
                // console.warn("[PTimeInteractionMeasure] Warning, there may be a missing leave event: " +
                //     "encountered a visit event when we have a visit time in memory.");
            }
            this.visitTime = event.time;
        }
        else if (checkCustomType(event, 'leave')) {
            if (this.visitTime === null) {
                // console.warn("[PTimeInteractionMeasure] Warning, encountered a leave event without a " +
                //     "corresponding visit event.");
                this.foundLeave = true;
            }
            else {
                this.start();
                this.measure += event.time - this.visitTime;
                this.visitTime = null;
            }
        }
    }
    getMeasure() {
        if (!this.isSeen() && (this.visitTime || this.foundLeave)) {
            if (this.heartbeatMeasure.isSeen()) {
                return this.heartbeatMeasure.measure;
            }
            else if (this.firstEvent && this.lastEvent) {
                return this.lastEvent.time - this.firstEvent.time;
            }
        }
        return super.getMeasure();
    }
}

// This measure is a backup that attempts to determine the total time the user spent
// on the streamed events by counting the heartbeats and summing the time intervals.
class PTimeHeartbeatMeasure extends CountMeasure {
    constructor() {
        super('time_heartbeat');
    }
    check(event) {
        return checkCustomType(event, 'heartbeat');
    }
    increment() {
        this.start();
        this.measure += 5;
    }
}

class PAvgTimePerStepMeasure extends CountMeasure {
    constructor() {
        super('avg_time_per_step');
        this.numStepsMeasure = new PNumStepsMeasure();
        this.timeInteractionMeasure = new PTimeInteractionMeasure();
    }
    feed(event) {
        this.numStepsMeasure.feed(event);
        this.timeInteractionMeasure.feed(event);
        return false;
    }
    getMeasure() {
        if (this.numStepsMeasure.measure === 0 || !this.numStepsMeasure.isSeen()) {
            return 'N/A';
        }
        else {
            let measure = this.timeInteractionMeasure.getMeasure()/this.numStepsMeasure.measure;
            if (isNaN(measure)) {
                debugger;
            }
            return measure;
        }
    }
}

class PTimeFirstMeasure extends CountMeasure {
    constructor() {
        super('time_first');
        this.visitTime = null;
        this.triedMeasure = new PTriedMeasure();
    }
    feed(event) {
        this.triedMeasure.feed(event);
        if (checkCustomType(event, 'visit')) {
            this.visitTime = event.time;
        }
        else if (checkCustomType(event, 'leave')) {
            this.add(event);
        }
        else if (checkCustomType(event, 'complete') || checkCustomType(event, 'reset')) {
            this.add(event);
            return true;
        }
        return false;
    }
    add(event) {
        this.start();
        this.measure += event.time - this.visitTime;
        this.visitTime = null;
    }
    getMeasure() {
        if (this.triedMeasure.measure === 0) {
            return 'N/A';
        }
        return this.measure;
    }
}

class PTimeLastMeasure extends CountMeasure {
    constructor() {
        super('time_last');
        this.tempMeasure = 0;
        this.visitTime = null;
        this.completedMeasure = new PCompletedMeasure();
    }
    feed(event) {
        this.completedMeasure.feed(event);
        if (checkCustomType(event, 'visit')) {
            this.visitTime = event.time;
        }
        else if (checkCustomType(event, 'leave')) {
            this.add(event);
        }
        else if (checkCustomType(event, 'reset')) {
            this.tempMeasure = 0;
            this.visitTime = event.time;
        }
        else if (checkCustomType(event, 'complete')) {
            this.add(event);
            this.accept();
        }
        return false;
    }
    add(event) {
        this.tempMeasure += event.time - this.visitTime;
        this.visitTime = null;
    }
    accept() {
        this.measure = this.tempMeasure;
        this.tempMeasure = 0;
    }
    getMeasure() {
        if (this.completedMeasure.measure === 0) {
            return 'N/A';
        }
        else {
            return this.measure;
        }
    }
}

class PTimeInteractionFirstMeasure extends CountMeasure {
    constructor() {
        super('time_interaction_first');
        this.tempMeasure = 0;
        this.triedMeasure = new PTriedMeasure();
    }
    feed(event) {
        this.triedMeasure.feed(event);
        if (checkCustomType(event, 'visit')) {
            this.visitTime = event.time;
        }
        else if (checkCustomType(event, 'leave')) {
            this.add(event);
        }
        else if (checkIfStep(event)) {
            this.add(event);
            this.accept();
            return true;
        }
        return false;
    }
    add(event) {
        this.tempMeasure += event.time - this.visitTime;
        this.visitTime = null;
    }
    accept() {
        this.measure = this.tempMeasure;
        this.tempMeasure = 0;
    }
    getMeasure() {
        if (this.triedMeasure.measure === 0) {
            return 'N/A';
        }
        else {
            return this.measure;
        }
    }
}

class PTimeInteractionFirstPercentMeasure extends CountMeasure {
    constructor() {
        super('time_interaction_first_percent');
        this.timeInteractionMeasure = new PTimeInteractionFirstMeasure();
        this.timeMeasure = new PTimeFirstMeasure();
    }
    feed(event) {
        this.timeInteractionMeasure.feed(event);
        this.timeMeasure.feed(event);
        return false;
    }
    getMeasure() {
        if (this.timeInteractionMeasure.measure === 'N/A') {
            return 'N/A';
        }
        else {
            return this.timeInteractionMeasure.measure/this.timeMeasure.measure;
        }
    }
}

class PTimeInteractionLastMeasure extends CountMeasure {
    constructor() {
        super('time_interaction_last');
        this.tempMeasure = 0;
        this.visitTime = null;
        this.completedMeasure = new PCompletedMeasure();
    }
    feed(event) {
        this.completedMeasure.feed(event);
        if (checkCustomType(event, 'visit')) {
            this.visitTime = event.time;
        }
        else if (checkCustomType(event, 'leave')) {
            this.add(event);
        }
        else if (checkCustomType(event, 'reset')) {
            this.tempMeasure = 0;
            this.visitTime = event.time;
        }
        else if (checkIfStep(event)) {
            this.add(event);
        }
        else if (checkCustomType(event, 'complete')) {
            this.accept();
        }
        return false;
    }
    add(event) {
        this.tempMeasure += event.time - this.visitTime;
        this.visitTime = null;
    }
    accept() {
        this.measure = this.tempMeasure;
        this.tempMeasure = 0;
    }
    getMeasure() {
        if (this.completedMeasure.measure === 0) {
            return 'N/A';
        }
        else {
            return this.measure;
        }
    }
}

class PTimeInteractionLastPercentMeasure extends CountMeasure {
    constructor() {
        super('time_interaction_last_percent');
        this.timeInteractionMeasure = new PTimeInteractionLastMeasure();
        this.timeMeasure = new PTimeLastMeasure();
    }
    feed(event) {
        this.timeInteractionMeasure.feed(event);
        this.timeMeasure.feed(event);
        return false;
    }
    getMeasure() {
        if (this.timeInteractionMeasure.measure === 'N/A') {
            return 'N/A';
        }
        else {
            return this.timeInteractionMeasure.measure/this.timeMeasure.measure;
        }
    }
}

class PInteractionStepFirstMeasure extends BooleanMeasure {
    constructor() {
        super('interaction_step_first');
    }
    check(event) {
        if (checkIfStep(event)) {
            this.setTrue();
            return true;
        }
        else if (checkIfMistake(event)) {
            // stop feeding on mistake, as that would mean
            // their first interaction was not a valid step
            return true;
        }
    }
}

class PInteractionStepLastMeasure extends BooleanMeasure {
    constructor() {
        super('interaction_step_last');
        this.tempMeasure = 0;
        this.firstInteraction = null;
    }
    check(event) {
        if (checkIfStep(event) && !this.firstInteraction) {
            this.setTrue();
            this.firstInteraction = event;
        }
        else if (checkIfMistake(event) && !this.firstInteraction) {
            this.firstInteraction = event;
        }
        else if (checkCustomType(event, 'complete')) {
            // Whenever there is a completion we will overwrite the existing
            // value with the current (last) attempt's value.
            this.accept();
        }
        return false;
    }
    setTrue() {
        this.tempMeasure = 1;
    }
    accept() {
        this.measure = this.tempMeasure;
        this.tempMeasure = 0;
        this.firstInteraction = null;
    }
}

class PNumStepsMeasure extends CountMeasure {
    constructor() {
        super('num_steps');
    }
    check(event) {
        return checkIfStep(event);
    }
}

class PUserFirstStepMeasure extends CountMeasure {
    constructor() {
        super('user_first_step');
    }
    feed(event) {
        super.feed(event);
        return checkCustomType(event, 'complete');
    }
    check(event) {
        return checkIfStep(event);
    }
}

class PUserLastStepMeasure extends CountMeasure {
    constructor() {
        super('user_last_step');
        this.tempMeasure = 0;
        this.completedMeasure = new PCompletedMeasure();
    }
    feed(event) {
        this.completedMeasure.feed(event);
        super.feed(event);
        if (checkCustomType(event, 'complete')) {
            this.accept();
        }
        if (checkCustomType(event, 'reset')) {
            this.tempMeasure = 0;
        }
        return false;
    }
    check(event) {
        return checkIfStep(event);
    }
    increment() {
        this.start();
        this.tempMeasure++;
    }
    accept() {
        this.measure = this.tempMeasure;
        this.tempMeasure = 0;
    }
    getMeasure() {
        if (this.completedMeasure.measure === 0) {
            return 'N/A';
        }
        else {
            return this.measure;
        }
    }
}

class PFirstEfficiencyMeasure extends CountMeasure {
    constructor(trial) {
        super('first_efficiency');
        this.bestStep = +trial.best_step;
        this.completedMeasure = new PCompletedMeasure();
        this.firstStepMeasure = new PUserFirstStepMeasure();
    }
    feed(event) {
        if (!this.complete1) {
            this.complete1 = this.completedMeasure.feed(event);
        }
        if (!this.complete2) {
            this.complete2 = this.firstStepMeasure.feed(event);
        }
        return this.complete1 && this.complete2;
    }
    getMeasure() {
        if (this.completedMeasure.measure === 0 || !this.isSeen()) {
            return 'N/A';
        }
        else return this.firstStepMeasure.measure / this.bestStep;
    }
}

class PLastEfficiencyMeasure extends CountMeasure {
    constructor(trial) {
        super('last_efficiency');
        this.bestStep = trial.best_step;
        this.completedMeasure = new PCompletedMeasure();
        this.lastStepMeasure = new PUserLastStepMeasure();
    }
    feed(event) {
        if (!this.complete1) {
            this.complete1 = this.completedMeasure.feed(event);
        }
        if (!this.complete2) {
            this.complete2 = this.lastStepMeasure.feed(event);
        }
        return this.complete1 && this.complete2;
    }
    getMeasure() {
        if (this.completedMeasure.measure === 0 || !this.isSeen()) {
            return 'N/A';
        } else {
            return this.lastStepMeasure.measure/this.bestStep;
        }
    }
}

class PFirstMoreStepMeasure extends CountMeasure {
    constructor(trial) {
        super('first_efficiency');
        this.bestStep = trial.best_step;
        this.completedMeasure = new PCompletedMeasure();
        this.firstStepMeasure = new PUserFirstStepMeasure();
    }
    feed(event) {
        if (!this.complete1) {
            this.complete1 = this.completedMeasure.feed(event);
        }
        if (!this.complete2) {
            this.complete2 = this.firstStepMeasure.feed(event);
        }
        return this.complete1 && this.complete2;
    }
    getMeasure() {
        if (this.completedMeasure.measure === 0) {
            return 'N/A';
        }
        else if (this.isSeen()) {
            return this.firstStepMeasure.measure-this.bestStep;
        }
        else {
            return this.measure;
        }
    }
}

class PLastMoreStepMeasure extends CountMeasure {
    constructor(trial) {
        super('last_efficiency');
        this.bestStep = trial.best_step;
        this.completedMeasure = new PCompletedMeasure();
        this.lastStepMeasure = new PUserLastStepMeasure();
    }
    feed(event) {
        if (!this.complete1) {
            this.complete1 = this.completedMeasure.feed(event);
        }
        if (!this.complete2) {
            this.complete2 = this.lastStepMeasure.feed(event);
        }
        return this.complete1 && this.complete2;
    }
    getMeasure() {
        if (this.completedMeasure.measure === 0) {
            return 'N/A';
        }
        else if (this.isSeen()) {
            return this.lastStepMeasure.measure-this.bestStep;
        }
        else {
            return this.measure;
        }
    }
}

class PTotalErrorMeasure extends CountMeasure {
    constructor() {
        super('total_error');
    }
    check(event) {
        return checkIfMistake(event);
    }
}

class PFirstErrorMeasure extends CountMeasure {
    constructor() {
        super('first_error');
    }
    feed(event) {
        super.feed(event);
        return checkCustomType(event, 'complete') || checkCustomType(event, 'reset');
    }
    check(event) {
        return checkIfMistake(event);
    }
}

class PLastErrorMeasure extends CountMeasure {
    constructor() {
        super('last_error');
        this.tempMeasure = 0;
    }
    feed(event) {
        super.feed(event);
        if (checkCustomType(event, 'custom')) {
            this.accept();
        }
        if (checkCustomType(event, 'reset')) {
            this.tempMeasure = 0;
        }
    }
    check(event) {
        return checkIfMistake(event);
    }
    increment() {
        this.start();
        this.tempMeasure++;
    }
    accept() {
        this.measure = this.tempMeasure;
        this.tempMeasure = 0;
    }
}

class PKeypadErrorMeasure extends CountMeasure {
    constructor() {
        super('keypad_error');
    }
    check(event) {
        return checkIfKeypadError(event);
    }
}

class PFirstKeypadErrorMeasure extends CountMeasure {
    constructor() {
        super('first_keypad_error');
    }
    feed(event) {
        super.feed(event);
        return checkCustomType(event, 'complete') || checkCustomType(event, 'reset');
    }
    check(event) {
        return checkIfKeypadError(event);
    }
}

class PLastKeypadMeasure extends CountMeasure {
    constructor() {
        super('last_keypad_error');
    }
    feed(event) {
        super.feed(event);
        if (checkCustomType(event, 'custom')) {
            this.accept();
        }
        if (checkCustomType(event, 'reset')) {
            this.tempMeasure = 0;
        }
    }
    check(event) {
        return checkIfKeypadError(event);
    }
    increment() {
        this.start();
        this.tempMeasure++;
    }
    accept() {
        this.measure = this.tempMeasure;
        this.tempMeasure = 0;
    }
}

class PShakingErrorMeasure extends CountMeasure {
    constructor() {
        super('shaking_error');
    }
    check(event) {
        return checkIfShakingError(event);
    }
}

class PFirstShakingErrorMeasure extends CountMeasure {
    constructor() {
        super('first_shaking_error');
    }
    feed(event) {
        super.feed(event);
        return checkCustomType(event, 'complete') || checkCustomType(event, 'reset');
    }
    check(event) {
        return checkIfShakingError(event);
    }
}

class PLastShakingMeasure extends CountMeasure {
    constructor() {
        super('last_shaking_error');
        this.tempMeasure = 0;
    }
    feed(event) {
        super.feed(event);
        if (checkCustomType(event, 'custom')) {
            this.accept();
        }
        if (checkCustomType(event, 'reset')) {
            this.tempMeasure = 0;
        }
    }
    check(event) {
        return checkIfShakingError(event);
    }
    increment() {
        this.start();
        this.tempMeasure++;
    }
    accept() {
        this.measure = this.tempMeasure;
        this.tempMeasure = 0;
    }
}

class PSnappingErrorMeasure extends CountMeasure {
    constructor() {
        super('snapping_error');
    }
    check(event) {
        return checkIfSnappingError(event);
    }
}

class PFirstSnappingErrorMeasure extends CountMeasure {
    constructor() {
        super('first_snapping_error');
    }
    feed(event) {
        super.feed(event);
        return checkCustomType(event, 'complete') || checkCustomType(event, 'reset');
    }
    check(event) {
        return checkIfSnappingError(event);
    }
}

class PLastSnappingMeasure extends CountMeasure {
    constructor() {
        super('last_snapping_error');
        this.tempMeasure = 0;
    }
    feed(event) {
        super.feed(event);
        if (checkCustomType(event, 'custom')) {
            this.accept();
        }
        if (checkCustomType(event, 'reset')) {
            this.tempMeasure = 0;
        }
    }
    check(event) {
        return checkIfMistake(event);
    }
    increment() {
        this.start();
        this.tempMeasure++;
    }
    accept() {
        this.measure = this.tempMeasure;
        this.tempMeasure = 0;
    }
}

function checkIfKeypadError(event) {
    return event.type == 'interaction' && event.subtype == 'mistake' && event.method == 'keypad';
}

function checkIfShakingError(event) {
    return event.type == 'interaction' && event.subtype == 'mistake' && event.method == 'tap';
}

function checkIfSnappingError(event) {
    return event.type == 'interaction' && event.subtype == 'mistake' && event.method != 'keypad' && event.method != 'tap';
}

function checkIfStep(event) {
    return event.type === 'interaction' && event.subtype === 'rewrite';
}

function checkIfMistake(event) {
    return event.type === 'interaction' && event.subtype === 'mistake';
}

function checkCustomType(event, type) {
    return event.type === 'custom' && event.subtype === type;
}

class Measures {
    constructor(measures=[]) {
        this.measures = measures.map(function(m) {
            return { measure: m, isComplete: false }
        });
    }
    feed(data) {
        let allComplete = true;
        this.measures.forEach(m => {
            if (!m.isComplete) m.isComplete = m.measure.feed(data);
            allComplete = allComplete && m.isComplete;
        });

        // This can return true if you are only collecting boolean measures.
        return allComplete;
    }
    getResults() {
        return this.measures.map(m => {
            const value = m.measure.getMeasure();
            if (isNaN(value) && value !== 'N/A') {
                console.warn('Found a NaN value for a measure.');
                debugger;
            }
            return {
                name: m.measure.name,
                measure: value
            }
        });
    }
}

// At this time, it is best practice for all measures to be ran from this class and not
// by themselves. This is because the interpretation of "number"-type measures depends on
// whether the problem has been "seen" or not by the user. This class will always privately
// run an instance of the seen-measure (whether or not the seen-measure is desired in the 
// final results) and notify other measures when the problem has been seen.

// This design decision was made on the following desires:
// 1. Whenever a method of a measure class instance is called, the type of the "measure" instance member
//   should be consistent with whether the problem is seen or not. (I.e. if a seen-measure instance would
//   give true as its measure, the measure of another value-measure instance should be zero, not N/A.)
//   Note that even in the current implementation, in the time between feeding the event to the seen-measure
//   and starting the value-measure, "seen" will be true while the measure's value will be N/A.
// 2. It should not matter in which position the seen measure instance appears in the list of
//   actively collected measures. Always running a seen-measure privately avoids this.
// 3. At this time, I don't think I want to default every measure value to zero, and then go over all
//   measures after streaming events to update the value to N/A if the problem was not seen. I would
//   prefer if all measure values were final once the final event has been streamed to all measures.

// This is however, not the ideal solution I think. With this architecture, there is a sequential
// dependency between all measures and the seen measure, where you must go: feed seen measure -> start
// other measure instances based on return value -> feed other measures. (This being the reason why you
// should always access measure classes through this class and not by themselves.)
class PMeasures extends Measures {
    constructor(trial) {
        super([
            new PSeenMeasure(),
            new PTriedMeasure(),
            new PNumVisitMeasure(),
            new PCompletedMeasure(),
            new PFirstCompletedMeasure(),
            new PCompletionsMeasure(),
            new PGoBacksMeasure(),
            new PNumGoBacksMeasure(),
            new PResetMeasure(),
            new PNumResetMeasure(),
            new PNumAttemptsMeasure(),
            new PUseHintMeasure(),
            new PCloverFirstMeasure(),
            new PCloverLastMeasure(),
            new PCloverHighestMeasure(),
            new PTimeInteractionMeasure(),
            new PTimeHeartbeatMeasure(),
            new PAvgTimePerStepMeasure(),
            new PTimeFirstMeasure(),
            new PTimeLastMeasure(),
            new PTimeInteractionFirstMeasure(),
            new PTimeInteractionFirstPercentMeasure(),
            new PTimeInteractionLastMeasure(),
            new PTimeInteractionLastPercentMeasure(),
            new PInteractionStepFirstMeasure(),
            new PInteractionStepLastMeasure(),
            new PNumStepsMeasure(),
            new PUserFirstStepMeasure(),
            new PUserLastStepMeasure(),
            new PFirstEfficiencyMeasure(trial),
            new PLastEfficiencyMeasure(trial),
            new PFirstMoreStepMeasure(trial),
            new PLastMoreStepMeasure(trial),
            new PTotalErrorMeasure(),
            new PFirstErrorMeasure(),
            new PLastErrorMeasure(),
            new PKeypadErrorMeasure(),
            new PFirstKeypadErrorMeasure(),
            new PLastKeypadMeasure(),
            new PShakingErrorMeasure(),
            new PFirstShakingErrorMeasure(),
            new PLastShakingMeasure(),
            new PSnappingErrorMeasure(),
            new PFirstSnappingErrorMeasure(),
            new PLastSnappingMeasure()
        ]);
        this.seenMeasure = new PSeenMeasure();
        this.seen = false;
    }
    feed(event) {
        // Here is the key sequential dependency between this seen-measure and others.
        // Must do this before looping over other measures.
        if (!this.seen) {
            this.seen = this.seenMeasure.feed(event);
            if (this.seen) {
                this.measures.forEach(m => {
                    if (m.measure.start) m.measure.start();
                });
            }
        }

        return super.feed(event);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////

class ASeenMeasure extends CountMeasure {
    constructor() {
        super('seen');
    }
    check(trial) {
        return checkBooleanMeasure(trial, 'p_measure_seen');
    }
}

class ASeenBooleanMeasure extends BooleanMeasure {
    constructor() {
        super('seen_bool');
    }
    check(trial) {
        return checkBooleanMeasure(trial, 'p_measure_seen');
    }
}

class ATriedMeasure extends CountMeasure {
    constructor() {
        super('tried');
    }
    check(trial) {
        return checkBooleanMeasure(trial, 'p_measure_tried');
    }
}

class ANumVisitMeasure extends TotalMeasure {
    constructor() {
        super('num_visit', 'p_measure_num_visit');
    }
}

class ADistinctCompletedMeasure extends CountMeasure {
    constructor() {
        super('distinct_completed');
    }
    check(trial) {
        return checkBooleanMeasure(trial, 'p_measure_completed');
    }
}

class APercentageCompletedMeasure extends PercentMeasure {
    constructor() {
        super('percentage_completed', 'p_measure_completed');
    }
}

class ATotalCompletedMeasure extends TotalMeasure {
    constructor() {
        super('total_completed', 'p_measure_completions');
    }
}

class AFirstCompletedMeasure extends CountMeasure {
    constructor() {
        super('distinct_completed');
    }
    check(trial) {
        return checkBooleanMeasure(trial, 'p_measure_completed');
    }
}

class DependentPercentMeasure extends PercentMeasure {
    constructor(name, field, measure) {
        super(name, field);
        this.independent = measure;
    }
    feed(trial) {
        this.independent.feed(trial);
        return super.feed(trial);
    }
    getMeasure() {
        if (this.isSeen()) {
            if (this.independent.measure) {
            }
            return 0;
        }
        else {
            return this.measure;
        }
    }
}

class APercentFirstCompleted extends DependentPercentMeasure {
    constructor() {
        super('percent_first_completed', 'p_measure_first_completed', new ADistinctCompletedMeasure());
    }
}

class AGoBacks extends CountMeasure {
    constructor() {
        super('gobacks');
    }
    check(trial) {
        return checkBooleanMeasure(trial, 'p_measure_goback');
    }
}

class APercentGoBacks extends DependentPercentMeasure {
    constructor() {
        super('percent_gobacks', 'p_measure_goback', new ADistinctCompletedMeasure());
    }
}

class AAvgNumGoBacks extends AverageMeasure {
    constructor() {
        super('avg_num_gobacks', 'p_measure_num_gobacks')
    }
}

class ADistinctReset extends CountMeasure {
    constructor() {
        super('distinct_reset');
    }
    check(trial) {
        return checkBooleanMeasure(trial, 'p_measure_reset')
    }
}

class APercentReset extends PercentMeasure {
    constructor() {
        super('percentage_reset', 'p_measure_reset', new ASeenMeasure()); // "percantage" differs from other wordings
    }
}

class AAvgNumReset extends AverageMeasure {
    constructor() {
        super('avg_num_reset', 'p_measure_num_reset');
    }
}

function checkBooleanMeasure(trial, measure) {
    return typeof trial[measure] === 'number' && trial[measure] >= 1;
}

class AMeasures extends Measures {
    constructor() {
        super([
            new ASeenMeasure(),
            new ATriedMeasure(),
            new ANumVisitMeasure(),
            new ADistinctCompletedMeasure(),
            new APercentageCompletedMeasure(),
            new ATotalCompletedMeasure(),
            new AFirstCompletedMeasure(),
            new APercentFirstCompleted(),
            new AGoBacks(),
            new APercentGoBacks(),
            new AAvgNumGoBacks(),
            new ADistinctReset(),
            new APercentReset(),
            new AAvgNumReset(),

        ]);
        this.seenMeasure = new ASeenBooleanMeasure();
        this.seen = false;
    }
    feed(event) {
        // Here is the key sequential dependency between this seen-measure and others.
        // Must do this before looping over other measures.
        if (!this.seen) {
            this.seen = this.seenMeasure.feed(event);
            if (this.seen) {
                this.measures.forEach(m => {
                    if (m.measure.start) m.measure.start();
                });
            }
        }

        return super.feed(event);
    }
}
