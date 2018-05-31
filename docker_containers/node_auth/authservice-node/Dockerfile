#FROM registry.ng.bluemix.net/ibmnode
FROM node:latest

RUN mkdir /src

WORKDIR /src
COPY ./ /src
RUN npm install

EXPOSE 80
ENV VCAP_APP_PORT=80

ENV CUSTOMER_SERVICE=nginx1/customer

CMD ["node", "authservice_app.js"]
