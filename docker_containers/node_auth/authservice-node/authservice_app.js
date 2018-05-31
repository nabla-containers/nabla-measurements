/*******************************************************************************
 * Copyright (c) 2015 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/

// This is needed as rumprun starts with cwd=/
process.chdir(__dirname)

var fs = require('fs');
var settings = JSON.parse(fs.readFileSync('settings.json', 'utf8'));

var express = require('express');
var bodyParser = require('body-parser');
var methodOverride = require('method-override');
var cookieParser = require('cookie-parser')

var app = express(); 				
var router = express.Router();
var jsonParser = bodyParser.json();//create application/json parser
var urlencodedParser = bodyParser.urlencoded({ extended: false });//create application/x-www-form-urlencoded parser

var  log4js = require('log4js');
log4js.configure('log4js.json', {});
var logger = log4js.getLogger('authservice_app');
logger.setLevel(settings.loggerLevel);

var morgan = require('morgan');
if (settings.useDevLogger)
	app.use(morgan('dev'));// log every request to the console
app.use(jsonParser);
app.use(urlencodedParser);
app.use(bodyParser.text({ type: 'text/html' }));//parse an HTML body into a string
app.use(methodOverride());// simulate DELETE and PUT
app.use(cookieParser());// parse cookie

var port = (process.env.PORT || process.env.VCAP_APP_PORT || settings.authservice_port);
var dbtype = process.env.dbtype || "mongo";
var routes = new require('./authservice/routes/index.js')(dbtype, settings); 
var initialized = false;
var serverStarted = false;

logger.info("port==" + port);
logger.info("db type==" + dbtype);

router.get('/', checkStatus);
router.post('/login', routes.login);
router.get('/service', serviceName);
router.get('/config/runtime', routes.getRuntimeInfo);

//REGISTER OUR ROUTES so that all of routes will have prefix 
app.use(settings.authContextRoot, router);

startServer();

function startServer() {
	if (serverStarted ) return;
	serverStarted = true;
	app.listen(port);
	console.log('Application started port ' + port);
}

function checkStatus(req, res){
	res.status(200).send('OK');
}

function serviceName(req, res){
	res.status(200).send('Auth Service');
}
