require! {
	aws2js
	handlebars
	Sync:sync
	path.extname
	"./magic".sync
	"./magic".async
	"./template".Template
	"./partial".Partial
	"./data".Data
	"prelude-ls".find
}

sync-cb = (label,err,res)-->
	console.error label, that.stack if err?
	console.log label, that if res?

module.exports = class Awscms
	var s3
	@handlers = [Template,Partial,Data]
	@init-s3 = (new-s3)->
		# Template needs to access our S3
		s3 := new-s3
		Template.init-s3 new-s3

	({access-key-id,secret-access-key,bucket,@prefix})->
		@@init-s3 aws2js.load \s3 access-key-id,secret-access-key
		s3.set-bucket bucket
		Sync do
			:fiber ~> @load-templates!
			sync-cb \load-templates

	load-templates: async ->
		# GET the bucket root for a list of all its files
		for {Key} in [] ++ ((sync s3~get) '/' \xml .Contents)
			# instantiate a handler for each file in the bucket if we can
			if find (.handles Key), @@handlers
				new that Key
			else console.error "No handler for #Key"

	middleware: (req,res,next)-> Sync do
		:fiber ~>
			if //^#{@prefix}// == req.path
				remote-path = req.url - //^#{@prefix}// # strip off the prefix

				if Template.files[remote-path]?
					Data.files[remote-path]?data ? {} # any json for us?
					|> that.render
					|> res.send
					return true # notify sync's callback that we were able to render (avoids sending headers twice)
					
		:callback (err,res)->
			# pass on to the next handle iff we haven't rendered a template. pass any serious errors on
			next err unless res

	@middleware = ({prefix}:conf)->
		[prefix, new Awscms conf .~middleware]