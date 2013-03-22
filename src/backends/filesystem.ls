require! {
	fs
	path.resolve
	path.relative
	"../magic".sync
	"../magic".async
	"../backend".Backend
}

class exports.Filesystem extends Backend
	get: async (file)->
		res = resolve @directory,file
		{mtime} = (sync fs.stat) res
		content = (sync fs.read-file) res,\utf8
		{content, etag: mtime}

	is-fresh: async (file,tag)->
		res = resolve @directory,file
		{mtime} = (sync fs.stat) res
		tag isnt mtime

	list: async (dir = @directory)->
		(sync fs.readdir) dir
		|> concat-map (file)~>
			res = resolve dir,file
			match (sync fs.stat) res
			| (.is-directory!) => list res
			| otherwise => [(relative @directory,res)]

	({@directory})->