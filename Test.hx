package ;

import couchbase.Couchbase;
import couchbase.CouchbaseConst;

// These are low level for handling the protocol
import couchbase.CouchbaseSocket;
import memcache.MemcacheSocket;

// User level interfaces
import couchbase.Couchbase;
import memcache.Memcache;

class Test{
	static function main(){
		Test.MemcacheSocketTest();
		Test.MemcacheTest();

		Test.CouchbaseSocketTest();
		Test.CouchbaseTest();
	}

	static function CouchbaseTest() {
		/*var cb = new Couchbase(['localhost'],"user","password","default",false);
		trace(CouchbaseConst.COUCHBASE_SUCCESS);
		var cb = new Couchbase(['localhost:8091'],"user","password","default",false);
		trace(CouchbaseConst.COUCHBASE_SUCCESS);
		var cb = new Couchbase(['127.0.0.1'],"user","password","default",false);
		trace(CouchbaseConst.COUCHBASE_SUCCESS);
		var cb = new Couchbase(['127.0.0.1:8091'],"user","password","default",false);
		trace(CouchbaseConst.COUCHBASE_SUCCESS);*/
	}

	static function CouchbaseSocketTest() {
		// create Socket
		var con:CouchbaseSocket;

		try {
			con = new CouchbaseSocket("localhost",11211);
			// just a string
			con.send('add','mynewstring','This is the data I\'m storing');
		} catch ( e:Dynamic ) {
			trace(Std.string(e));
		}
		// send command
		
	}

	static function MemcacheTest() {
		/*var cb = new Memcache(['localhost'],"user","password","default",false);*/
	}

	static function MemcacheSocketTest() {
		// create Socket
		var con:MemcacheSocket;
		try {
			con = new MemcacheSocket("localhost",11211);
			// send command
			// con.send('add','mynewstring',"This is the data I'm storing");
		} catch ( e:Dynamic ) {
			trace(Std.string(e));
		}
	}
}
