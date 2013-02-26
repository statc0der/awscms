require! {
	aws2js
	handlebars
	tunnel
	Sync:sync
	path.extname
	"./magic".sync
	"./magic".async
	"./magic".future
	"./template".Template
	"./partial".Partial
	"./data".Data
	"./globaldata".GlobalData
	"prelude-ls".find
}

tap = (fn,a)--> fn a; a
and-now = tap (do)
module.exports = class Awscms
	var s3
	@handlers = [Template,Partial,Data,GlobalData]
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
		
		set-interval do
			and-now ~> Sync @~load-templates, -> if it? then console.error it
			refresh-interval
			
	refresh: async ->
		for handler in @@handlers => do sync handler~refresh

	load-templates: async ->
		# GET the bucket root for a list of all its files
		for {Key} in [] ++ ((sync s3~get) '/' \xml .Contents)
			# instantiate a handler for each file in the bucket if we can
			if handler = find (.handles Key), @@handlers
				if (file = handler.files[Key - //#{extname Key}$//])?
					file.current-refresh = do (future file~refresh) unless file.current-refresh?
				else new handler Key
			else console.error "No handler for #Key"

	middleware: (req,res,next)-> Sync do
		:fiber ~>
			if //^#{@prefix}// == req.path
				remote-path = req.path - //^#{@prefix}// # strip off the prefix

				if (file = (Template.resolve remote-path))?
					ex = if @external? then that req,res else {} # any external data?
					GlobalData.collapse!
					|> (import ex)
					|> file.render
					|> res.send
					return true # notify sync's callback that we were able to render (avoids sending headers twice)
					
		:callback (err,res)->
			# pass on to the next handle iff we haven't rendered a template. pass any serious errors on
			next err unless res

	@middleware = ({prefix}:conf)->
		[prefix, new Awscms conf .~middleware]