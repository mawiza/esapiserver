# Esapiserver

A Sinatra/MongoDB API server to use for EmberJS development

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

## Contributing

1. Fork it ( https://github.com/[my-github-username]/esapiserver/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
