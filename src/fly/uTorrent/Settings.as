package fly.uTorrent
{
	import flash.net.URLRequestHeader;
	import fly.serialization.base64.Base64;
	import flash.net.SharedObject;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	[RemoteClass(alias="fly.uTorrent.Settings")]
	public class Settings
	{
		static private var _initialize_bool:Boolean = _initialize();
		static private var _sharedObject:SharedObject;
		static private var _settings:Settings;
		static private var _found_bool:Boolean;
		
		static private function _initialize():Boolean
		{
			_sharedObject = SharedObject.getLocal("uTorrentSettings", "/");
			//delete _sharedObject.data.settings;
			//_sharedObject.flush();
			
			_found_bool = _sharedObject.data.hasOwnProperty("settings") && _sharedObject.data.settingsSaved;
			
			return true;
		};		
				
		static public function get found():Boolean
		{
			return _found_bool;
		};
		
		static public function get instance():Settings
		{
			if (!_settings)
			{
				if (!_sharedObject.data.hasOwnProperty("settings"))
				{
					_settings = new Settings();
				} else
				{
					var ba:ByteArray = _sharedObject.data.settings;
					_settings = ba.readObject() as Settings;
				};
			};
			
			return _settings;
		};
		
		static public function save():void
		{
			_sharedObject.data.settingsSaved = true;
			var ba:ByteArray = new ByteArray();
			ba.writeObject(_settings);
			_sharedObject.data.settings = ba;
			_sharedObject.flush();
		};
		
		public var username:String;
		public var password:String;
		public var url:String;
		public var port:int;
		public var skinName:String;
		
		public function Settings()
		{
			skinName = "uTorrentSkin";
		};
		
		public function get totalURL():String
		{
			return ("http://" + url + ":" + port + "/gui/");
		};
		
		public function get authenticationHeader():URLRequestHeader
		{
			var header:URLRequestHeader;
			
			if (username && password)
			{
				header = new URLRequestHeader("Authorization","Basic " + Base64.encode(username + ":" + password));
			};
			
			return header;
		};
	};
}

class SingletonEnforcer
{
};