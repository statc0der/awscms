LiveScript = require \LiveScript
{relative,resolve} = require \path
fs = require \fs

slobber = (path,code)->
	spit path, code
	say "* #path"

task \build "build lib/ from src/" ->
	for file in dir \src when file == /\.ls$/
		path = \lib `resolve` file - /\.ls$/ + '.js'
		
		\src `resolve` file
		|> (`fs.read-file-sync` \utf8)
		|> LiveScript.compile
		|> slobber path,_

task \run ->
	http    = require \http
	express = require \express
	Awscms  = require \./lib

	port    = process.env.PORT ? 3000
	app     = express!
	
	app.use ...Awscms.middleware {
		prefix: '/'
		refresh-interval: 5s * 1000ms
		external: -> test:"hello"
		...(JSON.parse fs.read-file-sync 'config.json' \utf8)
	}
	app.use (q,s,n)->s.send "404"

	server = http.create-server app
	server.listen port, ->console.log "listening on #port"