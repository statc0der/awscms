require! {
	handlebars
	path.extname
	"../handler".Handler
}

class exports.Template extends Handler
	@files = []
	@handles = (in [\.htm \.html]) . extname
	@provides \main

	compile: (src)->
		# compile & cache it
		@compiled = handlebars.compile src

	render: (template,data)->
		# any data blobs for us?
		blob = (require "./data" .Data.resolve @unext)?.output! ? {}
		template ^^blob import data

handlebars.register-helper \extends (parent,options)->
	# render a parent template with the child template as the {{{body}}}
	Template.files[parent.replace '.' '/'].output {} import this import body:options.fn this