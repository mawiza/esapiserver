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
    POOL_SIZE = 5
    TIMEOUT = 5
    
    $mongoDB = Mongo::Connection.new
    $db = nil
    
    
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
      $db = $mongoDB.db(params[:db], :pool_size => POOL_SIZE, :timeout => TIMEOUT)
      "DB #{params[:db]} selected"
    end

    #
    # This will drop the DB and reload it - useful for cleaning up when running tests
    #
    get '/reset_db/:db' do
      $mongoDB.drop_database(params[:db])
      $db = $mongoDB.db(params[:db], :pool_size => POOL_SIZE, :timeout => TIMEOUT)
      "DB #{params[:db]} dropped and reloaded"
    end

    #
    # Get a list of collections for a specific DB
    #
    get '/db_collections' do
      if $db == nil
        "Please select a DB using /select_db/:db where :db is the name of the database"
      else
        collections = $db.collection_names
        "#{collections}"
      end
    end

    #
    # Returns a list of models or a list of models that matches a specific query
    # http://localhost:4567/api/focusareas - will retrieve all the focusareas
    # http://localhost:4567/api/focusareas?theme_id=53bb2eba19cfd247e4000002 - will retrieve all the focusareas
    # belonging to the specified theme.
    # Works only with a single query parameter or multiple ids[] parameters
    get '/api/:model' do
      content_type :json
      query = {}
      result = {}
      collection = $db.collection(params[:model])

      if request.query_string.empty?
        result = collection.find.to_a.map{|t| fromBsonId(t, params[:model])}.to_json
      else
        if request.query_string.include? 'ids[]' or request.query_string.include? 'ids%5B%5D'
          ids = []
          if request.query_string.include? '&'
            queries = request.query_string.split('&')            
            queries.each do |q|
              key, value = q.split('=')
              if key != 'ids[]' and key != 'ids%5B%5D'
                throw 'multiple query parameters that also have _ids[]= parameters not supported yet'
              end
              ids << toBsonId(value)
            end            
          else
            key, value = request.query_string.split('=')
            ids << toBsonId(value)
          end
          query = {"_id" => { "$in" => ids }}
        elsif request.query_string.include? '&'
          conditions = []
          queries = request.query_string.split('&')
          queries.each do |q|
              key, value = q.split('=')
              conditions << {modelName(params[:model]) + "." + key => value}
          end
          query = {"$and" => conditions }
          puts query
        else
          key, value = request.query_string.split('=')
          query = {modelName(params[:model]) + "." + key => value}
        end
        result = collection.find(query).to_a.map{|t| fromBsonId(t, params[:model])}.to_json
      end
      serializeJSON(result, params[:model])
    end

    #
    # Returns a model with a specific id
    #
    get '/api/:model/:id' do
      content_type :json
      findOne(params[:model], params[:id])
    end

    #
    # Create a new model
    #
    post '/api/:model' do
      content_type :json
      json = JSON.parse(request.body.read.to_s)
      oid = $db.collection(params[:model]).insert(json)
      findOne(params[:model], oid.to_s)
    end

    #
    # Delete a model with a specific id
    #
    delete '/api/:model/:id' do
      content_type :json
      $db.collection(params[:model]).remove({'_id' => toBsonId(params[:id])})
      "{}"
    end

    #
    # Update a model with a specific id
    #
    put '/api/:model/:id' do
      content_type :json
      selector = {'_id' => toBsonId(params[:id])}
      json = JSON.parse(request.body.read).reject{|k,v| k == 'id'}
      document = {'$set' => json}
      result = $db.collection(params[:model]).update(selector, document)
      findOne(params[:model], params[:id])
    end

    #
    # Convert the id to a BSON object id
    #
    def toBsonId(id)
      BSON::ObjectId.from_string(id)
    end

    #
    # Extract the BSON id, then replacing the '_id' key with a 'id' key
    #
    def fromBsonId(obj, model)
      id = obj['_id'].to_s
      obj.delete("_id")
      obj.each{|t| t[1]['id'] = id}
    end

    #
    # Serialize the Mongo JSON to Ember friendly JSON
    #
    def serializeJSON(json, model)
      hash = JSON.parse(json)
      jsonArray = []
      hash.each {|h| jsonArray << h[modelName(params[:model])]}
      newJson = {modelName(params[:model]) => jsonArray}
      newJson.to_json
    end

    #
    # Utility method - find one and the sreialize to Ember Friendly JSON
    #
    def findOne(model, id)
      result = $db.collection(model).find_one(toBsonId(id))
      jsonArray = []
      if result != nil
        normalizedResult = fromBsonId(result, model).to_json
        hash = JSON.parse(normalizedResult)
        jsonArray << hash[modelName(model)]
        newJson = {modelName(params[:model]) => jsonArray}
      newJson.to_json
      else
        noResults = {modelName(model) => jsonArray}
      noResults.to_json
      end
    end

    #
    # Very crude method to singularize the model name.
    #
    def modelName(model)
      #model.chomp("s")
      model.singularize
    end
  end
end
