package memcache.codec;


class CodecToString implements memcache.codec.Codec
{
	public var codec:Int;

	public function new():Void {
        codec = 0;
    }

    public function encode( data:Dynamic, flags:{flag:Int} ):String {
        flags.flag = codec;
        return Std.string(data);
    }

    public function decode( data:String, flags:{flag:Int} ):Dynamic {
        if( flags.flag != codec ) {
            throw "Expecting codec conversion flag of "+codec + " <"+flags.flag+">";
        }
        return Std.string(data);
    }
}