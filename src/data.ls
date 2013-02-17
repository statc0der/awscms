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
		@compiled = JSON.parse src

	render: async (data)->
		if @error? # the last refresh didn't go so well
			throw that
		else if @load()?
			# we have cached data
			that
		else
			# if we're here something's rotten but you never know
			throw new Error "an unknown error occured"