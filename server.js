var schedule = require('node-schedule');
var request = require('request');
var express = require('express');
var cache = require('memory-cache');

var API_KEY = 'd528f800XXXXXXXXXXXXXXX';

function get_melbourne_weather() {
    console.log('about to invoke weather service');

    // openweathermap api url to hit
    var url = 'http://api.openweathermap.org/data/2.5/weather?q=Melbourne,AU&units=metric&APPID='+API_KEY;

    // invoke openweathermap api
    request.post(
        url,
        function (error, response, body) { // post invoke processing with response body
        if (!error && response.statusCode == 200) {      // successfully processed
            console.log('invoked weather service at '+ new Date());

            // store weather json object
            cache.put('melbourne', body);
        }
        // if error occurred, record HTTP status code
        console.log('response status: '+ response.statusCode);
    });

}

// run schedule every 2 hours, as api is refreshed every 2 hours
//schedule.scheduleJob('0 0 */2 * * *', get_melbourne_weather);

// run schedule every 5 secs – FOR TESTING ONLY
schedule.scheduleJob('*/5 * * * * *', get_melbourne_weather);

// schedule once on startup in case api is invoked in first 2 hours
schedule.scheduleJob(new Date(Date.now() + 500), get_melbourne_weather);

// initialize express application
var app = express();
var LISTEN_PORT = process.env.PORT || 48484;

// start listening on port
app.listen(LISTEN_PORT);

// root to document micro service
app.get(
    '/',
    function(req, res) {
      res.send('Melbourne Weather API: <p>GET /weather/melbourne to get the current weather');
    }
);

// get current weather for melbourne from cache.
app.get(
    '/weather/melbourne',
    function(req, res) {
      if(cache.size() != 1) return res.sendStatus(503);// service unavailable temporarily, try again later

      res.set('Content-Type', 'application/json');
      res.send(cache.get('melbourne'));
    }

);
