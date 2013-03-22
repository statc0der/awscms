require! {
	\require-folder
	path.extname
	"./magic".sync
	"./magic".async
	"./magic".future
	"./oop".abstract
	"./oop".subclass-tracker
	"./backend".Backend
}

class exports.Handler implements abstract \compile \render
	import abstract \handles

	@resolve = (path)->
		path -= /\/$/
		@files[path] ? @files[if path then "#path/index" else \index]

	@roles = {}
	@provides = (role)->
		@roles[role] = this

	import subclass-tracker!

	last-etag: null
	compiled: null
	current-refresh: null

	load: async ->
		# if there is a refresh currently in progress, block on it
		if @current-refresh?
			that.yield!
			@current-refresh = null
		return @compiled

	refresh: async ->
		try
			@error = null
			if Backend.current.is-fresh @path, @last-etag
				{content,etag} = Backend.current.get @path
				@last-etag = etag
				@compile content

		catch @error
			# let load know we couldn't
			return null

	output: async (data)->
		if @load()?
			# we have a cached template
			@render that,data
		else
			# if we're here and error's null something's rotten but you never know
			throw @error ? new Error "an unknown error occured"

	(@path)->
		@unext = path - //#{extname path}$//
		@constructor{}files[@unext] = this
		
		# load this template IN THE FUTURE!
		do future @~refresh

require-folder \handlers