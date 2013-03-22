require! {
	\require-folder
	"./oop".abstract
	"./oop".subclass-tracker
}

class exports.Backend implements abstract \list \get \isFresh
	import subclass-tracker!

	@current = null

	@create = (name,conf)->
		if find (.display-name is name), @subclasses
			@current = new that conf
		else throw new TypeError "No backend called #name"

require-folder \backends