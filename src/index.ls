require! {
	Sync:sync
	path.extname
	"./magic".sync
	"./magic".async
	"./magic".future
	"./handler".Handler
	"./backend".Backend
	"prelude-ls".find
}

tap = (fn,a)--> fn a; a
and-now = tap (do)
module.exports = class Awscms
	({ # Awscms' constructor
		backend
		@prefix
		@external
		refresh-interval ? 1000ms * 60s * 5m
	})->
		Backend.create backend.name, backend.options[backend.name]

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
		for filename in Backend.current.list!
			# instantiate a handler for each file in the bucket if we can
			if handler = find (.handles filename), Handler.subclasses
				if (file = handler.files[filename - //#{extname filename}$//])?
					file.current-refresh = do (future file~refresh) unless file.current-refresh?
				else new handler filename
			else console.warn "No handler for #filename"

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