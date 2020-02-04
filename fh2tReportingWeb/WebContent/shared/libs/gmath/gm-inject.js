/* Options:
 *   - version (no default, need to specify)
 *   - basePath (default is 'https://graspablemath.com/')
 *   - excludePatterns (default is [])
 *   - canvas_css_version (default is 0, set to force refresh)
 *   - build (default is '')
 */
var loadGM = function(callback, options) {
  if (!options) options = {};
  if (!options.basePath) options.basePath = 'https://graspablemath.com';
  if (!options.excludePatterns) options.excludePatterns = [];
  if (!options.canvas_css_version) options.canvas_css_version = '0';
  if (!options.build) options.build = '';
  var loadScripts = function(urls, callback) {
    var filtered_urls = urls.filter(excludeFilter);
    var number_of_scripts = filtered_urls.length;
    filtered_urls.forEach(function(src, idx) {
      var script = document.createElement('script');
      script.type = "text/javascript";

      if (callback && (idx === number_of_scripts - 1)) {
        if (script.readyState){  //IE
          script.onreadystatechange = function(){
            if (script.readyState == "loaded" ||
              script.readyState == "complete"){
              script.onreadystatechange = null;
              if (callback) callback();
            }
          };
        } else {  //Others
          script.onload = function(){
            if (callback) callback();
          };
        }
      }

      script.src = src;
      script.async = false;
      document.head.appendChild(script);
    });
  }

  var loadCSS = function(urls) {
    urls.filter(excludeFilter)
      .forEach(function(url) {
        var link = document.createElement("link")
        link.rel = "stylesheet";
        link.href = url;
        document.getElementsByTagName("head")[0].appendChild(link);
      });
  }

  function excludeFilter(url) {
    return options.excludePatterns.every(function(ex) {
      return url.indexOf(ex) === -1;
    });
  }

  function versionCompare(v1, v2) {
    if (v1 === 'latest' || v1 === '' || !v1) return 1;
    var v1parts = v1.split('.')
      , v2parts = v2.split('.');

    var isValid = function(str) { return /^\d+$/.test(str) }

    if (!v1parts.every(isValid) || !v2parts.every(isValid)) return NaN;

    while (v1parts.length < v2parts.length) v1parts.push("0");
    while (v2parts.length < v1parts.length) v2parts.push("0");

    v1parts = v1parts.map(Number);
    v2parts = v2parts.map(Number);

    for (var i = 0; i < v1parts.length; ++i) {
        if (v1parts[i] > v2parts[i]) return 1;
        if (v1parts[i] < v2parts[i]) return -1;
    }

    return 0;
  }

  function getVersionStr(str) {
    if (!str) return '';
    if (str.match("[0-9]+\\.[0-9]+\\.[0-9]")) {
      return '-' + str;
    } else if (str === 'latest') {
      return '';
    } else {
      console.warn('Unsupported verson string format: "' + version_str + '".');
      console.info('Loading the latest version of Graspable Math.');
      return '';
    }
  }

  var core_version = options.core_version || options.version || 'latest'
    , core_version_str = getVersionStr(core_version)
    , ui_version = options.ui_version || 'latest'
    , ui_version_str = getVersionStr(ui_version);

  function on_loaded() {
    gmath.ui.resource_path = options.basePath + '/shared/';
    console.info('Loaded gmath v' + gmath.version + '.');
    if (gmath.ui && gmath.ui.version) {
      console.info('Loaded gmath-canvas v' + gmath.ui.version + '.');
    }
    if (options && options.loadScripts) loadScripts(options.loadScripts, callback);
    else if (callback) callback();
  }

  // before 0.10.0, load gmath-canvas.min.js as a separate library
  if (versionCompare(core_version, '0.10.0') === -1) {
    loadCSS( [ options.basePath + "/shared/fonts/fonts.css"
           , options.basePath + "/shared/css/canvas.css"
           , options.basePath + "/shared/libs/bootstrap-3.3.4-dist/css/bootstrap.min.css"
           , options.basePath + "/shared/libs/bootstrap-3.3.4-dist/css/no-btn-focus.css"
           , options.basePath + "/shared/libs/mathquill/mathquill.css" ] );
    loadScripts( [ options.basePath + "/shared/libs/d3/d3.min.js"
               , options.basePath + "/shared/libs/geom.js/geom-partial.min.js"
               , options.basePath + "/shared/libs/gmath/gmath"+core_version_str+".min.js"
               , options.basePath + "/shared/libs/gmath/gmath-canvas"+ui_version_str+".min.js"
               , options.basePath + "/shared/libs/jquery/jquery-2.1.0.min.js"
               , options.basePath + "/shared/libs/mathquill/mathquill.min.js"
               , options.basePath + "/shared/libs/algebrite/algebrite.min.js"
               , options.basePath + "/shared/libs/bootstrap-3.3.4-dist/js/bootstrap.min.js" ]
             , on_loaded);
  }
  // before 0.11.0, load geom, algebrite & mathquill separately
  else if (versionCompare(core_version, '0.11.0') === -1) { // version prior to 0.11.0
    loadCSS( [ options.basePath + "/shared/fonts/fonts.css"
           , options.basePath + "/shared/css/canvas.css"
           , options.basePath + "/shared/libs/bootstrap-3.3.4-dist/css/bootstrap.min.css"
           , options.basePath + "/shared/libs/bootstrap-3.3.4-dist/css/no-btn-focus.css"
           , options.basePath + "/shared/libs/mathquill/mathquill.css" ] );
    loadScripts( [ options.basePath + "/shared/libs/d3/d3.min.js"
               , options.basePath + "/shared/libs/geom.js/geom-partial.min.js"
               , options.basePath + "/shared/libs/gmath/gmath"+core_version_str+".min.js"
               , options.basePath + "/shared/libs/jquery/jquery-2.1.0.min.js"
               , options.basePath + "/shared/libs/mathquill/mathquill.min.js"
               , options.basePath + "/shared/libs/algebrite/algebrite.min.js"
               , options.basePath + "/shared/libs/bootstrap-3.3.4-dist/js/bootstrap.min.js" ]
             , on_loaded);
  }
  // starting with version 0.11.0, geom, algebrite & mathquill are in the package
  else if (versionCompare(core_version, '2.7.0') === -1) {
    if (core_version === 'latest') core_version = '';
    loadCSS([ options.basePath + "/shared/fonts/fonts.css"
            , options.basePath + "/shared/css/canvas.css?ver=" + options.canvas_css_version
            , options.basePath + "/shared/libs/bootstrap-3.3.7-dist/css/bootstrap.min.css"
            , options.basePath + "/shared/libs/bootstrap-3.3.7-dist/css/no-btn-focus.css"
            ]);
    var scripts = [ options.basePath + "/shared/libs/d3/d3.min.js"
                  , options.basePath + "/shared/libs/jquery/jquery-3.1.0.min.js"
                  , options.basePath + "/shared/libs/bootstrap-3.3.7-dist/js/bootstrap.min.js" ];
    // starting with version 2.6.0, we use google api for login
    if (core_version === '' || versionCompare(core_version, '2.6.0') >= 0) {
      scripts.push('https://apis.google.com/js/platform.js');
    }
    loadScripts(scripts, function() {
                  loadScripts( [options.basePath + "/shared/libs/gmath/gmath"+core_version_str+".min.js"]
                             , on_loaded);
               });
  }
  else {
    function loadGmathScript() {
      var build_str = options.build == '' ? '' : '+'+options.build;
      console.log('loading gm script', options.basePath + "/shared/libs/gmath-dist/gmath"+core_version_str+build_str+".min.js");
      loadScripts([options.basePath + "/shared/libs/gmath-dist/gmath"+core_version_str+build_str+".min.js"], on_loaded);
    }
    if (options.build !== 'ggb') {
      loadScripts(['https://apis.google.com/js/platform.js'], loadGmathScript);
    }
    else loadGmathScript();
  }
}

/** Options:
*   - version (default is "latest")
*   - containerSelector ('body' is the default, will append an iframe with gm into the container)
*   - canvasSettings JS object with canvas settings
*/
loadGMInIframe = function(callback, options) {
  var opts = options || {};
  var domain = 'https://graspablemath.com';
  var container = document.querySelector(opts.containerSelector || 'body');
  var version = opts.version || 'latest';
  var iframe = document.createElement('iframe');
  iframe.src = domain + "/canvas/embed?version=" + encodeURI(version)
                      + "&parent_url=" + encodeURI(window.location.href)
                      + "&options=" + encodeURI(JSON.stringify(options.canvasSettings || {}));
  iframe.setAttribute('width', '100%');
  iframe.setAttribute('height', '100%');
  container.append(iframe);
  return ExternalApi(iframe, domain, callback);
}

ExternalApi = function(iframe, domain, onLoadCallback) {
  var msg_id = 0;
  var iframeContent = null;
  var msg_queue = [];
  var listeners = []; // { fn, type }
  
  var sendMessage = function(data) {
    return new Promise(function(resolve, fail) {
      var id = msg_id++;
      data.gmm_id = id;
      iframeContent.postMessage(data, domain);
      msg_queue.push({id: id, resolve: resolve, fail: fail});
    });
  }

  var processEvent = function(data) {
    for (var i=0; i<listeners.length; i++) {
      if (listeners[i].type === data.eventType) listeners[i].fn(data.result);
    }
  }
  
  var processCommandResponse = function(data) {
    var msg = undefined;
    for (var i=0; i<msg_queue.length; i++) {
      if (data.gmm_id === msg_queue[i].id) {
        msg = msg_queue.splice(i, 1)[0];
        break;
      }
    }
    if (!msg) return;
    if (data.error) msg.fail(data.error);
    else msg.resolve(data.result);
  }

  var receiveMessage = function(event) {
    if (event.origin !== domain) return;
    if ((typeof event.data !== 'object') || !('gmm_id' in event.data)) return;
    if (event.data.is_event) processEvent(event.data);
    else processCommandResponse(event.data);
  }
  var core = {};
  var ping_timer;
  
  var onFrameLoaded = function() {
    iframeContent = iframe.contentWindow;
    if (onLoadCallback) { // wait until the externalAPI is initialized inside the iFrame
      ping_timer = setInterval(function() {
        sendMessage({ command: 'ping' }).then(function() {
          clearInterval(ping_timer);
          if (onLoadCallback) onLoadCallback(core);
          onLoadCallback = null;
        })
      }, 250);
    }
  }
  
  window.addEventListener('message', receiveMessage);
  iframe.addEventListener('load', onFrameLoaded);
  
  core.addEventListener = function(eventType, fn) {
    listeners.push({ type: eventType, fn: fn });
    return sendMessage({ command: 'listen', eventType: eventType });
  }

  core.removeEventListener = function(fn) {
    listeners = listeners.filter(function(listener) { return listener.fn !== fn });
  }

  core.getAsJSON = function() {
    return sendMessage({ command: 'getAsJSON' });
  }
  
  core.loadFromJSON = function(json) {
    return sendMessage({ command: 'loadFromJSON', args: { json: json } });
  }

  core.undo = function() {
    return sendMessage({ command: 'undo' });
  }

  core.redo = function() {
    return sendMessage({ command: 'redo' });
  }
  
  return core;
}
