package couchbase;

import haxe.Http;
import haxe.crypto.Base64;
import haxe.io.Bytes;
import sys.net.Socket;


/**
 * A class to wrap the management of a Couchbase cluster.
 */
class CouchbaseClusterManager {

    /*
        haxe.Http -- sending custom requests
        new (url)
        // addHeader/setHeader
        //  + Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ== notes: Base64.encrypt( Bytes.ofString('user:pass') ), encode RFC2045-MIME
        // addParameter/setParameter
        // setPostData
        // fileTransfer // sets file
        // method != NULL - use method type
    */

    private var socket:sys.net.Socket;
    private var master:haxe.Http;

    private var authentication:String;

    // http://docs.couchbase.com/couchbase-devguide-2.5/index.html#connecting-with-couchbase-sdks
    // http://docs.couchbase.com/couchbase-devguide-2.5/index.html#create-your-first-bucket
    private var defaultHost:String = 'localhost';
    private var defaultPort:Int = 8091;

    /**
     * Create a new instance of the CouchbaseClusterManager.
     *
     * @param array This is an array of hostnames[:port] where the
<pre><code>                Couchbase cluster is running. The port number is
                optional (and only needed if you're using a non-
                standard port).</code></pre>
     * @param string This is the username used for authentications towards
                    the cluster
     * @param string This is the password used to authenticate towards
                      the cluster
     */
    function new ( hosts:Array<Dynamic>,  user:String,  password:String ) {
        // http or https??
        master = new haxe.Http( 'http://'+Std.string(defaultHost)+':'+Std.string(defaultPort) + '/pools' );
        socket = new sys.net.Socket();

        authentication = Base64.encode( Bytes.ofString(user + ':' + password) );
    }

    /**
     * Get information about the cluster.
     *
     * @return string a JSON encoded string containing information of the
               cluster.
     */
    function getInfo ( ):String { return ""; }

    /**
     * Get information about one (or more) buckets.
     *
     * @param string if specified this is the name of the bucket to get
                    information about
     * @return string A JSON encoded string containing all information about
               the requested bucket(s).
     */
    function getBucketInfo ( name:String ):String { return ""; }

    /**
     * Create a new bucket in the cluster with a given set of attributes.
     *
     * @param string the name of the bucket to create
     * @param array a hashtable specifying the attributes for the
                         bucket to create.
     */
    function createBucket ( name:String,  attributes:Array<Dynamic> ):Dynamic { return {}; }

    /**
     * Modify the attributes for a given bucket.
     *
     * @param string the name of the bucket to modify
     * @param array a hashtable specifying the new attributes for
                         the bucket
     */
    function modifyBucket ( name:String,  attributes:Array<Dynamic> ):Dynamic { return {}; }

    /**
     * Delete the named bucket.
     *
     * @param string the bucket to delete
     */
    function deleteBucket ( name:String ):Dynamic { return {}; }

    /**
     * Flush (delete the content) the named bucket.
     *
     * @param string the bucket to flush
     */
    function flushBucket ( name:String ):Dynamic { return {}; }

}
