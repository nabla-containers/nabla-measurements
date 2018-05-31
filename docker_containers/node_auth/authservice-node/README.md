## Acme Air Auth Service - Node.js

An implementation of the Acme Air Auth Service for NodeJS. The primary task of the auth service is to validate user ID and generate JSON Web Tokens (JWT).

This implementation can support running on a variety of runtime platforms including standalone bare metal system, Virtual Machines, docker containers, IBM Bluemix, IBM Bluemix Container Service.

Use Bluemix_CF.sh to deploy on Bluemix Cloudfoundry, use Bluemix_Container.sh to deploy on Bluemix Containers (Kraken & Armada). Note: The script needs to be modified to function. e.g.appName, NAME_SPACE, MONGO_BRIDGE. 