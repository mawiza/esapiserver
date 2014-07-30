# Esapiserver

A very lightweight Sinatra/MongoDB CRUD API server to be used for EmberJS development and testing. By using MongoDB as the database server, all the tables are created on the fly when POST requests are made, in other words, no tables needs to be created beforehand. 

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
		
	List a collection of a selected db
		http://localhost:4567/db_collections
	
	
POST request:

	Creates a new thing
		http://localhost:4567/api/:thing
	
	
GET requests:

	Returns a list of things
		http://localhost:4567/api/:thing
	
	Returns a list of things that matches a specific query
		http://localhost:4567/api/:thing?ids[]=id1&ids[]=id2
	
	Returns a thing with a specific key/value
		http://localhost:4567/api/:thing?key=value
		
	Returns a thing with a specific id
		http://localhost:4567/api/:thing/:id
	
DELETE request:

	Deletes a thing with a specific id
		http://localhost:4567/api/:thing/:id
	
PUT request:

	Updates a thing with a specific id
		http://localhost:4567/api/:thing/:id
		

EmberJS

	App.ApplicationAdapter = DS.RESTAdapter.extend
    	namespace: 'api'
    	host: 'http://127.0.0.1:4567'
    	corsWithCredentials: true

