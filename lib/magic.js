if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
(function(){
  var async, sync, future, out$ = typeof exports != 'undefined' && exports || this, slice$ = [].slice;
  out$.async = async = function(it){
    return it.async();
  };
  out$.sync = sync = function(fn){
    return function(){
      var args;
      args = slice$.call(arguments);
      return fn.sync.apply(fn, [null].concat(slice$.call(args)));
    };
  };
  out$.future = future = function(fn){
    return function(){
      var args;
      args = slice$.call(arguments);
      return fn.future.apply(fn, [null].concat(slice$.call(args)));
    };
  };
}).call(this);
