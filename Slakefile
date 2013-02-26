global import require \prelude-ls
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
		proxy: host: \localhost port:3128
		external: -> test:"hello"
		...(JSON.parse fs.read-file-sync 'config.json' \utf8)
	}
	app.use (q,s,n)->s.send "404"

	server = http.create-server app
	server.listen port, ->console.log "listening on #port"
	
parse-version = (ver)->
	[major,minor,release] = map parse-int, ver.split \.
	{major,minor,release}

format-version = (ver)->
	join \. ver[\major \minor \release]

munge-file = (file,fn)-->
	fs.read-file-sync file, \utf8
	|> fn
	|> fs.write-file-sync file, _

munge-package = (fn)-> munge-file \package.json JSON.parse>>fn>>(JSON.stringify _,null,2)

munge-version = (fn)-> munge-package (import version: format-version fn parse-version it.version)

task \bump-release ->munge-version (import release: it.release + 1)
task \bump-minor   ->munge-version (import minor:   it.minor   + 1, release: 0)
task \bump-major   ->munge-version (import major:   it.major   + 1, minor: 0 release: 0)