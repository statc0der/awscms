require! {
	marked
	path.extname
	"../handler".Handler
}

class exports.Markdown extends Handler
	@files = []
	@handles = (in [\.md \.markdown]) . extname

	compile: (src)->
		compiled = marked src
		handlebars.register-partial (@unext.replace '/' '.'), compiled
		return compiled

	render: (template,data)->
		template
