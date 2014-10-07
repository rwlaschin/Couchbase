package memcache.codec;


class CodecToString implements memcache.codec.Codec
{
	private var codec:Int;

	public function new() {codec = 0;}

    public function encode( data:Dynamic, flags:{flag:Int} ):String; {
        flags.flag = codec;
        return Std.string(data);
    }

    public function decode( data:String, flags:{flag:Int} ):Dynamic {
        if( flags.flag != codec ) {
        	throw "Expecting codec conversion flag of "+codec;
        }
        return Std.string(data);
    }
}