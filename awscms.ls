require! {aws2js,handlebars,crypto,Sync:sync,path.extname}

async  = (.async!)
sync   = (fn)->(...args)-> fn.sync null,...args
future = (fn)->(...args)-> fn.future null,...args

sync-cb = (label,err,res)-->
	console.error label, that.stack if err?
	console.log label, that if res?

class Awscms extends process.EventEmitter
	var s3
	class Template
		@files = []
		
		last-etag: null
		compiled: null
		load: async ->
			try
				headers = (sync s3~head) @path

				console.log "loading #{@path}"
				if headers.etag isnt @last-etag
					@last-etag = headers.etag
					{buffer} = (sync s3~get) @path,\buffer
					console.log "load #{@path}"
					@compile buffer.to-string \utf8
				else @compiled
			catch @error => return null

		compile: (src)->
			console.log "compiled #{@path}"
			@compiled = handlebars.compile src
		render: async (data)->
			console.log "rendering #{@path}"
			if @load! then that data else throw @error ? new Error "an unknown error occured"

		(@path)->
			console.log "init #{@path}"
			
			@unext = path - //#{extname path}$//
			@constructor{}files[@unext] = this
			do future @~load

	class Partial extends Template
		@files = []
		compile: (src)->
			console.log "compiled #{@path}"
			handlebars.register-partial (@unext.replace '/' '.') ,handlebars.compile src
		render: async (data)-> throw new TypeError "Partial template #{@path} cannot be directly rendered."

	class Data extends Template
		@files = []
		render: async (data)-> throw new TypeError "JSON data #{@path} cannot be rendered."
		compile: (src)->
			console.log "compiled #{@path}"
			@data = JSON.parse src
			
	handlebars.register-helper \extends (parent,options)->
		Template.files[parent.replace '.' '/'].render {} import this import body:options.fn this

	({access-key-id,secret-access-key,bucket,@prefix})->
		s3 := aws2js.load \s3 access-key-id,secret-access-key
		s3.set-bucket bucket
		Sync do
			:fiber ~>
				@load-templates!
				@emit \load
			sync-cb \load-templates

	load-templates: async ->
		for {Key} in [] ++ ((sync s3~get) '/' \xml .Contents)
			switch extname Key
			| \.htm  => new Template Key
			| \.part => new Partial Key
			| \.json => new Data Key

	middleware: (req,res,next)-> Sync do
		:fiber ~>
			if //^#{@prefix}// == req.path
				remote-path = req.url - //^#{@prefix}//

				if Template.files[remote-path]?
					Data.files[remote-path]?data ? {}
					|> that.render
					|> res.send
					
					return true
				
		(err,res)->next err unless res
	@middleware = ({prefix}:conf)->
		[prefix, aws = new Awscms conf .~middleware]

if module is require.main
	require! [http,express]
	port = process.env.PORT ? 3000
	app = express!
	
	app.use ...Awscms.middleware do
		prefix: '/'
		access-key-id: \access
		secret-access-key: \secret
		bucket: \bucket
	app.use (q,s,n)->s.send "404"

	server = http.create-server app
	server.listen port, ->console.log "listening on #port"