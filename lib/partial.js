if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
(function(){
  var handlebars, extname, async, Template, Partial;
  handlebars = require('handlebars');
  extname = require('path').extname;
  async = require('./magic').async;
  Template = require('./template').Template;
  exports.Partial = Partial = (function(superclass){
    var prototype = extend$((import$(Partial, superclass).displayName = 'Partial', Partial), superclass).prototype, constructor = Partial;
    Partial.files = [];
    Partial.handles = compose$([
      (function(it){
        return it === '.part';
      }), extname
    ]);
    prototype.compile = function(src){
      return handlebars.registerPartial(this.unext.replace('/', '.'), handlebars.compile(src));
    };
    prototype.render = async(function(data){
      throw new TypeError("Partial template " + this.path + " cannot be directly rendered.");
    });
    function Partial(){
      Partial.superclass.apply(this, arguments);
    }
    return Partial;
  }(Template));
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
}).call(this);
