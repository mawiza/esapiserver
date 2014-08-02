# Esapiserver

A very lightweight Sinatra/MongoDB CRUD API server to be used for EmberJS development and testing. By using MongoDB as the database server, all the tables are created on the fly when POST requests are made, in other words, no tables needs to be created beforehand.

I started out using the fixture and local storage adapter in Ember, but experienced that the limitations that these adapters have, would turn out be a pain in the butt later when it was time to release my app - I wanted to make sure that what I test, was consistant with what I would release, hence the esapiserver. 

## Installation

Run:

	Install the gem
    	$ gem install esapiserver
    
    Start up your mongoDB server   
    	$ mongoD
    	
    Start the Ember Sinatra/MongoDB API server
    	$ easapiserver

## Usage

Database related requests:

	Load a db
		http://localhost:4567/select_db/ember_test_db
		
	Reset a db - this will drop and reload the DB
		http://localhost:4567/reset_db/ember_test_db
		
	List the collections of the selected db
		http://localhost:4567/db_collections
	
	
POST request:

	Creates a new model
		http://localhost:4567/api/:model
	
	
GET requests:

	Returns a list of models
		http://localhost:4567/api/:model
	
	Returns a list of models that matches a specific query
		http://localhost:4567/api/:model?ids[]=id1&ids[]=id2
	
	Returns a model with a specific key/value
		http://localhost:4567/api/:model?key=value
		
	Returns a model with a specific id
		http://localhost:4567/api/:model/:id
	
DELETE request:

	Deletes a model with a specific id
		http://localhost:4567/api/:model/:id
	
PUT request:

	Updates a model with a specific id
		http://localhost:4567/api/:model/:id
		

EmberJS

	App.ApplicationAdapter = DS.RESTAdapter.extend
    	namespace: 'api'
    	host: 'http://127.0.0.1:4567'
    	corsWithCredentials: true

