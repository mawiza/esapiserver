require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'mongo'
require 'json'
require 'sinatra/cross_origin'
require 'active_support/inflector'
require "esapiserver/version"

module Esapiserver
  class Server < Sinatra::Application
    mongoDB = Mongo::Connection.new
    @@db = nil
    
    #
    #
    #
    configure do
      enable :cross_origin
    end
    
    #
    # Taking care of Access-Control-Allow
    #
    before do
      if request.request_method == 'OPTIONS'
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = "POST, PUT, DELETE"
        halt 200
      end
    end
    
    #
    # Select the DB - for example sip_ember_db for development and sip_ember_test_db when
    # running tests.
    #
    get '/select_db/:db' do
      @@db = mongoDB.db(params[:db], :pool_size => 5, :timeout => 5)      
      "DB #{params[:db]} selected"
    end
    
    #
    # This will drop the DB and reload it - useful for cleaning up when running tests
    #
    get '/reset_db/:db' do  
      mongoDB.drop_database(params[:db])
      @@db = mongoDB.db(params[:db], :pool_size => 5, :timeout => 5)      
      "DB #{params[:db]} dropped and reloaded"
    end
    
    #
    # Get a list of collections for a specific DB
    #
    get '/db_collections' do
      if @@db == nil
        "Please select a DB using /select_db/:db where :db is the name of the database"
      else
        collections = @@db.collection_names
        "#{collections}"
      end  
    end
    
    
    #
    # Returns a list of things or a list of things that matches a specific query
    # http://localhost:4567/api/focusareas - will retrieve all the focusareas
    # http://localhost:4567/api/focusareas?theme_id=53bb2eba19cfd247e4000002 - will retrieve all the focusareas
    # belonging to the specified theme.
    # Works only with a single query parameter or multiple ids[] parameters
    get '/api/:thing' do
      content_type :json
      query = {}
      result = {}
      collection = @@db.collection(params[:thing])
    
      if request.query_string.empty?
        result = collection.find.to_a.map{|t| frombsonid(t, params[:thing])}.to_json
      else    
        if request.query_string.include? '&'
          queries = request.query_string.split('&')
          ids = []
          queries.each do |q|            
            key, value = q.split('=')
            if key != 'ids[]'
              throw 'multiple query parameters not supported yet, except _ids[]=' 
            end
            ids << tobsonid(value)
          end
          query = {"_id" => { "$in" => ids }}
        else
          key, value = request.query_string.split('=')
          query = {modelName(params[:thing]) + "." + key => value}
        end
        result = collection.find(query).to_a.map{|t| frombsonid(t, params[:thing])}.to_json        
      end
      serializeJSON(result, params[:thing])    
    end
    
    #
    # Returns a thing with a specific id
    #
    get '/api/:thing/:id' do
      content_type :json
      find_one(params[:thing], params[:id])
    end
    
    #
    # Create a new thing
    #
    post '/api/:thing' do
      content_type :json
      json = JSON.parse(request.body.read.to_s)
      oid = @@db.collection(params[:thing]).insert(json)
      find_one(params[:thing], oid.to_s)
    end
    
    #
    # Delete a thing with a specific id
    #
    delete '/api/:thing/:id' do
      content_type :json
      @@db.collection(params[:thing]).remove({'_id' => tobsonid(params[:id])})
      "{}"
    end
    
    #
    # Update a thing with a specific id
    #
    put '/api/:thing/:id' do
      content_type :json
      selector = {'_id' => tobsonid(params[:id])}
      json = JSON.parse(request.body.read).reject{|k,v| k == 'id'}
      document = {'$set' => json}
      result = @@db.collection(params[:thing]).update(selector, document)
      find_one(params[:thing], params[:id])
    end
    
    #
    # Convert the id to a BSON object id
    #
    def tobsonid(id) 
        BSON::ObjectId.from_string(id) 
    end
    
    #
    # Extract the BSON id, then replacing the '_id' key with a 'id' key
    #
    def frombsonid(obj, thing)
      id = obj['_id'].to_s
      obj.delete("_id")
      obj.each{|t| t[1]['id'] = id}
    end
    
    #
    # Serialize the Mongo JSON to Ember friendly JSON
    #
    def serializeJSON(json, thing)
      hash = JSON.parse(json)
      jsonArray = []
      hash.each {|h| jsonArray << h[modelName(params[:thing])]}
      newJson = {modelName(params[:thing]) => jsonArray}
      newJson.to_json
    end
    
    #
    # Utility method - find one and the sreialize to Ember Friendly JSON
    #
    def find_one(thing, id)
      result = @@db.collection(thing).find_one(tobsonid(id))
      jsonArray = []
      if result != nil
        normalizedResult = frombsonid(result, thing).to_json      
        hash = JSON.parse(normalizedResult)        
        jsonArray << hash[modelName(thing)]
        newJson = {modelName(params[:thing]) => jsonArray}       
        newJson.to_json
      else
        noResults = {modelName(thing) => jsonArray}
        noResults.to_json
      end
    end
    
    #
    # Very crude method to singularize the model name.
    #
    def modelName(thing)
      #thing.chomp("s")
      thing.singularize
    end
  end
end
