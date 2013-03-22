global import require \prelude-ls
LiveScript = require \LiveScript
{relative,resolve,dirname} = require \path
mkdirp = require \mkdirp
fs = require \fs
{spawn} = require \child_process

shell = (line)->
	[cmd,...args] = words line

	(out ? id)->
		console.log line
		spawn cmd,args,stdio:\inherit .on \close out

slobber = (path,code)->
	spit path, code
	say "* #path"

build-dir = (folder)->
	for file in dir folder
		full = folder `resolve` file

		switch
		| fs.stat-sync full .is-directory! => build-dir full
		| file == /\.ls$/ =>
			mkdirp.sync \lib `resolve` (\src `relative` full)
			path = \lib `resolve` (\src `relative` full) - /\.ls$/ + '.js'
			
			fs.read-file-sync full, \utf8
			|> LiveScript.compile
			|> slobber path,_

task \build "build lib/ from src/" ->
	build-dir \src

task \clean "clean lib/" shell "rm -rf lib"

task \publish ->
	<- (shell "rm -rf lib")
	invoke \build
	do shell "npm publish"

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
		backend:
			name: \amazon
			options: amazon: JSON.parse fs.read-file-sync 'config.json' \utf8
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

munge-version = (fn)->
	munge-package (import version: format-version fn parse-version it.version)
	<- (shell "git commit -am bump")

task \bump-release ->munge-version (import release: it.release + 1)
task \bump-minor   ->munge-version (import minor:   it.minor   + 1, release: 0)
task \bump-major   ->munge-version (import major:   it.major   + 1, minor: 0 release: 0)