package fly.uTorrent
{
	import flash.net.SharedObject;
	import flash.net.URLRequestHeader;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	import fly.serialization.base64.Base64;
	
	[RemoteClass(alias="fly.uTorrent.Settings")]
	public class Settings
	{
		public var username:String;
		public var password:String;
		public var url:String;
		public var port:int;
		
		private var _found:Boolean;
		private var _sharedObject:SharedObject;
		
		public function Settings()
		{
			_sharedObject = SharedObject.getLocal("uTorrentSettings", "/");
			
			_sharedObject.data.settingsSaved = null;
			_sharedObject.flush();
			
			_found = _sharedObject.data.hasOwnProperty("settings") && _sharedObject.data.settingsSaved;
			
			if (_found) 
			{
				var ba:ByteArray = _sharedObject.data.settings;
				var settings:Settings = Settings(ba.readObject());
				username = settings.username;
				password = settings.password;
				url = settings.url;
				port = settings.port;
			}
		}
		
		public function save():void
		{
			_sharedObject.data.settingsSaved = true;
			var ba:ByteArray = new ByteArray();
			ba.writeObject(this);
			_sharedObject.data.settings = ba;
			_sharedObject.flush();
		}
		
		public function get totalURL():String
		{
			return ("http://" + url + ":" + port + "/gui/");
		}
		
		public function get authenticationHeader():URLRequestHeader
		{
			var header:URLRequestHeader;
			
			if (username && password)
			{
				header = new URLRequestHeader("Authorization","Basic " + Base64.encode(username + ":" + password));
			}
			
			return header;
		}
		
		public function get found():Boolean
		{
			return _found;
		}
	}
}
