(function(){
  var extname, async, Data, map, fold, each, GlobalData;
  extname = require('path').extname;
  async = require('./magic').async;
  Data = require('./data').Data;
  map = require('prelude-ls').map;
  fold = require('prelude-ls').fold;
  each = require('prelude-ls').each;
  exports.GlobalData = GlobalData = (function(superclass){
    var prototype = extend$((import$(GlobalData, superclass).displayName = 'GlobalData', GlobalData), superclass).prototype, constructor = GlobalData;
    GlobalData.files = [];
    GlobalData.handles = compose$([
      (function(it){
        return it === '.gjson';
      }), extname
    ]);
    GlobalData.collapse = function(){
      var _, f;
      return fold(curry$(function(x$, y$){
        return import$(x$, y$);
      }), {}, (function(){
        var ref$, results$ = [];
        for (_ in ref$ = this.files) {
          f = ref$[_];
          results$.push(f.output());
        }
        return results$;
      }.call(this)));
    };
    function GlobalData(){
      GlobalData.superclass.apply(this, arguments);
    }
    return GlobalData;
  }(Data));
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
}).call(this);
