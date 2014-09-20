package couchbase;


class CouchbaseConst {

/**
 * Everything is OK.
 */
public static var COUCHBASE_SUCCESS = 0x00; //LCB_SUCCESS
/**
 * This is an internal error message.
 */
public static var COUCHBASE_AUTH_CONTINUE = 0x01; //LCB_AUTH_CONTINUE
/**
 * Increment/decrement on an object that isn't a number.
 */
public static var COUCHBASE_DELTA_BADVAL = 0x03; //LCB_DELTA_BADVAL
/**
 * The object is too big to be stored on the server.
 */
public static var COUCHBASE_E2BIG = 0x04; //LCB_E2BIG
/**
 * The server is too busy to handle your request. Please try again later.
 */
public static var COUCHBASE_EBUSY = 0x05; //LCB_EBUSY
/**
 * An internal error in the Couchbase extension.
 * You should probably submit a bug report for this.
 */
public static var COUCHBASE_EINTERNAL = 0x06; //LCB_EINTERNAL
/**
 * Out of resources.
 */
public static var COUCHBASE_ENOMEM = 0x08; //LCB_ENOMEM
/**
 * Generic error code.
 */
public static var COUCHBASE_ERROR = 0x0a; //LCB_ERROR
/**
 * Temporarily cannot handle request. A later retry may succeed.
 */
public static var COUCHBASE_ETMPFAIL = 0x0b; //LCB_ETMPFAIL
/**
 * The key exists, but the CAS identifier provided did not match the one for
 * the object in the cluster.
 */
public static var COUCHBASE_KEY_EEXISTS = 0x0c; //LCB_KEY_EEXISTS
/**
 * The key does not exist.
 */
public static var COUCHBASE_KEY_ENOENT = 0x0d; //LCB_KEY_ENOENT
/**
 * An error occurred while trying to read/write data to the network.
 */
public static var COUCHBASE_NETWORK_ERROR = 0x10; //LCB_NETWORK_ERROR
/**
 * The command was sent to the wrong server. This problem may occur if
 * someone added/removed a node to the cluster. Retrying the operation may
 * solve the problem.
 */
public static var COUCHBASE_NOT_MY_VBUCKET = 0x11; //LCB_NOT_MY_VBUCKET
/**
 * The document was not stored.
 */
public static var COUCHBASE_NOT_STORED = 0x12; //LCB_NOT_STORED
/**
 * The server knows about this command, but the datastore doesn't support it
 * for some reason.
 */
public static var COUCHBASE_NOT_SUPPORTED = 0x13; //LCB_NOT_SUPPORTED
/**
 * The server did not understand the command we sent. This may occur if you
 * are attempting to use an operation not supported on an older version of
 * Couchbase Server.
 */
public static var COUCHBASE_UNKNOWN_COMMAND = 0x14; //LCB_UNKNOWN_COMMAND
/**
 * Failed to lookup the host.
 */
public static var COUCHBASE_UNKNOWN_HOST = 0x15; //LCB_UNKNOWN_HOST

////////////////////////////////////////////////////////
//                                                    //
//        The following option public static varants exist        //
//                                                    //
////////////////////////////////////////////////////////

/**
 * Specifies the serializer to use to store objects in the cluster.
 */
public static var COUCHBASE_OPT_SERIALIZER = 1;
/**
 * Specifies the compression to use for big objects.
 */
public static var COUCHBASE_OPT_COMPRESSION = 2;
/**
 * A text string used as a prefix for all keys (may be used to create your
 * own namespace).
 */
public static var COUCHBASE_OPT_PREFIX_KEY = 3;
/**
 * This option is used to disable the deserialisation of the
 * data received from the cluster. It is mainly used by the
 * developers of the extension to be able to test variable
 * parts of the API and should not be used by end users
 * (it may be removed without notice if we find a better way to do
 * this).
 */
public static var COUCHBASE_OPT_IGNOREFLAGS = 4;
/**
 * @todo figure out what this is used for...
 */
public static var COUCHBASE_OPT_VOPTS_PASSTHROUGH = 5;

/**
 * Constant representing the PHP serializer.
 */
public static var COUCHBASE_SERIALIZER_PHP = 0;
/**
 * Constant representing the JSON serializer.
 */
public static var COUCHBASE_SERIALIZER_JSON = 1;
/**
 * Constant representing the JSON serializer, but deserialise into arrays.
 */
public static var COUCHBASE_SERIALIZER_JSON_ARRAY = 2;
/**
 * Constant representing no compression.
 */
public static var COUCHBASE_COMPRESSION_NONE = 0;
/**
 * Constant representing zlib compression.
 */
public static var COUCHBASE_COMPRESSION_ZLIB = 1;
/**
 * Constant representing fastlz compression.
 */
public static var COUCHBASE_COMPRESSION_FASTLZ = 2;

/**
 * Constant representing preserve order for multiget
 */
public static var COUCHBASE_PRESERVE_ORDER = 1;




}
