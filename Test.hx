package ;

import couchbase.Couchbase;
import couchbase.CouchbaseConst;
import couchbase.CouchbaseClusterManager;

// These are low level for handling the protocol
import couchbase.CouchbaseSocket;
import memcache.MemcacheSocket;

// User level interfaces
import couchbase.Couchbase;
import memcache.Memcache;

import couchbase.Couchbase.CouchbaseConfig;


class Test{
	static function main(){
		Test.MemcacheSocketTest();
		Test.MemcacheTest();

		Test.CouchbaseSocketTest();
		Test.CouchbaseTest();
	}

	static function CouchbaseTest() {
		var con:Couchbase;
		try {
			var mixed1:Array<Dynamic> = ["STORED", ["This is the data I'm storing"] ];
			var mixed2:Array<Dynamic> = ["NOT_STORED","STORED", { msg : "This is the data I'm storing" },"DELETED"];
			var mixed3:Array<Dynamic> = ["STORED", 100000, 'DELETED' ];
			var data:Array<Dynamic> = [
				{ key : "cb_mynewnumber",
				  value : 100000, 
				  result : mixed3,
				  cmd : [ 'add', 'get', 'delete' ] 
				},
				{ key : "cb_mynewstring",
				  value : "This is the data I'm storing", 
				  result : ["STORED", "This is the data I'm storing", 'DELETED' ],
				  cmd : [ 'add', 'get', 'delete' ] 
				},
				{ key : "cb_mynewjson",
				  value : ["This is the data I'm storing"], 
				  result : mixed1,
				  cmd : [ 'add', 'get' ] 
				},
				{ key : "cb_mynewjson",
				  value : { msg : "This is the data I'm storing" }, 
				  result : mixed2,
				  cmd : [ 'add', 'set', 'get', 'delete' ]
				}
				,
				{ key : "cb_DoesntExist",
				  value : null, 
				  result : [null],
				  cmd : ['get' ]
				}
			];

			// command list: add, set, get, delete
			//               replace, cas, gets(for cas value)

			con = new Couchbase(["localhost"], "admin","aceace","test",new CouchbaseConfig());
			for( i in 0...data.length ) {
				var testInfo:Dynamic = data[i];
				var cmds:Array<String> = testInfo.cmd;
				var results:Array<String> = testInfo.result;
				for(j in 0...cmds.length ) {
					var response:Dynamic;
					var cmd:String = cmds[j];
					var result:String = results[j];
					trace( "Test <"+ testInfo.key +"> - cmd <"+ cmd +">" );
					switch( cmd ) {
						case "add": response = con.add(testInfo.key,testInfo.value);
						case "set": response = con.set(testInfo.key,testInfo.value);
						case "replace": response = con.replace(testInfo.key,testInfo.value);
						case "get": response = con.get(testInfo.key);
						case "delete": response = con.delete(testInfo.key);
						default: response = "Error: <" + cmd + "> not Supported, yet";
					}
					var passed:Bool = ( Std.string( result ) == Std.string( response ) );
					if( passed == false ) {
						trace( "Expected - " + Std.string( result ) );
						trace( "Received - " + Std.string( response ) );
					}
					trace( passed ? "Passed" : "Failed" );
				}
			}
			
		} catch ( e:Dynamic ) {
			trace( Std.string(e) );
		}
	}

	static function CouchbaseSocketTest() {
		// create Socket
		var con:CouchbaseSocket;
		var resp;

		try { // Test, good host name
			con = new CouchbaseSocket("localhost");
			var resp = con.stats();
			trace( "Passed");
		} catch (e:Dynamic) {
			trace( "Failed - " + Std.string( e ) );
		}

		try { // Test, good ip 
			con = new CouchbaseSocket("127.0.0.1");
			var resp = con.stats();
			trace( "Passed");
		} catch (e:Dynamic) {
			trace( "Failed - " + Std.string( e ) );
		}

		try { // Test, bad host
			con = new CouchbaseSocket("foonuggets");
			var resp = con.stats();
			trace( "Failed - " + Std.string(resp) );
		} catch (e:Dynamic) {
			trace( "Passed");
		}

		try { // Test, bad port
			con = new CouchbaseSocket("localhost",10001);
			var resp = con.stats();
			trace( "Failed - " + Std.string(resp) );
		} catch (e:Dynamic) {
			trace( "Passed");
		}

		try {
			var mixed1:Array<Dynamic> = ["STORED", ["This is the data I'm storing"] ];
			var mixed2:Array<Dynamic> = ["NOT_STORED","STORED", { msg : "This is the data I'm storing" },"DELETED"];
			var mixed3:Array<Dynamic> = ["STORED", 100000, 'DELETED' ];
			var data:Array<Dynamic> = [
				{ key : "cb_mynewnumber",
				  value : 100000, 
				  result : mixed3,
				  cmd : [ 'add', 'get', 'delete' ] 
				},
				{ key : "cb_mynewstring",
				  value : "This is the data I'm storing", 
				  result : ["STORED", "This is the data I'm storing", 'DELETED' ],
				  cmd : [ 'add', 'get', 'delete' ] 
				},
				{ key : "cb_mynewjson",
				  value : ["This is the data I'm storing"], 
				  result : mixed1,
				  cmd : [ 'add', 'get' ] 
				},
				{ key : "cb_mynewjson",
				  value : { msg : "This is the data I'm storing" }, 
				  result : mixed2,
				  cmd : [ 'add', 'set', 'get', 'delete' ]
				}
			];

			// command list: add, set, get, delete
			//               replace, cas, gets(for cas value)

			con = new CouchbaseSocket("localhost",11211);
			for( i in 0...data.length ) {
				var testInfo:Dynamic = data[i];
				var cmds:Array<String> = testInfo.cmd;
				var results:Array<String> = testInfo.result;
				for(j in 0...cmds.length ) {
					var cmd:String = cmds[j];
					var result:String = results[j];
					trace( "Test <"+ testInfo.key +"> - cmd <"+ cmd +">" );
					switch( cmd ) {
						case "add": con.send(cmd,testInfo.key,testInfo.value);
						case "set": con.send(cmd,testInfo.key,testInfo.value);
						case "replace": con.send(cmd,testInfo.key,testInfo.value);
						case "get": con.send(cmd,testInfo.key);
						case "delete": con.send(cmd,testInfo.key);
					}
					var response = con.read();
					var passed:Bool = ( Std.string( result ) == Std.string( response ) );
					if( passed == false ) {
						trace( "Expected - " + Std.string( result ) );
						trace( "Received - " + Std.string( response ) );
					}
					trace( passed ? "Passed" : "Failed" );
				}
			}
			
		} catch ( e:Dynamic ) {
			trace( Std.string(e) );
		}
	}

	static function MemcacheTest() {
		/*
			var cb = new Memcache(['localhost'],"user","password","default",false);
		*/
	}

	static function MemcacheSocketTest() {
		// create Socket
		var con:MemcacheSocket;
		var resp;

		try { // Test, good host name
			con = new MemcacheSocket("localhost");
			var resp = con.stats();
			trace( "Passed");
		} catch (e:Dynamic) {
			trace( "Failed - " + Std.string( e ) );
		}

		try { // Test, good ip 
			con = new MemcacheSocket("127.0.0.1");
			var resp = con.stats();
			trace( "Passed");
		} catch (e:Dynamic) {
			trace( "Failed - " + Std.string( e ) );
		}

		try { // Test, bad host
			con = new MemcacheSocket("foonuggets");
			var resp = con.stats();
			trace( "Failed - " + Std.string(resp) );
		} catch (e:Dynamic) {
			trace( "Passed Exception - " + Std.string( e ) );
		}

		try { // Test, bad port
			con = new MemcacheSocket("localhost",10001);
			var resp = con.stats();
			trace( "Failed - " + Std.string(resp) );
		} catch (e:Dynamic) {
			trace( "Passed Exception - " + Std.string( e ) );
		}

		try {
			var data:Array<Dynamic> = [
				{ key : "mc_mynewstring",
				  value : "This is the data I'm storing", 
				  result : ["STORED","This is the data I'm storing"],
				  cmd : [ 'add', 'get' ] 
				},
				{ key : "mc_mynewstring",
				  value : "This is the data I'm storing", 
				  result : ["NOT_STORED","STORED","This is the data I'm storing","DELETED"], 
				  cmd : [ 'add', 'set', 'get', 'delete' ]
				}
			];

			// command list: add, set, get, delete
			//               replace, cas, gets(for cas value)

			con = new MemcacheSocket("localhost",11211);
			for( i in 0...data.length ) {
				var testInfo:Dynamic = data[i];
				var cmds:Array<String> = testInfo.cmd;
				var results:Array<String> = testInfo.result;
				for(j in 0...cmds.length ) {
					var cmd:String = cmds[j];
					var result:String = results[j];
					trace( "Test <"+ testInfo.key +"> - cmd <"+ cmd +">" );
					switch( cmd ) {
						case "add": con.send(cmd,testInfo.key,testInfo.value);
						case "set": con.send(cmd,testInfo.key,testInfo.value);
						case "replace": con.send(cmd,testInfo.key,testInfo.value);
						case "get": con.send(cmd,testInfo.key);
						case "delete": con.send(cmd,testInfo.key);
					}
					var response = con.read();
					var passed = ( Std.string( result ) == Std.string( response ) );
					if( passed == false ) {
						trace( "Expected - " + Std.string( result ) );
						trace( "Received - " + Std.string( response ) );
					}
					trace( passed  ? "Passed" : "Failed" );
				}
			}
			
		} catch ( e:Dynamic ) {
			trace( Std.string(e) );
		}
	}
}
