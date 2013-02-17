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
		@files[path] ? @files["#path/index"]
		
		
	last-etag: null
	compiled: null
	current-refresh: null
	
	load: async ->
		that.yield! if @current-refresh?
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
		console.log "compile #{@path}"
		@compiled = handlebars.compile src

	render: async (data)->
		if @error? # the last refresh didn't go so well
			throw that
		else if @load()?
			# we have a cached template
			blob = (require "./data" .Data.resolve @unext)?.render! ? {} # any data blobs for us?
			that blob import data
		else
			# if we're here something's rotten but you never know
			throw new Error "an unknown error occured"

	(@path)->
		@unext = path - //#{extname path}$//
		@constructor{}files[@unext] = this
		
		# load this template IN THE FUTURE!
		do future @~refresh
		
handlebars.register-helper \extends (parent,options)->
	# render a parent template with the child template as the {{{body}}}
	Template.files[parent.replace '.' '/'].render {} import this import body:options.fn this