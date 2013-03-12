(function(){
  var handlebars, extname, Handler, Template;
  handlebars = require('handlebars');
  extname = require('path').extname;
  Handler = require('../handler').Handler;
  exports.Template = Template = (function(superclass){
    var prototype = extend$((import$(Template, superclass).displayName = 'Template', Template), superclass).prototype, constructor = Template;
    Template.files = [];
    Template.handles = compose$([
      (function(it){
        return it == '.htm' || it == '.html';
      }), extname
    ]);
    Template.provides('main');
    prototype.compile = function(src){
      return this.compiled = handlebars.compile(src);
    };
    prototype.render = function(template, data){
      var blob, ref$, ref1$;
      blob = (ref$ = (ref1$ = require("./data").Data.resolve(this.unext)) != null ? ref1$.output() : void 8) != null
        ? ref$
        : {};
      return template(import$(clone$(blob), data));
    };
    function Template(){
      Template.superclass.apply(this, arguments);
    }
    return Template;
  }(Handler));
  handlebars.registerHelper('extends', function(parent, options){
    var ref$;
    return Template.files[parent.replace('.', '/')].output((ref$ = import$({}, this), ref$.body = options.fn(this), ref$));
  });
  function extend$(sub, sup){
    function fun(){} fun.prototype = (sub.superclass = sup).prototype;
    (sub.prototype = new fun).constructor = sub;
    if (typeof sup.extended == 'function') sup.extended(sub);
    return sub;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
  function compose$(fs){
    return function(){
      var i, args = arguments;
      for (i = fs.length; i > 0; --i) { args = [fs[i-1].apply(this, args)]; }
      return args[0];
    };
  }
  function clone$(it){
    function fun(){} fun.prototype = it;
    return new fun;
  }
}).call(this);
