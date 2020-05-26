class ScheduleTracker {
    constructor() {
        this.assignments = {};
        this.problems = {};
    }
    addTrial(trial) {
        this.problems[trial.problem_id] = trial;
        this.assignments[trial.assignment_id] = trial;
    }
    getTrials() {
        return Object.values(this.problems).sort((a, b) => a.problem_id - b.problem_id)
    }
    getAssignmentIds() {
        return Object.keys(assignments).sort()
    }
}