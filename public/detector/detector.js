(function() {
  function getFeatures() {
    var features = [];
    if (typeof Modernizr !== 'undefined') {
      for (key in Modernizr) {
        if (Modernizr.hasOwnProperty(key)) {
          if (key.toString()[0] !== '_') {
            if (typeof Modernizr[key] !== 'function') {
              features.push({
                name: key,
                enabled: Modernizr[key]
              });
            }
          }
        }
      }
    }
    return features;
  }

  function sendStats(features) {
    var data = {
      apiKey: 'demo',
      features: features
    };

    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/stats', true);
    xhr.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');

    // send the collected data as JSON
    xhr.send(JSON.stringify(data));

    xhr.onloadend = function() {
      console.info('Done sending stats');
    };
  }

  sendStats(getFeatures());
})();
