(function(Modernizr) {
  function getFeatures() {
    if (typeof Modernizr === 'undefined') return;

    function isBlackListed(key) {
      return !Modernizr.hasOwnProperty(key) ||
        key.toString()[0] === '_' ||
        typeof Modernizr[key] === 'function';
    }

    var features = [];
    for (key in Modernizr) {
      if (!isBlackListed(key)) {
        features.push({
          name: key,
          enabled: Modernizr[key]
        });
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
})(window.Modernizr);
