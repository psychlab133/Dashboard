var is_working = false;

// Base function for sending a request to the logging server.
function queryLogger(requestMethod, route, body, callback, error_callback) {
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4 && xhr.status === 200) {
      if (callback) callback(xhr.responseText);
    }
  }
  // SERVER_API is a global that is defined in the "onchange" handler of the
  // server select form (see the index page).
  xhr.open(requestMethod, SERVER_API + route, true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.send(body ? JSON.stringify(body) : null);
}

// Parses the response text to JSON from the server before executing the callback.
function queryLoggerParsed(requestMethod, route, body, callback, error_callback) {
  queryLogger(requestMethod, route, body, function(json) {
    if (callback) {
      var data;
      try { data = JSON.parse(json) }
      catch (err) { if (error_callback) error_callback(err); return }
      callback(data);
    }
  }, error_callback);
}

// Performs the query in chunks.
function queryLoggerPaginatedParsed(requestMethod, route, progress_cb, done_callback, error_callback) {
  var skip = 0, data = [], finished = false;

  function query() {
    if (skip > 0) progress_cb(skip);
    var route2 = route + (route.indexOf('?') === -1 ? '?skip=' : '&skip=') + skip;
    queryLoggerParsed(requestMethod, route2, null
      , function onDone(res) {
        data = data.concat(res.data);
        skip += res.data.length;
        if (res.complete) done_callback(data);
        else query();
    }, error_callback);
  }
  query();
}

// helper function, converts Date into yyyy-mm-dd date format
function toYMD(timestamp) { return timestamp.toISOString().substring(0, 10); }

function showProgress(val) {
  if (typeof val === 'number') progress_span.text(val + '%');
  else progress_span.text(val);
}

// Called when the server option is selected in the menu. Queries for known
// experiments and sets up event listeners for the various DL options.
function init() {

  progress_span = d3.select('span#progress');
  var experiment = null
    , experiments = null
    // Select form for choosing a known experiment
    , experiments_sel = d3.select('#experiments')
    // Text input for adding a new experiment
    , id_sel = d3.select('#id')
    // Text areas for displaying experiment information
    , fields = ['name', 'description', 'experimentors', 'contact', 'fields', 'created', 'updated']
    , fields_sels = []
    // Buttons for modifying experiments
    , create_exp_sel = d3.select('#create-experiment')
    , update_exp_sel = d3.select('#update-experiment')
    // Date inputs for setting bredth of query
    , start_sel = d3.select('#start')
    , end_sel = d3.select('#end')
    // Download buttons
    , dl_trials_sel = d3.select('#download-trials')
    , dl_data_and_trials_sel = d3.select('#download-data')
    , dl_data_csv_sel = d3.select('#download-data-csv')
    , dl_data_trajectries_csv_sel = d3.select('#download-data-trajectories-csv')
    , dl_fh2t_data_sel = d3.select('#download-fh2t-data');

  resetAllExperimentInputForms();
  resetNewExperimentIDInputField();

  alert("GET");
  // add existing experiments to the experiment selection input
  queryLoggerParsed('GET', 'experiments', null, function(expts) {
    experiments = expts;
    for (var i = 0; i < experiments.length; i++) {
      experiments_sel.append('option')
        .html(experiments[i].id);
    }
    experiments_sel.property('selectedIndex', -1);
    experiments_sel.on('change', function() {
        experiment = experiments[experiments_sel.property('selectedIndex')];
        fillFieldsWithExperimentInfo();
        resetNewExperimentIDInputField();
        setCreatable(false);
        setUpdatable(false);
      });
    function checkValidID(id) {
      for (var i = 0; i < experiments.length; i++) {
        if (experiments[i].id == id) return false;
      }
      return true;
    }
    var input = false;
    id_sel.on('input', function() {
        if (!input) {
          if (experiment) {
            experiments_sel.property('selectedIndex', -1);
            experiment = null;
            fillFieldsWithExperimentInfo();
          }
          input = true;
        }
        var valid_id = checkValidID(id_sel.property('value'));
        id_sel.style('color', valid_id ? 'black' : 'red');
        setCreatable(valid_id);
      })
      .on('blur', function() {
        input = false;
        if (id_sel.property('value') == '') resetNewExperimentIDInputField();
      });
  });

  fields.forEach(function(field) {
    fields_sels.push(d3.select('#' + field));
  });

  fields_sels.forEach(function(field_sel, i) {
    field_sel.on('blur', function() {
      if (experiment && this.value != experiment[fields[i]]) setUpdatable(true);
    });
  });

  create_exp_sel.on('click', function() {
    d3.select('#created').property('value', new Date().toString());
    experiment = fieldsToReqBody(id_sel.property('value'));
    experiments.push(experiment);
    experiments_sel.append('option')
        .html(experiment.id);
    experiments_sel.property('selectedIndex', experiments_sel.property('options').length - 1);
    resetNewExperimentIDInputField();
    setCreatable(false);
    queryLoggerParsed('POST', 'experiments', experiment);
  });

  update_exp_sel.on('click', function() {
    d3.select('#updated').property('value', new Date().toString());
    var idx = experiments.indexOf(experiment);
    experiments[idx] = fieldsToReqBody(experiment.id);
    experiment = experiments[idx];
    setUpdatable(false);
    queryLoggerParsed('PUT', 'experiments/' + experiment.id, experiment);
  });

  start_sel.on('change', updateCounts);

  end_sel.on('change', updateCounts);

  dl_trials_sel.on('click', function() {
    showProgress('loading from server...');
    queryLoggerPaginatedParsed('GET', 'data/' + experiment.id + '_trials' + getInterval()
    , function onProgress(N) { showProgress(N + ' trials') }
    , function onDone(trials) { downloadJSON(trials, null, experiment.id+'_trials') }
    , function onError(error) { debugger; showProgress('Error: ' + error)
    }
    );
  });

  dl_data_and_trials_sel.on('click', function() {
    getTrialsAndEvents(function(trials, data) {
      downloadJSON(trials, data, experiment.id+'_trials_and_data')
    });
  });

  dl_data_csv_sel.on('click', function() {
    getTrialsAndEvents(function(trials, data) {
      downloadCSV(data, experiment.id+'_data', false, trials,(experiment.id.indexOf("FHtT") === 0));
    });
  });

  dl_data_trajectries_csv_sel.on('click', function() {
    getTrialsAndEvents(function(trials, data) {
      downloadCSV(data, experiment.id+'_data-full', true, trials,(experiment.id.indexOf("FHtT") === 0));
    });
  });

  dl_fh2t_data_sel.on('click', function() {
    getTrialsAndEvents(function(trials, data) {
      downloadCSV(data, experiment.id+'_aggregation_table', true, trials, true);
    });
  });

  function getTrialsAndEvents(callback) {
    showProgress('loading from server...');
    queryLoggerPaginatedParsed('GET', 'data/' + experiment.id + '_trials' + getInterval()
      , function onProgress(N) { showProgress(N + ' trials') }
      , function onDone(trials) {
        queryLoggerPaginatedParsed('GET', 'data/' + experiment.id + '_data' + getInterval()
          , function onProgress(N) { showProgress(N + ' events') }
          , function onDone(data) { callback(trials, data) }
          , function onError(error) { debugger; showProgress('Error: ' + error) }
        );
      }
      , function onError(error) { debugger; showProgress('Error: ' + error) }
    );
  }

  function downloadCSV(arrayOfEvents, filename, include_trajectories, arrayOfTrials, isFHtT) {
    if (is_working) {
      alert('Already processing a download!')
      return;
    }
    is_working = true;
    showProgress(30);
    var worker = getWorker()
      , csv_lines = [];
    worker.postMessage({ cmd: 'csv', arrayOfEvents: arrayOfEvents, filename: filename
                       , include_trajectories: include_trajectories
                       , arrayOfTrials: arrayOfTrials, isFHtT: isFHtT });
    worker.onmessage = function(msg) {
      if (msg.data === 'done') {
        showProgress('saving...');
        var blob = new Blob(csv_lines, { type: 'text/csv' });
        saveAs(blob, filename + '.csv');
        showProgress('done');
        is_working = false;
      } else {
        if (msg.data.lines) msg.data.lines.forEach(function(line) { csv_lines.push(line + '\r\n') });
        if (msg.data.progress || msg.data.progress === 0) showProgress(30+Math.round(70*msg.data.progress));
        if (msg.data.error) addError(msg.data.error);
      }
    };
  }

  function downloadJSON(trials, data, filename) {
    showProgress('saving...');
    var parts = ['{"trials":['];
    if (trials) {
      var N = trials.length;
      trials.forEach(function(trial, i) { parts.push(JSON.stringify(trial) + (i<N-1 ? ',' : '')) });
    }
    parts.push('],"data":[');
    if (data) {
      var N = data.length;
      data.forEach(function(d, i) { parts.push(JSON.stringify(d) + (i<N-1 ? ',' : '')) });
    }
    parts.push(']}');
    var blob = new Blob(parts, { type: 'application/json' });
    saveAs(blob, filename + '.json');
    showProgress('done');
  }

  function getWorker() {
    if (!window.gm_worker) {
      window.gm_worker = new Worker('db-export-worker.js');
    }
    return window.gm_worker;
  }

  function resetNewExperimentIDInputField() {
    id_sel.property('value', 'ID')
      .style('color', 'silver');
  }

  function setCreatable(bool) { create_exp_sel.attr('disabled', bool ? null : true); }

  function setUpdatable(bool) { update_exp_sel.attr('disabled', bool ? null: true); }

  function getInterval() {
    var res = [];
    var start = start_sel.property('value');
    if (start !== "") {
      res.push('start=' + new Date(start).toISOString());
    }
    var end = end_sel.property('value');
    if (end !== "") {
      var end_t = new Date(end);
      end_t.setDate(end_t.getDate() + 1); // increment by one day to include the specified day
      res.push('end=' + end_t.toISOString());
    }

    if (res.length === 0) return '';
    return '?' + res.join('&');
  }

  function setTrialsDownloadable(bool) { dl_trials_sel.attr('disabled', bool ? null : true); }

  function setDataDownloadable(bool) {
    dl_data_and_trials_sel.attr('disabled', bool ? null : true);
    dl_data_csv_sel.attr('disabled', bool ? null : true);
    dl_data_trajectries_csv_sel.attr('disabled', bool ? null : true);
    dl_fh2t_data_sel.attr('disabled', bool ? null : true);
  }

  function resetAllExperimentInputForms() {
    experiments_sel.selectAll('*').remove();
    fillFieldsWithExperimentInfo();
  }

  function fillFieldsWithExperimentInfo() {
    for (var i = 0; i < fields_sels.length; i++) {
      fields_sels[i].property('value', experiment ? experiment[fields[i]] : '');
    }
    function callback(interval) {
      start_sel.property('value', interval.start ? toYMD(new Date(interval.start)) : '');
      end_sel.property('value', interval.end ? toYMD(new Date(interval.end)) : '');
      updateCounts();
    }
    function on_error() {
      start_sel.property('value', null);
      end_sel.property('value', null);
      updateCounts();
    }
    if (experiment) queryLoggerParsed('GET', 'summary/interval/' + experiment.id, null, callback, on_error);
    else callback({});
  }

  function fieldsToReqBody(id) {
    var body = { id: id };
    fields_sels.forEach(function(field_sel, i) {
      body[fields[i]] = field_sel.property('value');
    });
    return body;
  }

  function updateCounts() {
    function callback(counts) {
      d3.select('#trials').html(counts.trial || 0);
      d3.select('#interactions').html(counts.interaction || 0);
      d3.select('#events').html(counts.event || 0);
      d3.select('#custom').html(counts.custom || 0)
      setTrialsDownloadable(counts.trial > 0);
      setDataDownloadable((counts.interaction||0) + (counts.event||0) + (counts.custom||0) > 0);
    }
    if (experiment) queryLoggerParsed('GET', 'summary/counts/' + experiment.id + getInterval(), null, callback);
    else callback({});
  }

  var textarea = d3.select('#warnings').node();

  function addError(msg) {
    textarea.value = textarea.value + "\n" + msg;
  }
}
