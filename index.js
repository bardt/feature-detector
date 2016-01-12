const express = require('express');
const bodyParser = require('body-parser');

const app = express();

app.set('port', (process.env.PORT || 5000));
app.set('view engine', 'ejs')

app.use(bodyParser.json());
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.render('demo', function(err, html) {
    res.send(html);
  });
});

app.post('/stats', (req, res) => {
  console.log('Request approved');
  console.log(req.body);
  res.sendStatus(200);
});

app.listen(app.get('port'), () => {
  console.log('Node app is running on port', app.get('port'));
});
