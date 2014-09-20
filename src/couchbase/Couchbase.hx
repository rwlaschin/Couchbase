package couchbase;

import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import sys.net.Socket;

import couchbase.CouchbaseConst;
import couchbase.CouchbaseException;

/**
 * A class representing a connection to a Couchbase bucket.
 */
class Couchbase {

    private var sockets:Array<sys.net.Socket>;
    private var hosts:Array<Dynamic>;
    private var user:String;
    private var password:String;
    private var bucket:String;
    private var persistent:Bool;
    private var byter:BytesOutput;
    static inline var port:Int = 8091; // default port

    /**
     * Constructs a new instance of a Couchbase object.
     *
     * @param array An array of hostnames[:port] where the
<pre><code>                Couchbase cluster is running. The port number is
                optional (and only needed if you're using a non-
                standard port).</code></pre>
     * @param string The username used for authentication to
                    the cluster
     * @param string The password used to authenticate to
                      the cluster
     * @param string The name of the bucket to connect to
     * @param boolean If a persistent object should be used or not
     */
    function new ( hosts:Array<String>,  user:String,  password:String,  bucket:String,  persistent:Bool ){
        this.hosts = new Array();
        this.byter = new BytesOutput();

        this.user = user;
        this.password = password;
        this.bucket = bucket;
        this.persistent = persistent;
        var regMatch:EReg = ~/(?:\d{1,3}[.]){3}\d{1,3}$/;

        for( i in 0...hosts.length) {
            var hostinfo = hosts[i].split(':');
            this.hosts[i] = { ip :  regMatch.match(hostinfo[0]) ? hostinfo[0] : new sys.net.Host(hostinfo[0]),
                              port: hostinfo.length < 2 ? Couchbase.port : Std.parseInt(hostinfo[1]) };
        }

        // open a connection
        // get the mapping table
        // close the connection
        // store the table
    }

    private function openConnection( host:Dynamic ) : sys.net.Socket {
        var socket:sys.net.Socket = new sys.net.Socket();
        try {
            socket.connect( host.ip, host.port );
            return socket;
        } catch (e:String) {
            trace(e);
        }
        // leak??
        return null;
    }

    private function sendCommand( socket:sys.net.Socket, command:String, key:String, flags:Int, data:Dynamic ):Void {
        // https://github.com/memcached/memcached/blob/master/doc/protocol.txt

        // <command name> <key> <flags> <exptime> <bytes> [noreply]\r\n
        var message:String = 
            command + " " +
            key + " " +
            this.byter.writeUInt16(flags) + " " + // do I need to do this?
            this.byter.writeString( Json.stringify(data) ) + 
            "\r\n";
            
        socket.write( message );
    }

    private function readResponse( socket:sys.net.Socket ):Void {
        // https://github.com/memcached/memcached/blob/master/doc/protocol.txt

        /*
        - "STORED\r\n"
        - "NOT_STORED\r\n"
        - "EXISTS\r\n"
        - "NOT_FOUND\r\n"
        */
        // socket.

    }

    /**
     * Add a document to the cluster.
     *
     * @param string the identifier to store the document under
     * @param object the document to store
     * @param integer the lifetime of the document (0 == infinite)
     * @param integer wait until the document is persisted to (at least)
<pre><code>                       this many nodes</code></pre>
     * @param integer wait until the document is replicated to (at least)
<pre><code>                       this many nodes</code></pre>
     * @return string the cas value of the object if success
     * @throws \CouchbaseException if an error occurs
     */
    function add ( id:String,  document:Dynamic,  expiry:Int,  persist_to:Int,  replicate_to:Int ):String {
        for( i in 0...this.hosts.length ) {
            var host = this.hosts[i];
            var socket = openConnection( host );
            if( socket != null ) {
                var success = sendCommand( socket );
                if( success != null ) {
                    var response = readResponse( socket );
                    socket.close();
                    // if the socket isn't for the first host, switch them
                    // we'll need to ask for a new host list
                    return response;
                }
            }
        }
        throw new CouchbaseException();
    }

    /**
     * Store a document in the cluster.
     *
     * @param string the identifier to store the document under
     * @param object|string the document to store
     * @param integer the lifetime of the document (0 == infinite)
     * @param string a cas identifier to restrict the store operation
     * @param integer wait until the document is persisted to (at least)
<pre><code>                       this many nodes</code></pre>
     * @param integer wait until the document is replicated to (at least)
<pre><code>                       this many nodes</code></pre>
     * @return string the cas value of the object if success
     * @throws \CouchbaseException if an error occurs
     */
    function set ( id:String,  document:Dynamic,  expiry:Int,  cas:String,  persist_to:Int,  replicate_to:Int ):String;

    /**
     * Store multiple documents in the cluster.
     *
     * @param array an array containing "id" =&gt; "document" pairs
     * @param integer the lifetime of the document (0 == infinite)
     * @param integer wait until the document is persisted to (at least)
<pre><code>                       this many nodes</code></pre>
     * @param integer wait until the document is replicated to (at least)
<pre><code>                       this many nodes</code></pre>
     * @return boolean true if success
     * @throws \CouchbaseException if an error occurs
     */
    function setMulti ( documents:Array<Dynamic>,  expiry:Int,  persist_to:Int,  replicate_to:Int ):Bool;

    /**
     * Replace a document in the cluster.
     *
     * @param string the identifier to store the document under
     * @param object the document to store
     * @param integer the lifetime of the document (0 == infinite)
     * @param string a cas identifier to restrict the replace operation
     * @param integer wait until the document is persisted to (at least)
<pre><code>                       this many nodes</code></pre>
     * @param integer wait until the document is replicated to (at least)
<pre><code>                       this many nodes</code></pre>
     * @return string the cas value of the object if success
     * @throws \CouchbaseException if an error occurs
     */
    function replace ( id:String,  document:Dynamic,  expiry:Int,  cas:String,  persist_to:Int,  replicate_to:Int ):String;

    /**
     * Prepend a document to another document.
     *
     * @param string identifies the document
     * @param object the document to prepend
     * @param integer the lifetime of the document (0 == infinite)
     * @param string a cas identifier to restrict the prepend operation
     * @param integer wait until the document is persisted to (at least)
<pre><code>                       this many nodes</code></pre>
     * @param integer wait until the document is replicated to (at least)
<pre><code>                       this many nodes</code></pre>
     * @return string the cas value of the object if success
     * @throws \CouchbaseException if an error occurs
     */
    function prepend ( id:String,  document:Dynamic,  expiry:Int,  cas:String,  persist_to:Int,  replicate_to:Int ):String;

    /**
     * Append a document to another document.
     *
     * @param string identifies the document
     * @param object the document to append
     * @param integer the lifetime of the document (0 == infinite)
     * @param string a cas identifier to restrict the append operation
     * @param integer wait until the document is persisted to (at least)
<pre><code>                       this many nodes</code></pre>
     * @param integer wait until the document is replicated to (at least)
<pre><code>                       this many nodes</code></pre>
     * @return string the cas value of the object if success
     * @throws \CouchbaseException if an error occurs
     */
    function append ( id:String,  document:Dynamic,  expiry:Int,  cas:String,  persist_to:Int,  replicate_to:Int ):String;

    /**
     * Please use replace with the $cas field specified.
     *
     */
    function cas ( cas:Dynamic,  id:Dynamic,  document:Dynamic,  expiry:Dynamic ):Dynamic;

    /**
     * Retrieve a document from the cluster.
     *
     * @param string identifies the object to retrieve
     * @param callable a callback function to call for missing
<pre><code>            objects. The function signature looks like:
            <code>bool function($res, $id, &amp;$val)</code>
            if the function returns <code>true</code> the value
            returned through $val is returned. Please note that
            the cas field is not updated in these cases.</code></pre>
     * @param string where to store the cas identifier of the object
     * @return object The document from the cluster
     * @throws \CouchbaseException if an error occurs
     */
    function get ( id:String,  callback:Void->Void,  cas:String ):Dynamic;

    /**
     * Retrieve multiple documents from the cluster.
     *
     * @param array an array containing all of the document identifiers
     * @param array an array to store the cas identifiers of the documents
     * @param integer may be 0 or COUCHBASE_GET_PRESERVE_ORDER
     * @return array an array containing the documents
     * @throws \CouchbaseException if an error occurs
     */
    function getMulti ( ids:Array<Dynamic>,  cas:Array<Dynamic>,  flags:Int ):Array<Dynamic>;

    /**
     * Retrieve a replica of a document from the cluster.
     *
     * @param string The document id(s) to get. Pass an array to
<pre><code>               retrieve multiple documets</code></pre>
     * @param string Which strategy to use to pick the replica.
                        Pass in an array to specify extra options
                        to the strategy.
     * @return object The document from the cluster
     * @throws \CouchbaseException if an error occurs
     */
    function getReplica ( id:Dynamic,  strategy:String ):Dynamic;

    /**
     * Retrieve an object from the cache and lock it from modifications.
     *
     * @param string identifies the document
     * @param string where to store the cas identifier
     * @param integer a configuratble lock expiry time (0 == use the
value configured on the server).
     * @return object The requested document from the cluster
     * @throws \CouchbaseException if an error occurs
     */
    function getAndLock ( id:String,  cas:String,  expiry:Int ):Dynamic;

    /**
     * Retrieve and lock multiple documents from the cache.
     *
     * @param array an array containing the identifiers to retrieve
     * @param array where to store the cas identifier
     * @param integer TODO update document for this param
     * @param integer a configuratble lock expiry time (0 == use the
value configured on the server).
     * @return array an array containint the requested documents
     * @throws \CouchbaseException if an error occurs
     */
    function getAndLockMulti ( ids:Array<Dynamic>,  cas:Array<Dynamic>,  flags:Int,  expiry:Int ):Array<Dynamic>;

    /**
     * Retrieve a document from the cluster and update its time to live.
     *
     * @param string identifies the document
     * @param integer the new time to live (0 == infinite)
     * @param string where to store the cas identifier
     * @return object The requested document from the cluster
     * @throws \CouchbaseException if an error occurs
     */
    function getAndTouch ( id:String,  expiry:Int,  cas:String ):Dynamic;

    /**
     * Retrieve multiple documents from the cluster and update their time to live.
     *
     * @param array an array containint the document identifiers
     * @param integer the new time to live (0 == infinite)
     * @param array where to store the cas identifier
     * @return array an array containing the requested documents
     * @throws \CouchbaseException if an error occurs
     */
    function getAndTouchMulti ( ids:Array<Dynamic>,  expiry:Int,  cas:Array<Dynamic> ):Array<Dynamic>;

    /**
     * Unlock a previously locked document.
     *
     * @param string the document to unlock
     * @param string the cas value obtained from getAndLock()
     * @return boolean true upon success
     * @throws \CouchbaseException if an error occurs
     */
    function unlock ( id:String,  cas:String ):Bool;

    /**
     * Touch (update time to live) a document in the cluster.
     *
     * @param string identifies the document
     * @param integer the new time to live (0 == infinite)
     * @return string containing the cas value (note some servers will
               will always return "0" for the cas value)
     * @throws \CouchbaseException if an error occurs
     */
    function touch ( id:String,  expiry:Int ):String;

    /**
     * Touch (update time to live) multiple documents in the cluster.
     *
     * @param array an array containing the document identifiers
     * @param integer the new time to live (0 == infinite)
     * @return boolean true upon success
     * @throws \CouchbaseException if an error occurs
     */
    function touchMulti ( ids:Array<Dynamic>,  expiry:Int ):Bool;

    /**
     * Delete a document from the cluster.
     *
     * @param string the document identifier
     * @param string a cas identifier to restrict the store operation
     * @param integer wait until the document is persisted to (at least)
<pre><code>                       this many nodes</code></pre>
     * @param integer wait until the document is replicated to (at least)
<pre><code>                       this many nodes</code></pre>
     * @return string the cas value representing the delete document if success
     * @throws \CouchbaseException if an error occurs
     */
    function delete ( id:String,  cas:String,  persist_to:Int,  replicate_to:Int ):String;

    /**
     * Increment a numeric value in the cluster.
     *
     * @param string the document identifier
     * @param integer the amount to increment
     * @param boolean should the value be created if it doesn't exist
     * @param integer the time to live for the document (0 == infinite)
     * @param integer the initial value for the counter if it doesn't exist
     * @return integer the new value upon success
     * @throws \CouchbaseException if an error occurs
     */
    function increment ( id:String,  delta:Int,  create:Bool,  expire:Int,  initial:Int ):Int;

    /**
     * Decrement a numeric value in the cluster.
     *
     * @param string the document identifier
     * @param integer the amount to decrement
     * @param boolean should the value be created if it doesn't exist
     * @param integer the time to live for the document (0 == infinite)
     * @param integer the initial value for the counter if it doesn't exist
     * @return integer the new value upon success
     * @throws \CouchbaseException if an error occurs
     */
    function decrement ( id:String,  delta:Int,  create:Bool,  expire:Int,  initial:Int ):Int;

    /**
     * Delete all documents in the bucket.
     *
     * @return boolean true upon success
     * @throws \CouchbaseException if an error occurs
     */
    function flush ( ):Bool;

    /**
     * Issue a get request, but do not wait for responses.
     *
     * @param array the document identifiers to retrieve
     * @param boolean if the cas identifier should be retrieved
     * @param callable function to call per retrieved document
     * @param integer lock expiry time
     * @param boolean if the documents should be locked or not
     * @return boolean true upon success, false otherwise
     * @throws \CouchbaseException if an error occurs
     */
    function getDelayed ( ids:Array<Dynamic>,  with_cas:Bool,  callback:Void->Void,  expiry:Int,  lock:Bool ):Bool;

    /**
     * Fetch the one of the received documents requested from getDelayed.
     *
     * @return array an array representing the next document retrieved,
              or NULL if there are no more documents.
     * @throws \CouchbaseException if an error occurs
     */
    function fetch ( ):Array<Dynamic>;

    /**
     * Fetch the one of the received documents requested from getDelayed.
     *
     * @return array an array representing the documents retrieved,
              or NULL if there are no more documents.
     * @throws \CouchbaseException if an error occurs
     */
    function fetchAll ( ):Array<Dynamic>;

    /**
     * Execute a view request.
     *
     * @todo  update the table above with a description.
     * @param string The design document containing the view to call
     * @param string The view to execute
     * @param array extra options to add to the view request (see above)
     * @param boolean Should error messages be returned upon failures
     * @return array an array with the result of the view request upon success,
              or an array containing an error message
     * @throws \CouchbaseException if an error occurs
     */
    function view ( document:String,  view:String,  options:Array<Dynamic>,  return_errors:Bool ):Array<Dynamic>;

    /**
     * Generate a view request.
     *
     * @param string The design document containing the view to call
     * @param string The view to execute
     * @param array extra options to add to the view request (see view()
<pre><code>                  for more information)</code></pre>
     * @param boolean Should error messages be returned upon failures
     * @return string generated view request in format: "/_design/$doc/_view/$view?stale=ok&amp;..."
     * @throws \CouchbaseException if an error occurs
     */
    function viewGenQuery ( document:String,  view:String,  options:Array<Dynamic>,  return_errors:Bool ):String;

    /**
     * Retrieve statistics information from the cluster.
     *
     * @return array an array containing all "key" =&amp;gt; "value" pairs upon success
     * @throws \CouchbaseException if an error occurs
     */
    function getStats ( ):Array<Dynamic>;

    /**
     * Get the last result code from the extension internals.
     *
     * @return integer An error code representing the last error code as
        seen by libcouchbase
     */
    function getResultCode ( ):Int;

    /**
     * Get a textual representation of the last result from the extension
internals.
     *
     * @return string An textual string describing last error code as
        seen by libcouchbase
     */
    function getResultMessage ( ):String;

    /**
     * Update one of the tunables.
     *
     * @param integer the option to set
     * @param integer the new value for the option
     * @throws \CouchbaseException if an error occurs (e.g illegal option / value)
     */
    function setOption ( option:Int,  value:Int ):Dynamic;

    /**
     * Retrieve the current value of a tunable.
     *
     * @param integer the option to retrieve the value for
     * @return integer The current value for a tunable. See setOption() for a
              description of the legal options to retrieve.
     * @throws \CouchbaseException if an error occurs (e.g illegal option)
     */
    function getOption ( option:Int ):Int;

    /**
     * Get the version numbers of the memcached servers in the cluster.
     *
     * @return array an array containing the memcached version on each node
     * @throws \CouchbaseException if an error occurs
     */
    function getVersion ( ):Array<Dynamic>;

    /**
     * Retrieve the version number of the client.
     *
     * @return string client library version number
     */
    function getClientVersion ( ):String;

    /**
     * Get the number of replicas configured for the bucket.
     *
     * @return integer The number of replicas for the bucket
     * @throws \CouchbaseException if an error occurs
     */
    function getNumReplicas ( ):Int;

    /**
     * Get the name of the servers in the cluster.
     *
     * @return array an array containing all of the servers in the cluster
     * @throws \CouchbaseException if an error occurs
     */
    function getServers ( ):Array<Dynamic>;

    /**
     * Get information about a key in the cluster.
     *
     * @param string The identifier to get information about
     * @param string The cas for the document to get information about
     * @param array an array to store the details about the key
     * @todo  update the documentation about the name and meaning of the details
     * @return boolean true on success, false otherwise
     * @throws \CouchbaseException if an error occurs
     */
    function observe ( id:String,  cas:String,  details:Array<Dynamic> ):Bool;

    /**
     * Get information about multiple keys in the cluster.
     *
     * @param array an array containing the identifiers to look up
     * @param array an array to store the details about the documents
     * @return array with the keys with true on success, false otherwise
     * @throws \CouchbaseException if an error occurs
     */
    function observeMulti ( ids:Array<Dynamic>,  details:Array<Dynamic> ):Array<Dynamic>;

    /**
     * Wait for a document to reach a certain state.
     *
     * @param string the identifier for the document to wait for
     * @param string the cas identifier for the document to wait for
     * @param array an array containing the details. see above
     * @return boolean true on success, false otherwise
     * @throws \CouchbaseException if an error occurs
     */
    function keyDurability ( id:String,  cas:String,  details:Array<Dynamic> ):Bool;

    /**
     * Wait for multiple documents to reach a certain state.
     *
     * @param array an array containing "identifier" =&gt; "cas" pairs
     * @param array is an array containing the options to wait for.
<pre><code>                 See keyDurability() for a description.</code></pre>
     * @return array with the keys with true on success, false otherwise
     * @throws \CouchbaseException if an error occurs
     */
    function keyDurabilityMulti ( ids:Array<Dynamic>,  details:Array<Dynamic> ):Array<Dynamic>;

    /**
     * Retrieve the current operation timeout.
     *
     * @return integer The currently used timeout specified in usec
     */
    function getTimeout ( ):Int;

    /**
     * Specify an operation timeout.
     *
     * @param integer the new operation timeout specified in usec
     */
    function setTimeout ( timeout:Int ):Dynamic;

    /**
     * Get a design document from the cluster.
     *
     * @param string The design document to retrieve
     * @return string the content of the document if success
     * @throws \CouchbaseException if an error occurs
     */
    function getDesignDoc ( name:String ):String;

    /**
     * Store a design document in the cluster.
     *
     * @param string the name of the design document to store
     * @param string the new document to create
     * @return boolean true on success
     * @throws \CouchbaseException if an error occurs
     */
    function setDesignDoc ( name:String,  document:String ):Bool;

    /**
     * Delete the named design document from the cluster.
     *
     * @param string the name of the design document to delete
     * @return boolean true on success
     * @throws \CouchbaseException if an error occurs
     */
    function deleteDesignDoc ( name:String ):Bool;

    /**
     * List all design documents for this bucket
     *
     * @return string A JSON encoded string containing all information about
               the design documents
     * @throws \CouchbaseException if an error occurs
     */
    function listDesignDocs ( ):String;

}
