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
		var resp;

		try {
			// command list: add, set, get, delete
			//               replace, cas, gets(for cas value)
			con = new CouchbaseSocket("localhost",11211);
			// just a string
			con.send('add','mynewstring','This is the data I\'m storing');
			var resp = con.read();
			trace( "Expected - STORED, Got - " + Std.string(resp) );

			con.send('add','mynewstring','This is the data I\'m storing');
			var resp = con.read();
			trace( "Expected - NOT_STORED, Got - " + Std.string(resp) );

			con.send('set','mynewstring','This is the data I\'m storing');
			var resp = con.read();
			trace( Std.string(resp) );

			con.send('set','mynewstring1','This is the data I\'m storing');
			var resp = con.read();
			trace( Std.string(resp) );

			con.send('get','mynewstring');
			var resp = con.read();
			trace( Std.string(resp) );

			con.send('get','notexisting');
			var resp = con.read();
			trace( Std.string(resp) );

			con.send('delete','mynewstring');
			var resp = con.read();
			trace( Std.string(resp) );

			con.send('delete','mynewstring1');
			var resp = con.read();
			trace( Std.string(resp) );

			con.send('delete','notexisting');
			var resp = con.read();
			trace( Std.string(resp) );

		} catch ( e:Dynamic ) {
			trace( Std.string(e) );
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
