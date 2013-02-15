if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
(function(){
  var aws2js, handlebars, Sync, extname, sync, async, Template, Partial, Data, syncCb, Awscms, http, express, port, ref$, app, server, replace$ = ''.replace;
  aws2js = require('aws2js');
  handlebars = require('handlebars');
  Sync = require('sync');
  extname = require('path').extname;
  sync = require('./magic').sync;
  async = require('./magic').async;
  Template = require('./template').Template;
  Partial = require('./partial').Partial;
  Data = require('./data').Data;
  syncCb = curry$(function(label, err, res){
    var that;
    if ((that = err) != null) {
      console.error(label, that.stack);
    }
    if ((that = res) != null) {
      return console.log(label, that);
    }
  });
  module.exports = Awscms = (function(){
    Awscms.displayName = 'Awscms';
    var s3, prototype = Awscms.prototype, constructor = Awscms;
    Awscms.handlers = [Template, Partial, Data];
    Awscms.initS3 = function(newS3){
      s3 = newS3;
      return Template.initS3(newS3);
    };
    function Awscms(arg$){
      var accessKeyId, secretAccessKey, bucket, this$ = this;
      accessKeyId = arg$.accessKeyId, secretAccessKey = arg$.secretAccessKey, bucket = arg$.bucket, this.prefix = arg$.prefix;
      constructor.initS3(aws2js.load('s3', accessKeyId, secretAccessKey));
      s3.setBucket(bucket);
      Sync(function fiber(){
        return this$.loadTemplates();
      }, syncCb('load-templates'));
    }
    prototype.loadTemplates = async(function(){
      var i$, ref$, len$, Key, that, results$ = [];
      for (i$ = 0, len$ = (ref$ = [].concat(sync(bind$(s3, 'get'))('/', 'xml').Contents)).length; i$ < len$; ++i$) {
        Key = ref$[i$].Key;
        if (that = find(fn$, constructor.handlers)) {
          results$.push(new that(Key));
        } else {
          results$.push(console.error("No handler for " + Key));
        }
      }
      return results$;
      function fn$(it){
        return it.handles(Key);
      }
    });
    prototype.middleware = function(req, res, next){
      var this$ = this;
      return Sync(function fiber(){
        var remotePath, that, ref$, ref1$;
        if (RegExp('^' + this$.prefix).exec(req.path)) {
          remotePath = replace$.call(req.url, RegExp('^' + this$.prefix), '');
          if ((that = Template.files[remotePath]) != null) {
            res.send(
            that.render(
            (ref$ = (ref1$ = Data.files[remotePath]) != null ? ref1$.data : void 8) != null
              ? ref$
              : {}));
            return true;
          }
        }
      }, function callback(err, res){
        if (!res) {
          return next(err);
        }
      });
    };
    Awscms.middleware = function(conf){
      var prefix;
      prefix = conf.prefix;
      return [prefix, (bind$(new Awscms(conf), 'middleware'))];
    };
    return Awscms;
  }());
  if (module === require.main) {
    http = require('http');
    express = require('express');
    port = (ref$ = process.env.PORT) != null ? ref$ : 3000;
    app = express();
    app.use.apply(app, Awscms.middleware({
      prefix: '/',
      accessKeyId: 'access',
      secretAccessKey: 'secret',
      bucket: 'bucket'
    }));
    app.use(function(q, s, n){
      return s.send("404");
    });
    server = http.createServer(app);
    server.listen(port, function(){
      return console.log("listening on " + port);
    });
  }
  function curry$(f, bound){
    var context,
    _curry = function(args) {
      return f.length > 1 ? function(){
        var params = args ? args.concat() : [];
        context = bound ? context || this : this;
        return params.push.apply(params, arguments) <
            f.length && arguments.length ?
          _curry.call(context, params) : f.apply(context, params);
      } : f;
    };
    return _curry();
  }
  function bind$(obj, key, target){
    return function(){ return (target || obj)[key].apply(obj, arguments) };
  }
}).call(this);
