package couchbase;
/**
 * Exception thrown when there are not enough nodes online to preform a
particular operation.  Generally occurs due to invalid durability
requirements
 */
class CouchbaseNotEnoughNodesException extends CouchbaseException {


}
