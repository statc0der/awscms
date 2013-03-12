require! {
	\require-folder
	path.extname
	"./magic".sync
	"./magic".async
	"./magic".future
}

abstract = (...methods)->
	{[m,->throw new TypeError "#m is abstract"] for m in methods}

class exports.Handler implements abstract \compile \render
	import abstract \handles

	var s3 # private static
	@init-s3 = (s3 :=)

	@resolve = (path)->
		@files[path] ? @files[if path then "#path/index" else \index]

	@roles = {}
	@provides = (role)->
		@roles[role] = this

	@subclasses = []
	@extended = @subclasses~push

	last-etag: null
	compiled: null
	current-refresh: null

	load: async ->
		# if there is an S3 GET currently in progress, block on it
		if @current-refresh?
			that.yield!
			@current-refresh = null
		return @compiled

	refresh: async ->
		try
			@error = null
			# all we need is the etag
			headers = (sync s3~head) @path

			if headers.etag isnt @last-etag
				# it's fresh on s3
				@last-etag = headers.etag
				
				{buffer} = (sync s3~get) @path,\buffer
				@compile buffer.to-string \utf8

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