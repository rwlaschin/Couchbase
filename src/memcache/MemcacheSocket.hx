
package memcache;

import sys.net.Socket;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class Host {
    public var ip(default,default) : sys.net.Host;
    public var port(default,default) : Int;

    function get_ip() { return ip; }
    function get_port() { return port; }

    public function new ( host:String, port:Int) {
        this.ip = new sys.net.Host(host);
        this.port = port;
    }
}

class ProtocolHandler {

    private var state:String;

    private var socket(default,default):sys.net.Socket;
    public var data(default,default):String;
    public var type(default,default):String;
    public var key(default,default):String;
    public var cas(default,default):Int;
    public var length(default,default):Int;

    public function get_socket() { return socket; }

    public function get_type() { return type; }
    public function get_key() { return key; }
    public function get_cas() { return cas; }
    public function get_length() { return length; }
    public function get_data() { return data; }

    public function new():Void {

    }

    public function initialize(socket:sys.net.Socket):Void {
        this.socket = socket;
    }

    public function read(): Void {
        // RESPONSE\r\n
        // VALUE <key> <cas> <length>\r\n<payload>\r\nEND
        state = "TYPE";
        var notdone:Bool = true;
        while( notdone ) {
            switch( state ) {
                case "TYPE": this.readType();
                case "VALUE": this.readValue();
                default: notdone = false;
            }
        }
    }

    public function readType(): Void {
        var response:String = socket.input.readLine();
        trace( 'Read - ' + Std.string(response) );
        var fields:Array<String> = response.split(" ");
        for( i in 0...fields.length) {
            var value:String = fields[i];
            switch(i){
                case 0: type = value;
                        data = value; // for errors there is only 1 field this will setup the data properly
                case 1: key = value;
                case 2: cas = Std.parseInt(value);
                case 3: length = Std.parseInt(value);
            }
        }
        state = type;
    }

    public function readValue(): Void {
        // populate the data, read until 'END' ...
        data = socket.input.readString(length);
        socket.input.readLine(); // eat ending '\r\n'
        var end:String = socket.input.readLine(); // close line
        trace( 'Read ('+length+') - ' + Std.string(data) );
        trace( 'Read - ' + Std.string(end) );
        state = end;
    }
}

class MemcacheSocket {
    private var defaultPort:Int = 11211;
    private var socket:sys.net.Socket = null;
    private var protocolHandler: ProtocolHandler = null;

    private var _host:Host;

    public function new( host:String, _port:Null<Int> = null, handler:ProtocolHandler=null ) {
        this._host = new Host (
                        host,
                        (_port != null ? _port : defaultPort)
                    );
        this.socket = new sys.net.Socket();

        protocolHandler = ( handler == null ) ? new ProtocolHandler() : handler ;
        protocolHandler.initialize(this.socket);

        open();
    }

    private function open() : Void {
        try {
            socket.connect( _host.ip, _host.port );
        } catch (e:Dynamic) {
            trace( Std.string(e) );
        }
    }

    private function close() : Void {
        try {
            socket.close();
        } catch (e:String) {
            trace(e);
        }
    }

    private function encode( data:Dynamic ):String {
        return Std.string(data);
    }

    private function decode( data:String, len:Int ):Dynamic {
        return Std.string(data);
    }

    // http://docs.couchbase.com/couchbase-devguide-2.0/#performing-basic-telnet-operations
    // http://docs.couchbase.com/couchbase-manual-2.0/#testing-couchbase-server-using-telnet

    public function send( command:String,
                           key:String, data:Dynamic = '', expire:Int = 0,
                           flags:Int = 0, cas:Null<Int> = null, noreply:Bool=false ):Void {
        // https://github.com/memcached/memcached/blob/master/doc/protocol.txt

        try {

            // <command name> <key> <flags> <exptime> <bytes> <cas> [noreply] <b:datablock>\r\n
            if( cas == null ) { cas = 0; }

            var encoded:String = this.encode(data);
            /*
                var byter:haxe.io.BytesOutput = new haxe.io.BytesOutput();
                byter.writeString( encoded );
                var data:Bytes = byter.getBytes();
            */

            var message:String = "";
            switch( cmd ) {
                case "delete":
                    message += command;
                    data = '';
                default:
                    message += command + " ";
                    message += key + " ";
                    message += flags + " "; // this can be used to communicate the storage type
                    message += expire + " ";
                    message += encoded.length + " ";
                    message += cas + " ";
                    message += ( noreply  ? "noreply " : "" );
            }

            trace(message + " " + encoded);

            // TODO: Add failure handling/retries
            socket.output.writeString( message + "\r\n" );
            if( data != '' ) { // request (get,gets,delete) should not have data sent
                socket.output.writeString( encoded );
                socket.output.writeString( "\r\n" );
            }
            socket.output.flush();
        } catch (e:Dynamic) {
            trace(Std.string(e));
        }
    }

    public function read():String {
        // https://github.com/memcached/memcached/blob/master/doc/protocol.txt
        protocolHandler.read();
        return protocolHandler.data;
    }

    public function stats():Array<String> {
        var end = "";
        var message: Array<String> = new Array();
        socket.output.writeString("stats\r\n");
        while ( end != "END" ) {
            end = socket.input.readLine();
            if( end != "END" ) { 
                message.push( end );
            }
        }
        return message;
    }
}
