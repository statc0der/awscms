(function(){
  var aws2js, tunnel, Sync, extname, sync, async, future, Handler, find, tap, andNow, Awscms, replace$ = ''.replace;
  aws2js = require('aws2js');
  tunnel = require('tunnel');
  Sync = require('sync');
  extname = require('path').extname;
  sync = require('./magic').sync;
  async = require('./magic').async;
  future = require('./magic').future;
  Handler = require('./handler').Handler;
  find = require('prelude-ls').find;
  tap = curry$(function(fn, a){
    fn(a);
    return a;
  });
  andNow = tap((function(it){
    return it();
  }));
  module.exports = Awscms = (function(){
    Awscms.displayName = 'Awscms';
    var s3, prototype = Awscms.prototype, constructor = Awscms;
    Awscms.initS3 = function(newS3){
      s3 = newS3;
      return Template.initS3(newS3);
    };
    function Awscms(arg$){
      var accessKeyId, secretAccessKey, bucket, proxy, httpOptions, ref$, refreshInterval, this$ = this;
      accessKeyId = arg$.accessKeyId, secretAccessKey = arg$.secretAccessKey, bucket = arg$.bucket, this.prefix = arg$.prefix, this.external = arg$.external, proxy = arg$.proxy, httpOptions = (ref$ = arg$.httpOptions) != null
        ? ref$
        : {}, refreshInterval = (ref$ = arg$.refreshInterval) != null
        ? ref$
        : 1000 * 60 * 5;
      if (proxy != null) {
        httpOptions.agent = tunnel.httpsOverHttp({
          proxy: proxy
        });
      }
      constructor.initS3(aws2js.load('s3', accessKeyId, secretAccessKey, null, httpOptions));
      s3.setBucket(bucket);
      Sync(function fiber(){
        for (;;) {
          this$.loadTemplates();
          Sync.sleep(refreshInterval);
        }
      }, function handler(it){
        console.error(it);
        if (it.errno != null) {
          throw it;
        }
      });
    }
    prototype.refresh = async(function(){
      var i$, ref$, len$, handler, results$ = [];
      for (i$ = 0, len$ = (ref$ = Handler.subclasses).length; i$ < len$; ++i$) {
        handler = ref$[i$];
        results$.push(sync(bind$(handler, 'refresh'))());
      }
      return results$;
    });
    prototype.loadTemplates = async(function(){
      var i$, ref$, len$, Key, handler, file, results$ = [];
      for (i$ = 0, len$ = (ref$ = [].concat(sync(bind$(s3, 'get'))('/', 'xml').Contents)).length; i$ < len$; ++i$) {
        Key = ref$[i$].Key;
        if (handler = find(fn$, Handler.subclasses)) {
          if ((file = handler.files[replace$.call(Key, RegExp(extname(Key) + '$'), '')]) != null) {
            if (file.currentRefresh == null) {
              results$.push(file.currentRefresh = future(bind$(file, 'refresh'))());
            }
          } else {
            results$.push(new handler(Key));
          }
        } else {
          results$.push(console.warn("No handler for " + Key));
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
        var remotePath, file, ex, that;
        if (RegExp('^' + this$.prefix).exec(req.path)) {
          remotePath = replace$.call(req.path, RegExp('^' + this$.prefix), '');
          if ((file = Handler.roles.main.resolve(remotePath)) != null) {
            ex = (that = this$.external) != null
              ? that(req, res)
              : {};
            res.send(
            file.output(
            (function(it){
              return import$(it, ex);
            })(
            Handler.roles.globaldata.collapse())));
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
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
