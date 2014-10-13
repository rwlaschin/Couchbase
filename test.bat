: # This is a bash/bat compatible shell
: # and will work on both unix based and windows
: # systems

haxe -cp src -cp . -main Test -neko Test.n
neko Test.n