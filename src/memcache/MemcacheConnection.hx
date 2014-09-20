
package memcache;

import managers.Connection;
import sys.net.Socket;

class MemcacheConnection extends Connection {

    public class Host {
        public var host(default,never) : String;
        public var port(default,never) : Int;

        function get_host() { return host; }
        function get_port() { return port; }

        public new ( host:String, port:Int) {
            this.host = ()
            this.port = port;
        }
    };

    private inline var regMatch:EReg = ~/(?:\d{1,3}[.]){3}\d{1,3}$/;
    private inline var defaultPort:Int = 11211;
    private inline var socket:sys.net.Socket = null;

    private var host:Host;

    public function new( host:String, ?port:Null<Int> = null ) {
        this.host = new Host (
                        regMatch.match(host) ? host : (new sys.net.Host(host)).toString(),
                        port ? port : defaultPort 
                    );
        this.socket = new sys.net.Socket();
        open();
    }

    private function open() : Void {
        try {
            socket.connect( host.ip, host.port );
        } catch (e:String) {
            trace(e);
        }
    }

    private function close() : Void {
        try {
            socket.close();
        } catch (e:String) {
            trace(e);
        }
    }

    private function send( command:String,
                           key:String, data:Dynamic, expire:Int
                           ?flags:Int = 0, ?cas:Null<Int> = null, ?noreply:Bool=false ):Void {
        // https://github.com/memcached/memcached/blob/master/doc/protocol.txt

        // <command name> <key> <flags> <exptime> <bytes> <cas> [noreply] <b:datablock>\r\n
        if( cas == null ) { cas = 0 );
        var byter:haxe.io.BytesOutput = new haxe.io.BytesOutput();

        byter.writeString( this.formatData(sys.parseString(data) ) );
        var data = byter.getBytes();
        var message:String = "";
        message += command + " ";
        message += key + " ";
        message += flags + " ";
        message += expire + " ";
        message += byter.length + " ";
        message += cas + " ";
        message += ( noreply  ? "noreply " : "" );
        message += data; 
        message += "\r\n";

        trace(message);

        // TODO: Add failure handling/retries
        socket.write( message );
    }

    private function read():String {
        // https://github.com/memcached/memcached/blob/master/doc/protocol.txt

        // TODO: Add failure handling/retries
        var message = "";
        var readByte : Int = -1;
        while( readByte != 0 ) {
            readByte = socket.input.readByte();
            message += String.fromCharCode(readByte);
            if( readByte != 0x20 && readByte != 0x0D && readByte != 0x0A && readByte != 0 ) {
                continue;
            }
            trace("Read so far - " + message);
            var type:String = message;
            switch(type) {
                default: 
                case " ": case "\r" : case "\n":
                    message = ""; // remove and keep processing
                    break;
                case "NOT_STORED": case "NOT_FOUND":
                    message = "";
                    return "Failed - " + type;
                case "STORED": case "EXISTS": case "TOUCHED":
                    message = "";
                    return type;
            }
        }
        return "";
    }
}