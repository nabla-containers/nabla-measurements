/*******************************************************************************
 * Copyright (c) 2015 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/

module.exports = function (dbtype, settings) {
	var module = {};
	var log4js = require('log4js');
	var jwt = require('jsonwebtoken');
	var debug = require('debug')('auth');

	var secretKey = "acmeairsecret128";
	log4js.configure('log4js.json', {});
	var logger = log4js.getLogger('authservice');
	logger.setLevel(settings.loggerLevel);

	// customer service setup code ****
	var http = require('http');

	// Place holder for service registry/discovery code
	var location = process.env.CUSTOMER_SERVICE || "localhost:9081";
	var host;
	var post;
	var customerContextRoot;

	if (location.indexOf(":") > -1) {
		var split1 = location.split(":");
		host=split1[0];

		var split2 = split1[1].split("/");
		port = split2[0];
		customerContextRoot = '/' + split2[1];
	} else {
		var split1 = location.split("/");
		host=split1[0];
		customerContextRoot = '/' + split1[1];
		port=80;
	}

	var path = '/validateid';
	if (customerContextRoot == '/undefined'){
		customerContextRoot = path;
	}else {
		customerContextRoot = customerContextRoot + path;
	}

//	*****

	module.login = function(req, res) {

		var login = req.body.login;
		var password = req.body.password;

		validateCustomer(login, password, function(err, customerValid) {
			if (err) {
				res.status(500).send(err); // TODO: do I really need this or is there a cleaner way??
				return;
			}

			if (!customerValid) {
				res.sendStatus(403);
			}
			else {
				res.cookie('jwt_token', jwt.sign({sub:login}, secretKey, { algorithm: 'HS256' }));
				res.cookie('loggedinuser', login);
				res.send('logged in');
			}
		});
	};
	
	module.getRuntimeInfo = function(req,res) {
		var runtimeInfo = [];
		runtimeInfo.push({"name":"Runtime","description":"NodeJS"});
		var versions = process.versions;
		for (var key in versions) {
			runtimeInfo.push({"name":key,"description":versions[key]});
		}
		res.contentType('application/json');
		res.send(JSON.stringify(runtimeInfo));
	};

	validateCustomer = function(login, password, callback) {
		// make service call to customerService
		http.globalAgent.keepAlive = true;
		var querystring = require('querystring');
		var dataString = querystring.stringify({
			login: login,
			password: password
		});

		logger.debug("Sending to: " + "http://" + host + ":" + port + customerContextRoot);

		var options = {
				host: host,
				port: port,
				path: customerContextRoot,
				method: 'POST',
				headers: {
					'Content-Type': 'application/x-www-form-urlencoded',
					'Content-Length': Buffer.byteLength(dataString)
				}
		};

		var request = http.request(options, function(response){
			var data='';
			response.setEncoding('utf8');
			response.on('data', function (chunk) {
				data +=chunk;
			});
			response.on('end', function(){
				if (response.statusCode>=400)
					callback("StatusCode:"+ response.statusCode+",Body:"+data, null);
				else{
					var jsonData = JSON.parse(data);
					logger.debug("returning " + jsonData.validCustomer);
					callback(null, jsonData.validCustomer);
				}
			})
		});
		request.on('error', function(e) {
			callback("StatusCode:500,Body:"+data, null);
		});

		request.write(dataString);
		request.end();		
	}

	return module;
}