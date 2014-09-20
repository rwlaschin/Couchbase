
package memcache;

import memcache.MemcacheSocket;

import haxe.Utf8;
import Math;

class Memcache
{
    private var connections:Array<MemcacheSocket>;

    // Overload this for a better indexing algo
    private function idToIndex( id: String ) : Int {
        var key:Int = 0;
        for( i in 0...id.length ) {
            key += haxe.Utf8.charCodeAt(id,i);
        }
        return key % connections.length;
    }

    /**
     * Constructs a new instance of a Memcache object.
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
    public function new ( hosts:Array<String> ){
        this.connections = new Array();
        for( i in 0...hosts.length) {
            var values = hosts[i].split(":");
            this.connections.push( new MemcacheSocket( 
                                   values[0],
                                   ( values.length >= 2 ? Std.parseInt(values[1]) : null ) ) );
        }
    }

    private function _do( cmd, id, flags, document
        // prolly need to pass in a handler
     ){
        var hostIndex = idToIndex(id);
        var connection = connections[hostIndex];
        connection.send( cmd, id, flags, document );
        return connection.read();
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
    function add ( id:String, document:Dynamic, expiry:Int ):String {
        return _do( 'add', id, 0, document );
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
    function set ( id:String,  document:Dynamic,  expiry:Int,  cas:String,  persist_to:Int,  replicate_to:Int ):String { 
        return _do( 'set', id, 0, document );
    }

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
    function setMulti ( documents:Array<Dynamic>,  expiry:Int,  persist_to:Int,  replicate_to:Int ):Bool { return false; }

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
    function replace ( id:String,  document:Dynamic,  expiry:Int,  cas:String,  persist_to:Int,  replicate_to:Int ):String { return ""; }

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
    function prepend ( id:String,  document:Dynamic,  expiry:Int,  cas:String,  persist_to:Int,  replicate_to:Int ):String { return ""; }

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
    function append ( id:String,  document:Dynamic,  expiry:Int,  cas:String,  persist_to:Int,  replicate_to:Int ):String { return ""; }

    /**
     * Please use replace with the $cas field specified.
     *
     */
    function cas ( cas:Dynamic,  id:Dynamic,  document:Dynamic,  expiry:Dynamic ):Dynamic { return {}; }

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
    function get ( id:String,  callback:Void->Void,  cas:String ):Dynamic { 
        return {};
     }

    /**
     * Retrieve multiple documents from the cluster.
     *
     * @param array an array containing all of the document identifiers
     * @param array an array to store the cas identifiers of the documents
     * @param integer may be 0 or COUCHBASE_GET_PRESERVE_ORDER
     * @return array an array containing the documents
     * @throws \CouchbaseException if an error occurs
     */
    function getMulti ( ids:Array<Dynamic>,  cas:Array<Dynamic>,  flags:Int ):Array<Dynamic> { return []; }

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
    function getReplica ( id:Dynamic,  strategy:String ):Dynamic { return {}; }

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
    function getAndLock ( id:String,  cas:String,  expiry:Int ):Dynamic { return {}; }

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
    function getAndLockMulti ( ids:Array<Dynamic>,  cas:Array<Dynamic>,  flags:Int,  expiry:Int ):Array<Dynamic> { return []; }

    /**
     * Retrieve a document from the cluster and update its time to live.
     *
     * @param string identifies the document
     * @param integer the new time to live (0 == infinite)
     * @param string where to store the cas identifier
     * @return object The requested document from the cluster
     * @throws \CouchbaseException if an error occurs
     */
    function getAndTouch ( id:String,  expiry:Int,  cas:String ):Dynamic { return {}; }

    /**
     * Retrieve multiple documents from the cluster and update their time to live.
     *
     * @param array an array containint the document identifiers
     * @param integer the new time to live (0 == infinite)
     * @param array where to store the cas identifier
     * @return array an array containing the requested documents
     * @throws \CouchbaseException if an error occurs
     */
    function getAndTouchMulti ( ids:Array<Dynamic>,  expiry:Int,  cas:Array<Dynamic> ):Array<Dynamic> { return []; }

    /**
     * Unlock a previously locked document.
     *
     * @param string the document to unlock
     * @param string the cas value obtained from getAndLock()
     * @return boolean true upon success
     * @throws \CouchbaseException if an error occurs
     */
    function unlock ( id:String,  cas:String ):Bool { return false; }

    /**
     * Touch (update time to live) a document in the cluster.
     *
     * @param string identifies the document
     * @param integer the new time to live (0 == infinite)
     * @return string containing the cas value (note some servers will
               will always return "0" for the cas value)
     * @throws \CouchbaseException if an error occurs
     */
    function touch ( id:String,  expiry:Int ):String { return ""; }

    /**
     * Touch (update time to live) multiple documents in the cluster.
     *
     * @param array an array containing the document identifiers
     * @param integer the new time to live (0 == infinite)
     * @return boolean true upon success
     * @throws \CouchbaseException if an error occurs
     */
    function touchMulti ( ids:Array<Dynamic>,  expiry:Int ):Bool { return false; }

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
    function delete ( id:String,  cas:String,  persist_to:Int,  replicate_to:Int ):String { return ""; }

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
    function increment ( id:String,  delta:Int,  create:Bool,  expire:Int,  initial:Int ):Int { return 0; }

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
    function decrement ( id:String,  delta:Int,  create:Bool,  expire:Int,  initial:Int ):Int { return 0; }

    /**
     * Delete all documents in the bucket.
     *
     * @return boolean true upon success
     * @throws \CouchbaseException if an error occurs
     */
    function flush ( ):Bool { return false; }

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
    function getDelayed ( ids:Array<Dynamic>,  with_cas:Bool,  callback:Void->Void,  expiry:Int,  lock:Bool ):Bool { return false; }

    /**
     * Fetch the one of the received documents requested from getDelayed.
     *
     * @return array an array representing the next document retrieved,
              or NULL if there are no more documents.
     * @throws \CouchbaseException if an error occurs
     */
    function fetch ( ):Array<Dynamic> { return []; }

    /**
     * Fetch the one of the received documents requested from getDelayed.
     *
     * @return array an array representing the documents retrieved,
              or NULL if there are no more documents.
     * @throws \CouchbaseException if an error occurs
     */
    function fetchAll ( ):Array<Dynamic> { return []; }

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
    function view ( document:String,  view:String,  options:Array<Dynamic>,  return_errors:Bool ):Array<Dynamic> { return []; }

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
    function viewGenQuery ( document:String,  view:String,  options:Array<Dynamic>,  return_errors:Bool ):String { return ""; }

    /**
     * Retrieve statistics information from the cluster.
     *
     * @return array an array containing all "key" =&amp;gt; "value" pairs upon success
     * @throws \CouchbaseException if an error occurs
     */
    function getStats ( ):Array<Dynamic> { return []; }

    /**
     * Get the last result code from the extension internals.
     *
     * @return integer An error code representing the last error code as
        seen by libcouchbase
     */
    function getResultCode ( ):Int { return 0; }

    /**
     * Get a textual representation of the last result from the extension
internals.
     *
     * @return string An textual string describing last error code as
        seen by libcouchbase
     */
    function getResultMessage ( ):String { return ""; }

    /**
     * Update one of the tunables.
     *
     * @param integer the option to set
     * @param integer the new value for the option
     * @throws \CouchbaseException if an error occurs (e.g illegal option / value)
     */
    function setOption ( option:Int,  value:Int ):Dynamic { return {}; }

    /**
     * Retrieve the current value of a tunable.
     *
     * @param integer the option to retrieve the value for
     * @return integer The current value for a tunable. See setOption() for a
              description of the legal options to retrieve.
     * @throws \CouchbaseException if an error occurs (e.g illegal option)
     */
    function getOption ( option:Int ):Int { return 0; }

    /**
     * Get the version numbers of the memcached servers in the cluster.
     *
     * @return array an array containing the memcached version on each node
     * @throws \CouchbaseException if an error occurs
     */
    function getVersion ( ):Array<Dynamic> { return []; }

    /**
     * Retrieve the version number of the client.
     *
     * @return string client library version number
     */
    function getClientVersion ( ):String { return ""; }

    /**
     * Get the number of replicas configured for the bucket.
     *
     * @return integer The number of replicas for the bucket
     * @throws \CouchbaseException if an error occurs
     */
    function getNumReplicas ( ):Int { return 0; }

    /**
     * Get the name of the servers in the cluster.
     *
     * @return array an array containing all of the servers in the cluster
     * @throws \CouchbaseException if an error occurs
     */
    function getServers ( ):Array<Dynamic> { return []; }

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
    function observe ( id:String,  cas:String,  details:Array<Dynamic> ):Bool { return false; }

    /**
     * Get information about multiple keys in the cluster.
     *
     * @param array an array containing the identifiers to look up
     * @param array an array to store the details about the documents
     * @return array with the keys with true on success, false otherwise
     * @throws \CouchbaseException if an error occurs
     */
    function observeMulti ( ids:Array<Dynamic>,  details:Array<Dynamic> ):Array<Dynamic> { return []; }

    /**
     * Wait for a document to reach a certain state.
     *
     * @param string the identifier for the document to wait for
     * @param string the cas identifier for the document to wait for
     * @param array an array containing the details. see above
     * @return boolean true on success, false otherwise
     * @throws \CouchbaseException if an error occurs
     */
    function keyDurability ( id:String,  cas:String,  details:Array<Dynamic> ):Bool { return false; }

    /**
     * Wait for multiple documents to reach a certain state.
     *
     * @param array an array containing "identifier" =&gt; "cas" pairs
     * @param array is an array containing the options to wait for.
<pre><code>                 See keyDurability() for a description.</code></pre>
     * @return array with the keys with true on success, false otherwise
     * @throws \CouchbaseException if an error occurs
     */
    function keyDurabilityMulti ( ids:Array<Dynamic>,  details:Array<Dynamic> ):Array<Dynamic> { return []; }

    /**
     * Retrieve the current operation timeout.
     *
     * @return integer The currently used timeout specified in usec
     */
    function getTimeout ( ):Int { return 0; }

    /**
     * Specify an operation timeout.
     *
     * @param integer the new operation timeout specified in usec
     */
    function setTimeout ( timeout:Int ):Dynamic { return {}; }

    /**
     * Get a design document from the cluster.
     *
     * @param string The design document to retrieve
     * @return string the content of the document if success
     * @throws \CouchbaseException if an error occurs
     */
    function getDesignDoc ( name:String ):String { return ""; }

    /**
     * Store a design document in the cluster.
     *
     * @param string the name of the design document to store
     * @param string the new document to create
     * @return boolean true on success
     * @throws \CouchbaseException if an error occurs
     */
    function setDesignDoc ( name:String,  document:String ):Bool { return false; }

    /**
     * Delete the named design document from the cluster.
     *
     * @param string the name of the design document to delete
     * @return boolean true on success
     * @throws \CouchbaseException if an error occurs
     */
    function deleteDesignDoc ( name:String ):Bool { return false; }

    /**
     * List all design documents for this bucket
     *
     * @return string A JSON encoded string containing all information about
               the design documents
     * @throws \CouchbaseException if an error occurs
     */
    function listDesignDocs ( ):String { return ""; }

}