package fly.serialization.base64
{
	import mx.utils.Base64Encoder;
	import mx.utils.Base64Decoder;
	import flash.utils.ByteArray;
	
	public class Base64
	{
		static private var _encoder:Base64Encoder;
		static private var _decoder:Base64Decoder;
		
		static public function encode(str:String):String
		{
			_encoder = new Base64Encoder();
			_encoder.encode(str);
			return _encoder.drain();
		};
		
		static public function decode(str:String):ByteArray
		{
			_decoder = new Base64Decoder();
			_decoder.decode(str);
			return _decoder.drain();
		};
	};
};