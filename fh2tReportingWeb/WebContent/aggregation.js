const DEFAULT_VALUE = 'N/A';

/// Look up for data measures by student and problem across problem,
/// student, classroom, session, and overall. For now, just by student
/// and problem.

class Aggregation {
  constructor() {
    this.students = {}; // { problemId: { total<field>, count<field> } }
  }

  aggregateTrial(trial, fields) {
    let studentId = trial.user_id;
    let problemId = 'p' + trial.problem_id;
    fields.forEach(field => {
      if (!this.students[studentId]) this.students[studentId] = {};
      const student = this.students[studentId];
      const totalKey = `total${field}`;
      const valuesKey = `count${field}`;
      if (!student[problemId]) student[problemId] = {};
      const problem = student[problemId];
      if (!(totalKey in problem)) {
        problem[totalKey] = 0;
        problem[valuesKey] = 0;
      }
      problem[totalKey] += trial[`p_measure_${field}`];
      problem[valuesKey] += 1;
    });
  }

  getStudentProblemValue(field, userId, problemId) {
    const student = this.students[userId];
    if (!student) return DEFAULT_VALUE;
    const problem = student['p' + problemId];
    if (!problem) return DEFAULT_VALUE;
    if (!problem[`count${field}`]) return DEFAULT_VALUE;
    return problem[`total${field}`] / problem[`count${field}`];
  }
}