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
	@handles = (is \.htm) . extname
	
	@resolve = (path)->
		@@files[path] ? @@files["#path/index"]
	
	last-etag: null
	compiled: null
	load: async ->
		try
			# all we need is the etag
			headers = (sync s3~head) @path

			if headers.etag isnt @last-etag
				# it's fresh on s3
				@last-etag = headers.etag
				
				{buffer} = (sync s3~get) @path,\buffer
				@compile buffer.to-string \utf8
			else
				# our version is fresh enough
				@compiled

		catch @error
			# let render know we couldn't load
			return null

	compile: (src)->
		# compile & cache it
		@compiled = handlebars.compile src

	render: async (data)->
		if @load!
			# we have a compiled (or cached) template
			that data
		else
			# if we're here and @error is null something's rotten but you never know
			throw @error ? new Error "an unknown error occured"

	(@path)->
		@unext = path - //#{extname path}$//
		@constructor{}files[@unext] = this
		
		# load this template IN THE FUTURE!
		do future @~load
		
handlebars.register-helper \extends (parent,options)->
	# render a parent template with the child template as the {{{body}}}
	Template.files[parent.replace '.' '/'].render {} import this import body:options.fn this