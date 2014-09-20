
package couchbase;

import memcache.MemcacheSocket;

class CouchbaseSocket extends MemcacheSocket
{
	// testing, no authentication required
	// telnet localhost 11211

	public function new( host:String, ?port:Null<Int> = null ) {
		super( host, port );
	}

	public function authenticate(user:String,password:String):Void {

	}

}