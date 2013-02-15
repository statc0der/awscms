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
		# this never gets rendered so we aren't going to cache it
		# TODO: we never try to load this again, so it could get stale?
		handlebars.register-partial (@unext.replace '/' '.') ,handlebars.compile src

	render: async (data)->
		# this *should* never get called
		throw new TypeError "Partial template #{@path} cannot be directly rendered."