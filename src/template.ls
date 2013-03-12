require! {
	handlebars
	path.extname
	"./magic".sync
	"./magic".async
	"./magic".future
}

class exports.Template
	var s3
	@files = []
	@init-s3 = (s3 :=)
	@handles = (in [\.htm \.html]) . extname

	@resolve = (path)->
		@files[path] ? @files[if path then "#path/index" else \index]

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

	compile: (src)->
		# compile & cache it
		@compiled = handlebars.compile src

	render: (template,data)->
		# any data blobs for us?
		blob = (require "./data" .Data.resolve @unext)?.output! ? {}
		if template not instanceof Function
			console.log [\RSNT template]
		template ^^blob import data

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

handlebars.register-helper \extends (parent,options)->
	# render a parent template with the child template as the {{{body}}}
	Template.files[parent.replace '.' '/'].output {} import this import body:options.fn this