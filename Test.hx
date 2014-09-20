package ;

import couchbase.Couchbase;
import couchbase.CouchbaseConst;

class Test{
	static function main(){
		var cb = new Couchbase(['localhost'],"user","password","default",false);
		trace(CouchbaseConst.COUCHBASE_SUCCESS);
		var cb = new Couchbase(['localhost:8091'],"user","password","default",false);
		trace(CouchbaseConst.COUCHBASE_SUCCESS);
		var cb = new Couchbase(['127.0.0.1'],"user","password","default",false);
		trace(CouchbaseConst.COUCHBASE_SUCCESS);
		var cb = new Couchbase(['127.0.0.1:8091'],"user","password","default",false);
		trace(CouchbaseConst.COUCHBASE_SUCCESS);
	}
}
