(function(){
  var handlebars, extname, sync, async, future, Template, replace$ = ''.replace;
  handlebars = require('handlebars');
  extname = require('path').extname;
  sync = require('./magic').sync;
  async = require('./magic').async;
  future = require('./magic').future;
  exports.Template = Template = (function(){
    Template.displayName = 'Template';
    var s3, prototype = Template.prototype, constructor = Template;
    Template.files = [];
    Template.initS3 = (function(it){
      return s3 = it;
    });
    Template.handles = compose$([
      (function(it){
        return it == '.htm' || it == '.html';
      }), extname
    ]);
    Template.resolve = function(path){
      var ref$;
      return (ref$ = this.files[path]) != null
        ? ref$
        : this.files[path ? path + "/index" : 'index'];
    };
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
    prototype.compile = function(src){
      return this.compiled = handlebars.compile(src);
    };
    prototype.render = function(template, data){
      var blob, ref$, ref1$;
      blob = (ref$ = (ref1$ = require("./data").Data.resolve(this.unext)) != null ? ref1$.output() : void 8) != null
        ? ref$
        : {};
      if (!(template instanceof Function)) {
        console.log(['RSNT', template]);
      }
      return template(import$(clone$(blob), data));
    };
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
    function Template(path){
      var ref$;
      this.path = path;
      this.unext = replace$.call(path, RegExp(extname(path) + '$'), '');
      ((ref$ = this.constructor).files || (ref$.files = {}))[this.unext] = this;
      future(bind$(this, 'refresh'))();
    }
    return Template;
  }());
  handlebars.registerHelper('extends', function(parent, options){
    var ref$;
    return Template.files[parent.replace('.', '/')].output((ref$ = import$({}, this), ref$.body = options.fn(this), ref$));
  });
  function compose$(fs){
    return function(){
      var i, args = arguments;
      for (i = fs.length; i > 0; --i) { args = [fs[i-1].apply(this, args)]; }
      return args[0];
    };
  }
  function bind$(obj, key, target){
    return function(){ return (target || obj)[key].apply(obj, arguments) };
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
  function clone$(it){
    function fun(){} fun.prototype = it;
    return new fun;
  }
}).call(this);
