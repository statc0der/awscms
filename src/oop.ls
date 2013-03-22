exports.abstract = (...methods)->
	{[m,->throw new TypeError "#m is abstract"] for m in methods}
