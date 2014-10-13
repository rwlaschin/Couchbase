rm -rf haxelib
mkdir -p haxelib/couchbase
cp -r src/* haxelib/couchbase

cd haxelib
zip -rq couchbase.zip couchbase
haxelib install couchbase.zip
cd ..
