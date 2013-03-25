exports.abstract = (...methods)->
	{[m,->throw new TypeError "#m is abstract"] for m in methods}

exports.subclass-tracker = ->
	subclasses: []
	extended: ->@subclasses.push it
