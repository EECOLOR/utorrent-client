package fly.uTorrent
{
	import com.adobe.serialization.json.JSON;
	
	import ee.di.extensions.spark.IInjectable;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import fly.net.SocketHTTPFileRequest;
	import fly.net.SocketURLLoader;
	import fly.uTorrent.decode.Torrent;
	import fly.uTorrent.decode.TorrentInfo;
	
	[Constructor("[Inject]")]
	public class Commands extends EventDispatcher implements IInjectable
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
		
		private var _token:String;
		private var _retrievingToken:Boolean;
		
		private var _loader:SocketURLLoader;
		private var _actionLoader:SocketURLLoader;
		private var _uploadLoader:SocketURLLoader;
		
		private var _processingFile_bool:Boolean;
		private var _filesToAddQueue_arr:Array;
		
		private var _timer:Timer;
		
		private var _settings:Settings;
		
		public function Commands(settings:Settings)
		{
			_settings = settings;
			
			_loader = new SocketURLLoader();
			_loader.addEventListener(Event.COMPLETE, _loadCompleteHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
			
			_actionLoader = new SocketURLLoader();
			_actionLoader.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
			
			_uploadLoader = new SocketURLLoader();
			_uploadLoader.addEventListener(Event.COMPLETE, _uploadCompleteHandler);
			_uploadLoader.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
			
			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, _timerHandler);
			
			_filesToAddQueue_arr = [];
		}
		
		private function _doAction(action:String, torrents:Vector.<Object> = null):void
		{
			var hashes:Array;
			
			if (torrents)
			{
				var torrent:Torrent;
				
				hashes = [];
				var statusChanged:Boolean;
				
				for each (torrent in torrents)
				{
					hashes.push(torrent.hash);
					
					if (!statusChanged && action == ACTION_START && torrent.filteredStatus == TorrentInfo.STATUS_QUEUED)
					{
						action = ACTION_FORCE_START;
					}
				}
			}
			
			var request:URLRequest = new URLRequest(_getActionURL(action, hashes));
			request.requestHeaders.push(_settings.authenticationHeader);
			
			_actionLoader.load(request);
		}
		
		private function _setToken(token:String):void
		{
			_token = "?token=" + token + "&";
		}
		
		private function _getURL(command:String):String
		{
			return _settings.totalURL + _token + command;
		}
		
		private function _getActionURL(action:String, hashes:Array = null):String
		{
			return _settings.totalURL + _token + _createAction(action, hashes);
		}
		
		private function get _tokenURL():String
		{
			return _settings.totalURL + TOKEN;
		}
		
		private function _createAction(action:String, hashes:Array = null):String
		{
			var s:String = ACTION + action;
			
			if (hashes)
			{
				var hash:String;
				
				for each (hash in hashes)
				{
					s += "&" + HASH + hash;
				}
			}
			
			return s;
		}
		
		private function _getToken():void
		{
			_retrievingToken = true;
			
			var request:URLRequest = new URLRequest(_tokenURL);
			var authenticationHeader:URLRequestHeader = _settings.authenticationHeader;
			if (authenticationHeader)
			{
				request.requestHeaders.push(authenticationHeader);		
			}
			
			_loader.load(request);
			
		}
		
		private function _ioErrorHandler(e:IOErrorEvent):void
		{
			trace("_ioErrorHandler: " + e);
		}
		
		private function _loadCompleteHandler(e:Event):void
		{
			if (_retrievingToken)
			{
				_retrievingToken = false;
				
				_setToken(new XML(_loader.data).div.text());
				
				startPolling();
			} else
			{
				var data_str:String = _loader.data;
				var data_obj:Object = JSON.decode(data_str);
				
				//TODO dispatch complete event
			}
		}
		
		private function _uploadCompleteHandler(e:Event):void
		{
			_processingFile_bool = false;
			
			if (_filesToAddQueue_arr.length)
			{
				_addNextFile();
			}
		}
		
		private function _addNextFile():void
		{
			var file:File = File(_filesToAddQueue_arr.shift());
			
			if (file.nativePath.substr(-8) == ".torrent")
			{
				_addFile(file);
			} else if (_filesToAddQueue_arr.length)
			{
				_addNextFile();
			}
		}
		
		public function startPolling():void
		{
			_timer.start();
			list();
		}
		
		public function stopPolling():void
		{
			_timer.stop();
		}
		
		private function _timerHandler(e:TimerEvent):void
		{
			list();
		}
		
		public function list():void
		{
			var request:URLRequest = new URLRequest(_getURL(LIST));
			var authenticationHeader:URLRequestHeader = _settings.authenticationHeader;
			if (authenticationHeader)
			{
				request.requestHeaders.push(authenticationHeader);		
			}
			
			_loader.load(request);
		}
		
		public function addFile(file:File):void
		{
			_filesToAddQueue_arr.push(file);
			
			if (!_processingFile_bool)
			{
				_addNextFile();
			}			
		}
		
		private function _addFile(file:File):void
		{
			_processingFile_bool = true;
			
			var fileContent:ByteArray = new ByteArray();
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(fileContent);
			fileStream.close();
			
			var request:SocketHTTPFileRequest = new SocketHTTPFileRequest(_getActionURL(ACTION_ADD_FILE));
			request.fileName = file.name;
			request.fileContent = fileContent;
			request.dataField = "torrent_file";
			request.requestHeaders.push(_settings.authenticationHeader);
			
			_uploadLoader.load(request);			

			
			return _doAction(ACTION_ADD_FILE);
		}
		
		public function start(torrents:Vector.<Object>):void
		{
			_doAction(ACTION_START, torrents);
		}
		
		public function forceStart(torrents:Vector.<Object>):void
		{
			_doAction(ACTION_FORCE_START, torrents);			
		}
		
		public function stop(torrents:Vector.<Object>):void
		{
			_doAction(ACTION_STOP, torrents);			
		}
		
		public function pause(torrents:Vector.<Object>):void
		{
			_doAction(ACTION_PAUSE, torrents);			
		}
		
		public function remove(torrents:Vector.<Object>):void
		{
			_doAction(ACTION_REMOVE, torrents);		
		}
	}
}