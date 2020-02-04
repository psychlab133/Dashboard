var loadGM = function(callback, options) {
  var loadScripts = function(urls, callback) {
    var number_of_scripts = urls.length;
    urls.forEach(function(src, idx) {
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
    urls.forEach(function(url) {
      var link = document.createElement("link")
      link.rel = "stylesheet";
      link.href = url;
      document.getElementsByTagName("head")[0].appendChild(link);
    });
  }

  function versionCompare(v1, v2) {
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
          if (v1parts[i] > v2parts[i]) return -1;
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

  var core_version_str = getVersionStr(options && options.core_version);
  var ui_version_str = getVersionStr(options && options.ui_version);

  loadCSS( [ "../shared/fonts/fonts.css"
           , "../shared/css/canvas.css"
           , "../shared/libs/bootstrap-3.3.4-dist/css/bootstrap.min.css"
           , "../shared/libs/bootstrap-3.3.4-dist/css/no-btn-focus.css"
           , "../shared/libs/mathquill/mathquill.css" ] );
  loadScripts( [ "../shared/libs/d3/d3.min.js"
               , "../shared/libs/geom.js/geom-partial.min.js"
               , "../shared/libs/gmath/gmath"+core_version_str+".min.js"
               , "../shared/libs/gmath/gmath-canvas"+ui_version_str+".min.js"
               , "../shared/libs/jquery/jquery-2.1.0.min.js"
               , "../shared/libs/mathquill/mathquill.min.js" ]
             , function() {
                console.info('Loaded Graspable Math core v' + gmath.version + '.');
                console.info('Loaded Graspable Math ui v' + gmath.ui.version + '.');
                if (options && options.loadScripts) loadScripts(options.loadScripts, callback);
                else if (callback) callback();
               } );
}
