
package couchbase;

import haxe.Json;

import memcache.MemcacheSocket;

class CouchbaseSocket extends MemcacheSocket
{
	// testing, no authentication required
	// telnet localhost 11211

	public function new( host:String, ?port:Null<Int> = null ) {
		super( host, port );
	}

	private override function encode( data:Dynamic ):String {
		return Json.stringify(data);
	}

	private override function decode( data:String ):Dynamic {
		try { return Json.parse(data); }
		catch (e:Dynamic) { return data; }
	}

}