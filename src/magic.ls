# woah, oh, oh, it's magic
export async  = (.async!)
# you know
export sync   = (fn)->(...args)-> fn.sync null,...args
# never believe it's not so!
export future = (fn)->(...args)-> fn.future null,...args