package fly.uTorrent
{
	
	
	public class Commands
	{
		static public const LIST:String = "list=1";
		static public const TOKEN:String = "token.html";
		static public const HASH:String = "hash=";
		static public const ACTION:String = "action=";
		static public const ACTION_START:String = "start";
		static public const ACTION_FORCE_START:String = "forcestart";
		static public const ACTION_ADD_FILE:String = "add-file";
		static public const ACTION_STOP:String = "stop";
		static public const ACTION_PAUSE:String = "pause";
		static public const ACTION_REMOVE:String = "remove";
		
		static private var _token:String;
		
		static public function setToken(token:String):void
		{
			_token = "?token=" + token + "&";
		}
		
		static public function getURL(command_str:String, ignoreToken:Boolean = false):String
		{
			return Settings.instance.totalURL + _token + command_str;
		};
		
		static public function getActionURL(action:Function, arguments_arr:Array = null, ignoreToken:Boolean = false):String
		{
			return Settings.instance.totalURL + _token + action.apply(Commands, arguments_arr);
		};
		
		static public function get tokenURL():String
		{
			return Settings.instance.totalURL + TOKEN;
		}
		
		static public function list():String
		{
			return LIST;
		};
		
		static private function _createAction(action_str:String, hashes_arr:Array = null):String
		{
			var s:String = ACTION + action_str;
			
			if (hashes_arr)
			{
				var hash_str:String;
				
				for each (hash_str in hashes_arr)
				{
					s += "&" + HASH + hash_str;
				};
			};
			
			return s;
		};
		
		static public function addFile():String
		{
			return _createAction(ACTION_ADD_FILE);
		};
		
		static public function start(hash_str:String, ... rest_arr:Array):String
		{
			return _createAction(ACTION_START, [hash_str].concat(rest_arr));			
		};
		
		static public function forceStart(hash_str:String, ... rest_arr:Array):String
		{
			return _createAction(ACTION_FORCE_START, [hash_str].concat(rest_arr));			
		};
		
		static public function stop(hash_str:String, ... rest_arr:Array):String
		{
			return _createAction(ACTION_STOP, [hash_str].concat(rest_arr));			
		};
		
		static public function pause(hash_str:String, ... rest_arr:Array):String
		{
			return _createAction(ACTION_PAUSE, [hash_str].concat(rest_arr));			
		};
		
		static public function remove(hash_str:String, ... rest_arr:Array):String
		{
			return _createAction(ACTION_REMOVE, [hash_str].concat(rest_arr));
		};
	};
};