function getStudentValues(userId, aggregation, measureFields, tracker) {
  const row = new Map();
  // student meta data
  row.set('userID', userId)
  row.set('studentID', 'N/A')
  row.set('conditionID', 'N/A')
  row.set('classID', 'N/A')
  row.set('schoolID', 'N/A')
  row.set('teacherID', 'N/A')
  row.set('grade', 'N/A')
  row.set('gender', 'N/A')

  tracker.getTrials().forEach(trial => {
    const pid = trial.problem_id;
    // add problem meta data
    row.set(`p${pid}_uniqueID`, trial.problem_id)
    row.set(`p${pid}_assignmentID`, trial.assignment_id)
    row.set(`p${pid}_problemID`, trial.assignment_problem_id)
    row.set(`p${pid}_start_state`, trial.start_state)
    row.set(`p${pid}_goal_state`, trial.goal_state)
    // add measure fields
    measureFields.forEach(field => {
      row.set(`p${pid}_${field}`, 
        aggregation.getStudentProblemValue(field, userId, pid))
    });
  })
  
  return row;
}