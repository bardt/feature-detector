const express = require('express');
const bodyParser = require('body-parser');
const expressMongoDb = require('express-mongo-db');
const useragent = require('express-useragent');

const app = express();

const allowCrossDomain = (req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type');

    next();
}

app.set('port', (process.env.PORT || 5000));
app.set('view engine', 'ejs');

app.use(allowCrossDomain);
app.use(bodyParser.json());
app.use(express.static('public'));
app.use(useragent.express());
app.use(expressMongoDb(process.env.MONGOLAB_URI || 'mongodb://localhost:27017/'));

function getStats(db, apiKey, callback) {

  function mapper() {
    this.features.forEach(function(feature) {
      if (typeof feature.enabled === 'boolean') {
        // Simple
        emit(feature.name, { enabled: feature.enabled ? 1 : 0, total: 1 });
      } else {
        // Composite
        Object.keys(feature.enabled).forEach(function(subFeature) {
          const enabled = feature.enabled[subFeature];
          emit(feature.name + '.' + subFeature, { enabled: enabled ? 1 : 0, total: 1 });
        });
      }
    });
  }

  function reducer(key, values) {
    return values.reduce(function(acc, value, index) {
      return {
        enabled: acc.enabled + value.enabled,
        total: acc.total + value.total
      };
    }, { enabled: 0, total: 0 });
  }

  const collection = db.collection('statistics');
  collection.mapReduce(mapper, reducer, {
    query: { apiKey: apiKey },
    out: { inline: 1 }
  }, (err, stats) => {
    if (err) {
      return callback(err, []);
    }

    const out = stats.map(statsItem => Object.assign({}, statsItem.value, {
      feature: statsItem._id,
    }));
    callback(err, out);
  });
}

app.get('/', (req, res) => {
  getStats(req.db, 'demo', (err, stats) => {
    if (err) {
      return res.sendStatus(500);
    }

    function countPercentage(statObject) {
      const enabled = statObject.enabled;
      const total = statObject.total;
      return Math.floor(enabled / total * 1000) / 10;
    }

    function addPercentage(statObject) {
      return Object.assign({}, statObject, {
        percentage: countPercentage(statObject)
      });
    };

    const statsView = stats
      .filter(statItem => !!statItem.total)
      .map(addPercentage);

    res.render('demo', { stats: statsView }, function(err, html) {
      res.send(html);
    });
  });

});

app.get('/stats', (req, res) => {
  getStats(req.db, 'demo', (err, stats) => {
    if (err) {
      console.log(err);
      return res.sendStatus(500);
    }

    res.status(200).send(stats);
  });
});

app.post('/stats', (req, res) => {
  const collection = req.db.collection('statistics');
  const newRecord = Object.assign({}, req.body, {
    timestamp: new Date().getTime(),
    // More info about browser (from express-useragent)
    browser: req.useragent
  });
  collection.insert(newRecord, (err, result) => {
    if (err) {
      res.sendStatus(500);
    } else {
      res.sendStatus(200);
    }
  });
});

app.listen(app.get('port'), () => {
  console.log('Node app is running on port', app.get('port'));
});
