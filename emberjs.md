I started out using the fixture and local storage adapters in Ember, but experienced that the limitations that these adapters have, would turn out be a pain later when it was time to release my app - I wanted to make sure that what I test, was consistant with what I would release, hence the esapiserver. 

###Installation

	Install the gem
    	$ gem install esapiserver
    
    Start up your mongoDB server   
    	$ mongoD
    	
    Start the Ember Sinatra/MongoDB API server
    	$ easapiserver

###EmberJS

There are a couple of things that we need to do to get EmberJS and the esapiserver to play together. 

First, we need to configure our RESTAdapter

	App.ApplicationAdapter = DS.RESTAdapter.extend
		namespace: 'api'
		host: 'http://127.0.0.1:4567'
		corsWithCredentials: true

Because we are using an "external server", we have to enable CORS support in EmberJS. (read more here)

Now. lets assume that we have the following model setup in EmerJS:

	App.Post = DS.Model.extend
		content: DS.attr('string')
		comments: DS.hasMany('strategy',
			async: true
		)

	App.comment = DS.Model.extend
		content: DS.attr('string')
		post: DS.belongsTo('post',
			embedded: true
		)

Creating our record in EmberJS

	post = @store.createRecord("post",
		content: 'EmberJS development'
	)

	post.save().then ->
		comment = store.createRecord("comment",
			content: 'the first comment'
			post: post
		)

		comment.save().then ->
			post.get("comments").pushObject(comment)
			post.save()

making a GET request to the esapiserver, 

	@store.find('post', "53b9a08f19cfd220bc000001")

the response from the server will be the following EmberJS friendly JSON

	{
		post: [
			{
				content: "EmberJS development",
				comments: [
					"53e3857219cfd21340000064"
				],
				id: "53b9a08f19cfd220bc000001"
			}
		]
	}

