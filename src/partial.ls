require! {
	handlebars
	path.extname
	"./magic".async
	"./template".Template
}

class exports.Partial extends Template
	@files = []
	@handles = (is \.part) . extname

	compile: (src)->
		handlebars.register-partial (@unext.replace '/' '.') ,handlebars.compile src

	render: async (data)->
		# this *should* never get called
		throw new TypeError "Partial template #{@path} cannot be directly rendered."