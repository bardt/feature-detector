const express = require('express');
const bodyParser = require('body-parser');
const MongoClient = require('mongodb').MongoClient;

const app = express();

app.set('port', (process.env.PORT || 5000));
app.set('mongoConnectionString', process.env.MONGOLAB_URI);
app.set('view engine', 'ejs')

app.use(bodyParser.json());
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.render('demo', function(err, html) {
    res.send(html);
  });
});

app.post('/stats', (req, res) => {
  MongoClient.connect(app.get('mongoConnectionString'), function(err, db) {
    db.close();
  });
});

app.listen(app.get('port'), () => {
  console.log('Node app is running on port', app.get('port'));
});
