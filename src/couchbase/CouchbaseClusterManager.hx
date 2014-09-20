package couchbase;
/**
 * A class to wrap the management of a Couchbase cluster.
 */
class CouchbaseClusterManager {


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
    function new ( hosts:Array<Dynamic>,  user:String,  password:String );

    /**
     * Get information about the cluster.
     *
     * @return string a JSON encoded string containing information of the
               cluster.
     */
    function getInfo ( ):String;

    /**
     * Get information about one (or more) buckets.
     *
     * @param string if specified this is the name of the bucket to get
                    information about
     * @return string A JSON encoded string containing all information about
               the requested bucket(s).
     */
    function getBucketInfo ( name:String ):String;

    /**
     * Create a new bucket in the cluster with a given set of attributes.
     *
     * @param string the name of the bucket to create
     * @param array a hashtable specifying the attributes for the
                         bucket to create.
     */
    function createBucket ( name:String,  attributes:Array<Dynamic> ):Dynamic;

    /**
     * Modify the attributes for a given bucket.
     *
     * @param string the name of the bucket to modify
     * @param array a hashtable specifying the new attributes for
                         the bucket
     */
    function modifyBucket ( name:String,  attributes:Array<Dynamic> ):Dynamic;

    /**
     * Delete the named bucket.
     *
     * @param string the bucket to delete
     */
    function deleteBucket ( name:String ):Dynamic;

    /**
     * Flush (delete the content) the named bucket.
     *
     * @param string the bucket to flush
     */
    function flushBucket ( name:String ):Dynamic;

}
