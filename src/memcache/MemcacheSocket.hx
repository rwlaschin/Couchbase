
package memcache;

import sys.net.Socket;

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

    public function new(debug:Bool=false):Void {
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
        // dtrace( 'Read - ' + Std.string(response) );
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
        // dtrace( 'Read ('+length+') - ' + Std.string(data) );
        // dtrace( 'Read - ' + Std.string(end) );
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
            throw e;
        }
    }

    private function close() : Void {
        try {
            socket.close();
        } catch (e:String) {
            throw e;
        }
    }

    private function encode( data:Dynamic ):String {
        return Std.string(data);
    }

    private function decode( data:String ):Dynamic {
        return Std.string(data);
    }

    // http://docs.couchbase.com/couchbase-devguide-2.0/#performing-basic-telnet-operations
    // http://docs.couchbase.com/couchbase-manual-2.0/#testing-couchbase-server-using-telnet

    public function send( command:String,
                           key:String, data:Dynamic = '', expire:Int = 0,
                           flags:Int = 0, cas:Int = 0, noreply:Bool=false ):Void {
        // https://github.com/memcached/memcached/blob/master/doc/protocol.txt

        try {

            // <command name> <key> <flags> <exptime> <bytes> <cas> [noreply] <b:datablock>\r\n
            var encoded:String = this.encode(data);
            /*var byteOutput:BytesOutput = new BytesOutput();
            byteOutput.writeString( encoded );
            var bytes = byteOutput.getBytes();*/

            var message:String = command + " ";
            switch( command ) {
                case "delete":
                    message += key;
                    data = '';
                default:
                    message += key + " ";
                    message += flags + " "; // this can be used to communicate the storage type
                    message += expire + " ";
                    message += encoded.length + " ";
                    message += cas + " ";
                    message += ( noreply  ? "noreply " : "" );
            }

            // dtrace(message + " " + encoded);

            // TODO: Add failure handling/retries
            socket.output.writeString( message + "\r\n" );
            if( data != '' ) { // request (get,gets,delete) should not have data sent
                socket.output.writeString( encoded );
                socket.output.writeString( "\r\n" );
            }
            socket.output.flush();
        } catch (e:Dynamic) {
            throw e;
        }
    }

    public function read():String {
        // https://github.com/memcached/memcached/blob/master/doc/protocol.txt
        protocolHandler.read();
        return this.decode(protocolHandler.data);
    }

    public function stats( cmd:String='' ):Array<String> {
        var response: Array<String> = new Array();
        var message = "";
        message += "stats";
        if ( cmd != '' ) { 
            message += " " + cmd;
        }
        message += "\r\n";
        socket.output.writeString(message);
        while ( true ) { // infinite loop on error?
            var end:String = socket.input.readLine();
            if( end != "END" ) {
                response.push( end );
            } else {
                break;
            }
        }
        return response;
    }
}
