package fly.test
{
	import mx.core.Application;
	import fly.net.SocketURLLoader;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.Event;
	import fly.utils.cfDump;
	import fly.uTorrent.Settings;
	import flash.net.URLRequest;
	import fly.utils.cfDumpClear;
	import flash.net.URLVariables;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.utils.ByteArray;
	import fly.net.SocketHTTPFileRequest;
	import flash.filesystem.FileStream;
	import flash.events.ProgressEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequestHeader;
	import fly.net.ContentType;

	public class Main extends Application
	{
		private var _sl:SocketURLLoader;
		private var _file:File;
		private var _settings:Settings;
		
		public function Main()
		{
			cfDumpClear();
			
			_sl = new SocketURLLoader();
			_sl.addEventListener(IOErrorEvent.IO_ERROR, _error);
			_sl.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _error);
			_sl.addEventListener(Event.COMPLETE, _loadComplete);
			_sl.addEventListener(ProgressEvent.PROGRESS, _loadProgress);
			_sl.addEventListener(HTTPStatusEvent.HTTP_STATUS, _loadStatus);
			
			var request:URLRequest = new URLRequest("http://www.torrentspy.com/search");
			request.method = URLRequestMethod.POST;
			//request.contentType = ContentType.MULTIPART_FORM_DATA;
			request.data = new URLVariables();
			request.data.query = "test";
			cfDump(request.data);
			_sl.load(request);
			
			
			/*
			_settings = Settings.instance;
			_settings.username = "admin";
			_settings.password = "Cinoibeb";
			_settings.url = "192.168.1.16";
			_settings.port = 16000;
			
			_sl = new SocketURLLoader();
			_sl.addEventListener(IOErrorEvent.IO_ERROR, _error);
			_sl.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _error);
			_sl.addEventListener(Event.COMPLETE, _loadComplete);
			_sl.addEventListener(ProgressEvent.PROGRESS, _loadProgress);
			_sl.addEventListener(HTTPStatusEvent.HTTP_STATUS, _loadStatus);
			
			var data:URLVariables = new URLVariables();
			data.list = 1;
			
			var request:URLRequest = new URLRequest(_settings.totalURL);
			request.data = data;
			request.requestHeaders.push(_settings.authenticationHeader);
			
			_sl.load(request);
			
			_file = new File();
			_file.addEventListener(Event.SELECT, _fileSelectHandler);
			_file.browse();
			*/
			
		};
		
		private function _fileSelectHandler(e:Event):void
		{
			var fileContent:ByteArray = new ByteArray();
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(_file, FileMode.READ);
			fileStream.readBytes(fileContent);
			fileStream.close();
			
			var request:SocketHTTPFileRequest = new SocketHTTPFileRequest(_settings.totalURL + "?action=add-file");
			request.fileName = _file.name;
			request.fileContent = fileContent;
			request.dataField = "torrent_file";
			request.requestHeaders.push(_settings.authenticationHeader);
			
			_sl.load(request);
		};
		
		private function _loadStatus(e:HTTPStatusEvent):void
		{
			cfDump(e, 5);
		};
		
		private function _loadProgress(e:ProgressEvent):void
		{
			cfDump(e, 5);
		};
		
		private function _loadComplete(e:Event):void
		{
			cfDump("load complete");
			cfDump(_sl.data);
		};
		
		private function _error(e:Event):void
		{
			cfDump(e, 5);
		};
	};
};