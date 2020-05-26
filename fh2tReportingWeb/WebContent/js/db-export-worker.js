importScripts("https://d3js.org/d3-collection.v1.min.js");
importScripts("https://d3js.org/d3-array.v1.min.js");
importScripts("https://d3js.org/d3-dispatch.v1.min.js");
importScripts("https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.15/lodash.min.js");
importScripts("./fh2t-data-measures.js");
importScripts("./aggregation.js");
importScripts("./schedule-tracker.js");
importScripts("./table.js");

onmessage = function(msg) {
  var d = msg.data;
  if (d.isFHtT) {
    downloadFH2TAggregationCSV(d.arrayOfEvents, d.filename, d.include_trajectories, d.arrayOfTrials);
  }
  else {
    downloadCSV(d.arrayOfEvents, d.filename, d.include_trajectories, d.arrayOfTrials, d.isFHtT)
  }
}

function on_progress(val) {
  postMessage({ progress: val });
}

function on_error(val) {
  postMessage({ error: val });
}

function send_lines(lines) {
  postMessage({ lines: lines });
}

function downloadCSV(arrayOfEvents, filename, include_trajectories, arrayOfTrials) {
  var csv_lines = []
    , fields;
  var renamed = [];
  on_progress(0);

  fields = ['interaction_id', 'within_interaction_id', 'trial_id', 'canvas_id'
              ,'type', 'subtype', 'method', 'el_id', 'el_type', 'el_subid', 'el_subtype'
            , 'old_state', 'new_state', 'action', 'time', 'timestamp', 'dur', 'row_id'
            , 'expr_ascii', 'expr_x', 'expr_y', 'expr_width', 'expr_height', 'x', 'y'
            , 'sym_ascii', 'sym_x', 'sym_y', 'sym_width', 'sym_height', 'sel_ascii'
            , 'sel_x', 'sel_y', 'sel_width', 'sel_height', 'curr_state', 'next_state']
  , renamed = { old_state: 'initial_state', new_state: 'final_state' };

  // get custom event field names and add them to the fields array
  var custom_fields = getFieldNames(arrayOfEvents.filter(function(d) { return d.type === 'custom' }), ['_id']);
  fields = _.union(fields, custom_fields);
  on_progress(0.1);

  // get all trial field names
  var trial_fields = getFieldNames(arrayOfTrials, ['_id', 'id'])
                      .map(function(field) { return 'trial_' + field });
  fields = _.union(fields, trial_fields);
  on_progress(0.15);

  var header = fields.map(function(field) { return renamed[field] || field }).join(',');
  send_lines([header]);

  // sort and slice by trial & interaction id
  var trial_groups = d3.nest()
    .key(function(d) { return d.trial_id })
    .key(function(d) { return d.interaction_id })
    .entries(arrayOfEvents);
  
  on_progress(0.2);
  var n = 0, N = arrayOfEvents.length;
  trial_groups.forEach(function(trial_group) {
    // sort interactions by time
    trial_group.values.sort((a, b) => a.values[0].time - b.values[0].time);
    var trial = arrayOfTrials.find(t => t.id === trial_group.key);
    var cross_interaction_fields = { user_id: null, user_type: null };
    trial_group.values.forEach(function(interaction_group) {
      n += interaction_group.values.length;
      send_lines(getCSVLinesForInteraction(fields, interaction_group.values, trial, include_trajectories, cross_interaction_fields));
    });
    on_progress(0.2 + n/N * 0.8);
  });

  postMessage('done');
}

function downloadFH2TAggregationCSV(arrayOfEvents, filename, include_trajectories, arrayOfTrials) {
  var csv_lines = []
    , fields;
  var renamed = [];
  on_progress(0);

  fields = ['interaction_id', 'within_interaction_id', 'trial_id', 'canvas_id'
              ,'type', 'subtype', 'method', 'el_id', 'el_type', 'el_subid', 'el_subtype'
            , 'old_state', 'new_state', 'action', 'time', 'timestamp', 'dur', 'row_id'
            , 'expr_ascii', 'expr_x', 'expr_y', 'expr_width', 'expr_height', 'x', 'y'
            , 'sym_ascii', 'sym_x', 'sym_y', 'sym_width', 'sym_height', 'sel_ascii'
            , 'sel_x', 'sel_y', 'sel_width', 'sel_height', 'curr_state', 'next_state']
  , renamed = { old_state: 'initial_state', new_state: 'final_state' };

  // get custom event field names and add them to the fields array
  var custom_fields = getFieldNames(arrayOfEvents.filter(function(d) { return d.type === 'custom' }), ['_id']);
  fields = _.union(fields, custom_fields);
  on_progress(0.1);

  // get all trial field names
  var trial_fields = getFieldNames(arrayOfTrials, ['_id', 'id'])
                      .map(function(field) { return 'trial_' + field });
  fields = _.union(fields, trial_fields);
  on_progress(0.15);

  let problemMeasureFields;
  // sort by trial to determine the measures for each trial
  var trial_groups = d3.nest()
    .key(function(d) { return d.trial_id })
    .entries(arrayOfEvents);
  on_progress(0.2);
  var n = 0, N = arrayOfEvents.length;
  trial_groups.forEach(function(trial_group) {
    var trial = arrayOfTrials.find(t => t.id === trial_group.key);
    problemMeasureFields = saveDataMeasuresToTrial(trial_group.values, trial);
    on_progress(0.2 + n/N * 0.8);
  });

  // sort by users to identify any issues w/ data
  let problemGroups = d3.nest()
    .key(d => d.user_id)
    .key(d => d.problem_id)
    .entries(arrayOfTrials);
  problemGroups.forEach(function(user) {
    user.values.forEach(function(problem) {
      if (problem.values.length > 1) {
        console.warn('A user has multiple trials corresponding to one problem.');
      }
    });
  })
  
  const tracker = new ScheduleTracker();
  const aggregation = new Aggregation();
  arrayOfTrials.forEach(trial => {
    tracker.addTrial(trial);
    aggregation.aggregateTrial(trial, problemMeasureFields);
  });

  const assignment_groups = d3.nest()
    .key(d => d.assistments_user_id)
    .entries(arrayOfTrials);
  
  assignment_groups.forEach((user, idx) => {
    const rowMap = getStudentValues(user.key, aggregation, problemMeasureFields, tracker);
    if (idx === 0) {
      const headerRow = Array.from(rowMap.keys()).map(escapeForCSV).join(',');
      send_lines([headerRow]);
    }

    const dataRow = Array.from(rowMap.values()).map(escapeForCSV).join(',');
    send_lines([dataRow]);

  });
  postMessage('done');
}

function getFieldNames(dataArray, excludes) {
  var fields = d3.set();
  dataArray.forEach(function(data) {
    for (var key in data) fields.add(key);
  });
  return fields.values().filter(function(field) { return excludes.indexOf(field) === -1 });
}

function getCSVLinesFHtT(fields, data, trial) {
  if (!trial) {
    trial = {};
    on_error('Trial referenced by interaction is missing.');
  }
  var res = [];
  data.forEach(function(event) {
    var values = [];
    fields.forEach(function(field) { values.push(event[field] || trial[field] || null) });
    res.push(values.map(escapeForCSV).join(','));
  });
  return res;
}

function saveDataMeasuresToTrial(data, trial) {
  if (!trial) {
    trial = {};
    on_error('Trial referenced by interaction is missing.');
  }

  // Group by interaction so we can pass everything through the DLLogger decompress and sort method.
  let expandedData = [];
  const interactionGroups = d3.nest()
    .key(d => d.interaction_id)
    .entries(data);
  // sort interactions by time
  interactionGroups.sort((a, b) => a.values[0].time - b.values[0].time);

  // Do a bit of processing on the interactions, and put all the events into the same array.
  interactionGroups.forEach(function(group) {
    // Individual drag events have been reduced to a single document in the
    // collection, which contains an array of the successive positions.
    // Expand the compressed form so each drag position gets its own event.
    expandedData = expandedData.concat(DLLogger.decompressAndSortEvents(group.values));
  });

  if (expandedData[0].type === 'event') {
    // The first element in the sorted array should be type "interaction."
    on_error('missing missing interaction log entry');
  }

  let measures = new PMeasures(trial);
  data.forEach(datum => {
    measures.feed(datum);
  });
  let results = measures.getResults();

  let measureFields = [];
  results.forEach(function(result) {
    let label = 'p_measure_'+result.name;
    trial[label] = result.measure;
    measureFields.push(result.name);
  });

  return measureFields;
}

function runAssignmentDataMeasures(user, trials) {
  trials.sort(function(t1, t2) { return t1.problem_id - t2.problem_id });

  let measures = new AMeasures();
  trials.forEach(trial => {
    measures.feed(trial);
  });

  let results = measures.getResults();
  let measureResults = {
    user: user,
    assignmentId: trials[0].assignment_id,
  };
  results.forEach(function(result) {
    measureResults['w_measure_'+result.name] = result.measure;
  })
  return measureResults;
}
/**
function getCSVLinesForInteraction(fields, data, trial, include_trajectories, cross_interaction_fields) {
  if (!trial) {
    trial = {};
    on_error('Trial referenced by interaction is missing.');
  }
  var res = [];

  // An interaction summary precedes all the events (subtype "rewrite").
  var interaction_count = data.filter(function(d) { return d.type === 'interaction' }).length;
  if (interaction_count > 1) {
    // The data passed into this function is assumed to have been filtered by interaction
    // id, like when using the d3.nest tool.
    on_error('Inconsistent data: found ' + interaction_count + ' interactions '
               + 'with the same interaction_id.');
    on_error('Problematic data:');
    on_error(JSON.stringify(data));
    on_error('Only using the first one.');
    // Put the first summary at the start of the revised data selection.
    var new_data = [data[0]];
    // However, note that we are still taking all the events, even the ones
    // that appear after the "extra" interaction summaries.
    for (var i=1; i<data.length && data[i].type !== 'interaction'; i++) new_data.push(data[i]);
    data = new_data;
  }
  // Individual drag events have been reduced to a single document in the
  // collection, which contains an array of the successive positions.
  // Expand the compressed form so each drag position gets its own event.
  data = DLLogger.decompressAndSortEvents(data); // also sorts by wi_int_id
  if (data[0].type === 'event') {
    // The first element in the sorted array should be type "interaction."
    on_error('missing missing interaction log entry');
    // I don't think we're dropping anything? Why is this message here?
    on_error('dropping these events:');
    on_error(JSON.stringify(data));
  }
  var interaction = data[0]
    , next_math_event = getNextMathEvent(data, 0)
    , curr_info = { curr_state: interaction.old_state
                  , next_state: next_math_event.expr_ascii
                  , action: next_math_event.action
                  , ...cross_interaction_fields }
    , rest_dur = interaction.dur;

  // Construct the CSV.
  // Each event type stores a subset of the desired fields, but we want each
  // line in the CSV to contain all the latest values up until that point.
  // For example, only a few events record what the starting and final state
  // of each math action is, but we want that information in every row of that
  // interaction.
  data.forEach(function(event, i) {
    // Update the current info with the data from this event.
    curr_info = { ...curr_info, ...event };
    // If there was no transformation, set the new state as the old state.
    if (!curr_info.new_state) curr_info.new_state = curr_info.old_state;
    if (event.subtype === 'drag' && !include_trajectories) return;
    var values = [];
    fields.forEach(function(field) {
      if (field.indexOf('trial_') === 0) {
        values.push(trial[field.substr(6)]);
      } else if (event.type === 'event' && field == 'dur') {
        values.push(next_math_event.dur || rest_dur);
      } else if (event.type === 'interaction' && (field === 'curr_state' || field === 'next_state')) {
        values.push(null);
      } else {
        values.push(curr_info[field]);
      }
      if ((field in cross_interaction_fields) && (field in curr_info)) {
        cross_interaction_fields[field] = curr_info[field];
      }
    });

    // Add the collected values to the CSV.
    res.push(values.map(escapeForCSV).join(','));

    if (event.type === 'event' && (event.subtype == 'math' || event.subtype == 'scrub')) {
      rest_dur -= event.dur;
      curr_info.curr_state = event.expr_ascii;
      next_math_event = getNextMathEvent(data, i);
      curr_info.next_state = next_math_event.expr_ascii;
      curr_info.action = next_math_event.action;
    }
  });
  return res;
}
*/
// Events is assumed to be sorted by appearance in the interaction.
// Start is a position within the array, and the search for the next
// math event will start *after* that position.
function getNextMathEvent(events, start) {
  for (var i=start+1; i<events.length; i++) {
    var event = events[i];
    if ((event.subtype === 'math' || event.subtype === 'scrub')
      && event.type === 'event') return event;
  }
  return {};
}

/// Escapes quotation marks and puts quotes around data containing reserved characters.
function escapeForCSV(val) {
  if (val === null || val === undefined) return '';
  var res = val.toString().replace(/"/g, '""');
  if (res.search(/("|,|\n)/g) >= 0) res = '"' + res + '"';
  return res;
}

DLLogger = {
  decompressAndSortEvents(events) {
    const trajectoryIdx = events.findIndex(evt => evt.subtype === 'trajectory');
    if (trajectoryIdx >= 0) {
      const trajectory = events.splice(trajectoryIdx, 1)[0];
      let time = trajectory.time;
      for (let i=0; i<trajectory.dts.length; i++) {
        const event = {
          time: trajectory.dts[i] + time
        , x: trajectory.xs[i]
        , y: trajectory.ys[i]
        , trial_id: trajectory.trial_id
        , interaction_id: trajectory.interaction_id
        , within_interaction_id: trajectory.wi_int_ids[i]
        , type: 'event'
        , subtype: 'drag'
        };
        if (trajectory.sel_ascii && trajectory.sel_ascii[i]) event.sel_ascii = trajectory.sel_ascii[i];
        events.push(event);
        time += trajectory.dts[i];
      }
    }
    // sort by wi-int-id with interaction event first
    events.sort((a, b) => (a.within_interaction_id || -1) -
                          (b.within_interaction_id || -1));
    return events;
  }
}