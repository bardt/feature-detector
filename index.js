const express = require('express');
const bodyParser = require('body-parser');
const expressMongoDb = require('express-mongo-db');

const app = express();

app.set('port', (process.env.PORT || 5000));
app.set('view engine', 'ejs');

app.use(bodyParser.json());
app.use(express.static('public'));
app.use(expressMongoDb(process.env.MONGOLAB_URI || 'mongodb://localhost:27017/'));

app.get('/', (req, res) => {
  res.render('demo', function(err, html) {
    res.send(html);
  });
});

app.get('/stats', (req, res) => {
  const collection = req.db.collection('statistics');
  collection.mapReduce(
    function() {
      Object.keys(this.features).forEach((key, index) => {
        if (typeof this.features[key] === 'boolean') {
          emit(key, this.features[key]);
        }
      });
    },
    function(key, values) {
      return values.filter(value => !!value).length / value.length;
    },
    {
      query: { apiKey: 'demo' },
      out: 'stats_totals'
    },
    (err, collecton) => {
      if (err) {
        return res.sendStatus(500);
      }

      collection.find({ stats_totals: true }, (err, result) => {
        console.log(result);
        if (err) {
          return res.sendStatus(500);
        }
        res.sendStatus(200);
      });
    }
  );
});

app.post('/stats', (req, res) => {
  const collection = req.db.collection('statistics');
  const newRecord = Object.assign({}, req.body, {
    timestamp: new Date().getTime()
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
