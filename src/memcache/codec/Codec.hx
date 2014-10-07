package memcache.codec;


interface Codec
{
	public var codec(default,null):Int;

    public function encode( data:Dynamic, flags:{flag:Int} ):String;

    public function decode( data:String, flags:{flag:Int} ):Dynamic;
}