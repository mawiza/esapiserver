require 'spec_helper'

describe 'esapiserver that' do
  
  describe 'provide database related requests that' do
    it 'loads a db' do
      get '/select_db/test_db'
      expect(last_response).to be_ok
      expect(last_response.body).to eq('DB test_db selected')      
    end
    
    it 'resets a db' do
      get '/reset_db/test_db'
      expect(last_response).to be_ok
      expect(last_response.body).to eq('DB test_db dropped and reloaded')
    end
    
    it 'lists a collection of a selected db' do
      get '/db_collections'
      expect(last_response).to be_ok
      expect(last_response.body).to eq('[]')
    end  
  end
  
  describe 'handle POST requests that' do
    it 'creates a new thing' do
      payload = '{"post": {"name": "test"}}'      
      post '/api/posts', payload, "CONTENT_TYPE" => "application/json"
      expect(last_response).to be_ok
      expect(last_response.body).to include('{"post":[{"name":"test","id":')
      #TODO should check to see if it is parsable by json
    end
  end
  
  describe 'handle GET requests that' do
    it 'returns a list of things' do
      get '/api/posts'
      expect(last_response).to be_ok
      expect(last_response.body).to include('{"post":[{"name":"test","id"')
      #TODO should check to see if it is parsable by json
    end
    
    #http://127.0.0.1:4567/api/focusareas?ids%5B%5D=53d7781819cfd232f4000085&ids%5B%5D=53d778e319cfd232f4000087
    it 'returns a list of things that matches a specific query' do
      #create another post
      payload = '{"post": {"name": "test1"}}'
      post '/api/posts', payload, "CONTENT_TYPE" => "application/json"
      expect(last_response).to be_ok
      #query the posts
      get '/api/posts'
      json_hash = JSON.parse(last_response.body)
      #get the ids from the result      
      id1 = json_hash["post"][0]["id"]
      id2 = json_hash["post"][1]["id"]
      get '/api/posts?ids%5B%5D=' + id1 + '&ids%5B%5D=' + id2
      expect(last_response).to be_ok
      expect(last_response.body).to eq('{"post":[{"name":"test","id":"' + id1 + '"},{"name":"test1","id":"' + id2 + '"}]}')
      #TODO should check to see if it is parsable by json      
    end
    
    #http://localhost:4567/api/posts?name=test1
    it 'returns a thing with a specific key/value' do
      get '/api/posts?name=test1'
      expect(last_response).to be_ok
      expect(last_response.body).to include('{"post":[{"name":"test1","id"')
    end
  end
  
  describe 'handle DELETE requests that' do
    it 'deletes a thing with a specific id' do
      get '/api/posts'
      json_hash = JSON.parse(last_response.body)
      id = json_hash["post"][1]["id"]
      delete '/api/posts/' + id
      expect(last_response).to be_ok
      get '/api/posts'
      json_hash = JSON.parse(last_response.body)
      expect(last_response).to be_ok
      expect(json_hash["post"].length).to equal(1)
    end
  end
  
  describe 'handle PUT requests that' do
    it 'updates a thing with a specific id' do
      get '/api/posts?name=test'
      json_hash = JSON.parse(last_response.body)
      id = json_hash["post"][0]["id"]      
      payload = '{"post": {"name": "updated test"}}'
      put '/api/posts/' + id, payload, "CONTENT_TYPE" => "application/json"
      expect(last_response).to be_ok
      expect(last_response.body).to eq('{"post":[{"name":"updated test","id":"' + id + '"}]}')
    end    
  end
end

