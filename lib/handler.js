(function(){
  var requireFolder, extname, sync, async, future, abstract, Handler, slice$ = [].slice, replace$ = ''.replace;
  requireFolder = require('require-folder');
  extname = require('path').extname;
  sync = require('../magic').sync;
  async = require('../magic').async;
  future = require('../magic').future;
  abstract = function(){
    var methods, i$, len$, m, results$ = {};
    methods = slice$.call(arguments);
    for (i$ = 0, len$ = methods.length; i$ < len$; ++i$) {
      m = methods[i$];
      results$[m] = fn$;
    }
    return results$;
    function fn$(){
      throw new TypeError(m + " is abstract");
    }
  };
  exports.Handler = Handler = (function(){
    Handler.displayName = 'Handler';
    var s3, prototype = Handler.prototype, constructor = Handler;
    importAll$(prototype, arguments[0]);
    import$(Handler, abstract('handles'));
    Handler.initS3 = (function(it){
      return s3 = it;
    });
    Handler.resolve = function(path){
      var ref$;
      return (ref$ = this.files[path]) != null
        ? ref$
        : this.files[path ? path + "/index" : 'index'];
    };
    Handler.roles = {};
    Handler.provides = function(role){
      return this.roles[role] = this;
    };
    Handler.subclasses = [];
    Handler.extended = bind$(Handler.subclasses, 'push');
    prototype.lastEtag = null;
    prototype.compiled = null;
    prototype.currentRefresh = null;
    prototype.load = async(function(){
      var that;
      if ((that = this.currentRefresh) != null) {
        that['yield']();
        this.currentRefresh = null;
      }
      return this.compiled;
    });
    prototype.refresh = async(function(){
      var headers, buffer;
      try {
        this.error = null;
        headers = sync(bind$(s3, 'head'))(this.path);
        if (headers.etag !== this.lastEtag) {
          this.lastEtag = headers.etag;
          buffer = sync(bind$(s3, 'get'))(this.path, 'buffer').buffer;
          return this.compile(buffer.toString('utf8'));
        }
      } catch (e$) {
        this.error = e$;
        return null;
      }
    });
    prototype.output = async(function(data){
      var that, ref$;
      if ((that = this.load()) != null) {
        return this.render(that, data);
      } else {
        throw (ref$ = this.error) != null
          ? ref$
          : new Error("an unknown error occured");
      }
    });
    function Handler(path){
      var ref$;
      this.path = path;
      this.unext = replace$.call(path, RegExp(extname(path) + '$'), '');
      ((ref$ = this.constructor).files || (ref$.files = {}))[this.unext] = this;
      future(bind$(this, 'refresh'))();
    }
    return Handler;
  }(abstract('compile', 'render')));
  requireFolder('handlers');
  function importAll$(obj, src){
    for (var key in src) obj[key] = src[key];
    return obj;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
  function bind$(obj, key, target){
    return function(){ return (target || obj)[key].apply(obj, arguments) };
  }
}).call(this);
