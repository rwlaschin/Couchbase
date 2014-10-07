
package couchbase;

import haxe.Json;

import memcache.MemcacheSocket;
import memcache.codec.Codec;

class CouchbaseSocket extends MemcacheSocket
{
	// testing, no authentication required
	// telnet localhost 11211

	public function new( host:String, ?port:Null<Int> = null, codec:Codec = null ) {
		super( host, port, null, codec );
	}
}