require! {
	path.extname
	"./magic".async
	"./template".Template
}

class exports.Data extends Template
	@files = []
	@handles = (is \.json) . extname
	
	compile: (src)->
		# this never gets rendered so we aren't going to cache it
		# TODO: we never try to load this again, so it could get stale?
		@data = JSON.parse src
	
	render: async (data)->
		# this *should* never get called
		throw new TypeError "JSON data #{@path} cannot be rendered."
