require! {
	aws2js
	tunnel
	"../magic".sync
	"../magic".async
	"../backend".Backend
}

class exports.Amazon extends Backend
	get: async (file)->
		{buffer,headers} = (sync @s3~get) file,\buffer
		content: buffer.to-string \utf8
		etag: headers.etag

	is-fresh: async (file,tag)->
		headers = (sync @s3~head) file
		tag isnt headers.etag

	list: async ->
		(sync @s3~get) '/' \xml .Contents
		|> ([] ++) # when there is only one thing in the bucket S3 returns a bare object. we want an array.
		|> map (.Key) # just the filenames

	({access-key-id,secret-access-key,bucket,proxy,http-options ? {}})->
		if proxy? then http-options import agent:tunnel.https-over-http {proxy}

		@s3 = aws2js.load \s3 access-key-id, secret-access-key,null,http-options
		@s3.set-bucket bucket