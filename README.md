# Awscms
## Say it with me: awh-s'ms

Awscms is a [Connect](https://github.com/senchalabs/connect) middleware that serves [Handlebars](https://github.com/wycats/handlebars.js) templates from an Amazon S3 bucket.

Made by [Matt Brennan](https://github.com/quarterto) at [import&bull;io](http://import.io).

##Installing
```npm install awscms```

##Using
### The setup
```javascript
app.use.apply(app, Awscms.middleware({
		prefix: '/awscms',
		access-key-id: "",
		secret-access-key: "",
		bucket: "bucket-name"
}))

```
#### page.htm
```html
{{#extends "base"}}
{{> header}}
<ol>
	{{#each list}}
	<li>{{.}}
	{{/each}}
</ol>
{{/extends}}
```
#### page.json
```json
{
	"list": [
		"Is amazing",
		"Will save your life"
	]
}
```
#### header.part
```html
<h1>Awscms</h1>
```
#### base.htm
```html
<!doctype html>

{{{body}}}
```

### The request
```GET /awscms/page```

### The response
Well, what do you think?

## Licence
Awscms is released under the [MIT licence](LICENCE.md).
&copy;2013 import&bull;io