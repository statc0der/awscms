{spawn,exec} = require \child_process
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
