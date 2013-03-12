require! {
	path.extname
	"./magic".async
	"./template".Template
}

class exports.Data extends Template
	@files = []
	@handles = (is \.json) . extname

	compile: (src)->
		@compiled = JSON.parse src

	render: (template,data)->template