(function(){
  var extname, Handler, Data;
  extname = require('path').extname;
  Handler = require('./handler').Handler;
  exports.Data = Data = (function(superclass){
    var prototype = extend$((import$(Data, superclass).displayName = 'Data', Data), superclass).prototype, constructor = Data;
    Data.files = [];
    Data.handles = compose$([
      (function(it){
        return it === '.json';
      }), extname
    ]);
    prototype.compile = function(src){
      return this.compiled = JSON.parse(src);
    };
    prototype.render = function(template, data){
      return template;
    };
    function Data(){
      Data.superclass.apply(this, arguments);
    }
    return Data;
  }(Handler));
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