require! {
	path.extname
	"./magic".async
	"./data".Data
	"prelude-ls".map
	"prelude-ls".fold
	"prelude-ls".each
}

class exports.GlobalData extends Data
	@files = []
	@handles = (is \.gjson) . extname

	@collapse = ->
		fold (import), {}, [f.output! for _,f of @files]