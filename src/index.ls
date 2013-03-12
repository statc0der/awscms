require! {
	aws2js
	tunnel
	Sync:sync
	path.extname
	"./magic".sync
	"./magic".async
	"./magic".future
	"./handler".Handler
	"prelude-ls".find
}

tap = (fn,a)--> fn a; a
and-now = tap (do)
module.exports = class Awscms
	var s3
	@init-s3 = (new-s3)->
		# Template needs to access our S3
		s3 := new-s3
		Template.init-s3 new-s3

	({ # Awscms' constructor
		access-key-id
		secret-access-key
		bucket
		@prefix
		@external
		proxy
		http-options ? {}
		refresh-interval ? 1000ms * 60s * 5m
	})->
		if proxy? then http-options import agent:tunnel.https-over-http {proxy}

		@@init-s3 aws2js.load \s3 access-key-id, secret-access-key,null,http-options
		s3.set-bucket bucket

		Sync do
			:fiber !~>
				for ever
					@load-templates!
					Sync.sleep refresh-interval
			:handler ->
				console.error it
				throw it if it.errno?

	refresh: async ->
		for handler in Handler.subclasses => do sync handler~refresh

	load-templates: async ->
		# GET the bucket root for a list of all its files
		for {Key} in [] ++ ((sync s3~get) '/' \xml .Contents)
			# instantiate a handler for each file in the bucket if we can
			if handler = find (.handles Key), Handler.subclasses
				if (file = handler.files[Key - //#{extname Key}$//])?
					file.current-refresh = do (future file~refresh) unless file.current-refresh?
				else new handler Key
			else console.warn "No handler for #Key"

	middleware: (req,res,next)-> Sync do
		:fiber ~>
			if //^#{@prefix}// == req.path
				remote-path = req.path - //^#{@prefix}// # strip off the prefix

				if (file = (Handler.roles.main.resolve remote-path))?
					ex = if @external? then that req,res else {} # any external data?
					Handler.roles.globaldata.collapse!
					|> (import ex)
					|> file.output
					|> res.send
					return true # notify sync's callback that we were able to render (avoids sending headers twice)

		:callback (err,res)->
			# pass on to the next handle iff we haven't rendered a template. pass any serious errors on
			next err unless res

	@middleware = ({prefix}:conf)->
		[prefix, new Awscms conf .~middleware]