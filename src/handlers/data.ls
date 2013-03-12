require! {
	path.extname
	"./handler".Handler
}

class exports.Data extends Handler
	@files = []
	@handles = (is \.json) . extname

	compile: (src)->
		@compiled = JSON.parse src

	render: (template,data)->template