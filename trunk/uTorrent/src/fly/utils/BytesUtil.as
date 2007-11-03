package fly.utils
{
	public class BytesUtil
	{
		static public const B:String = "B";
		static public const KB:String = "KB";
		static public const MB:String = "MB";
		static public const GB:String = "GB";
		
		static private const _b_int:int = 0;
		static private const _kb_int:int = 1;
		static private const _mb_int:int = 2;
		static private const _gb_int:int = 3;
		
		static private function _convert(bytes_num:Number, type_num:Number):Number
		{
			return (bytes_num / Math.pow(1024, type_num));
		};
		
		static public function toKB(bytes_num:Number):Number
		{
			return _convert(bytes_num, _kb_int);
		};
		
		static public function toMB(bytes_num:Number):Number
		{
			return _convert(bytes_num, _mb_int);
		};
		
		static public function toGB(bytes_num:Number):Number
		{
			return _convert(bytes_num, _gb_int);
		};
		
		static private function _toString(bytes_num:Number, type_num:Number, str:String, precision_num:Number):String
		{
			precision_num = Math.pow(10, precision_num);
			
			var num:Number = _convert(bytes_num, type_num);
			num = Math.round(num * precision_num);
			num = num / precision_num;
			
			return num + " " + str;
		};
		
		static public function toBString(bytes_num:Number, precision_num:Number):String
		{
			return _toString(bytes_num, _b_int, B, precision_num);
		};
		
		static public function toKBString(bytes_num:Number, precision_num:Number):String
		{
			return _toString(bytes_num, _kb_int, KB, precision_num);
		};
		
		static public function toMBString(bytes_num:Number, precision_num:Number):String
		{
			return _toString(bytes_num, _mb_int, MB, precision_num);
		};
		
		static public function toGBString(bytes_num:Number, precision_num:Number):String
		{
			return _toString(bytes_num, _gb_int, GB, precision_num);
		};
		
		static public function toString(bytes_num:Number, precision_num:Number):String
		{
			var str:String;
			if (bytes_num < Math.pow(1024, _kb_int))
			{
					str = _toString(bytes_num, _mb_int, B, precision_num);
			} else if (bytes_num < Math.pow(1024, _mb_int))
			{
					str = _toString(bytes_num, _kb_int, KB, precision_num);
			} else if (bytes_num < Math.pow(1024, _gb_int))
			{
					str = _toString(bytes_num, _mb_int, MB, precision_num);
			} else 
			{
					str = _toString(bytes_num, _gb_int, GB, precision_num);
			};

			return str;
		};
	};
};