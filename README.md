Couchbase
=========

Couchbase SDK for haxe

Alpha release, implements rudimentary features: add, get, set, replace, delete
Primary focus is getting the couchbase interface working, memcache will be updated
in parallel

Couchbase/CouchbaseConfig
-------------------------
- Couchbase interface and configuration

Example
-------
	import couchbase.CouchbaseConfig;
	import couchbase.Couchbase;

	var cconf:CouchbaseConfig = new CouchbaseConfig();
	con = new Couchbase(["localhost"], // list of couchbase hosts 
						"user", // username
						"passwd", // password
						"test", // bucket name
						cconf // configuration settings
					);


Couchbase.add( key:String, value:Dynamic ):String

	response = con.add("mykey","My value");

Couchbase.set( key:String, value:Dynamic ):String

	response = con.set("mykey","My value");

Couchbase.replace( key:String, value:Dynamic ):String

	response = con.replace("mykey","My value");

Couchbase.get( key:String ):Dynamic

	response = con.get("mykey");

Couchbase.delete( key:String ):String

	response = con.delete("mykey");

Memcache/MemcacheConfig
-----------------------

- Memcache interface and configuration

Example
-------
	import memcache.MemcacheConfig;
	import memcache.Memcache;

	var mconf:MemcacheConfig =  new MemcacheConfig();
	var cb = new Memcache(['localhost'], // host list
	                      mconf  // config
	                    );

<TBD>

Codec
- Data conversion interface
- By default Memcache uses CodecToString, and Couchbase uses CodecToJson

Example
-------
	import memcache.codec.*;

	var cdec:Codec = new CodecToString();
	var cconf:CouchbaseConfig = CouchbaseConfig(cdec);

	var cdec:Codec = new CodecToJson();
	var cconf:CouchbaseConfig = CouchbaseConfig(cdec);


Custom Codec
------------
	import tjson.TJSON;

	class CodecToTJSON implements memcache.codec.Codec
	{
		public var codec:Int;

		public function new():Void {
	        codec = 2;
	    }

	    public function encode( data:Dynamic, flags:{flag:Int} ):String {
	        flags.flag = codec;
	        return TJSON.encode(data);
	    }

	    public function decode( data:String, flags:{flag:Int} ):Dynamic {
	        if( flags.flag != codec ) {
	            throw "Expecting codec conversion flag of "+codec + " <"+flags.flag+">";
	        }
	        return TJSON.parse(data);
	    }
	}

	var cdec:Codec = new CodecToTJSON();
	var cconf:CouchbaseConfig = CouchbaseConfig(cdec);

--- More to come ---