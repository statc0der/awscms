require! {
	path.extname
	"./magic".async
	"./data".Data
}

class exports.GlobalData extends Template
	@files = []
	@handles = (is \.gjson) . extname
	
	@collapse = ->
		map (.render!), @files
		|> fold (import),{}