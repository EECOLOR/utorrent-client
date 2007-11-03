package fly.uTorrent.ui
{
	import mx.managers.PopUpManager;
	import fly.uTorrent.Settings;
	import fly.flex.events.ButtonClickEventKind;
	import fly.flex.events.ButtonClickEvent;
	import flash.net.URLLoader;
	import flash.events.Event;
	import fly.utils.cfDump;
	import fly.uTorrent.decode.Torrents;
	import fly.utils.BytesUtil;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import com.adobe.serialization.json.JSON;
	import fly.uTorrent.Commands;
	import fly.uTorrent.decode.Torrent;
	import mx.events.ListEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import fly.uTorrent.skins.Indicators;
	import mx.events.FlexMouseEvent;
	import fly.uTorrent.skins.Icons;
	import fly.uTorrent.decode.TorrentInfo;
	import flash.net.URLVariables;
	import flash.net.FileReferenceList;
	import flash.net.FileReference;
	import flash.events.HTTPStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import fly.uTorrent.events.UTorrentEvent;
	import flash.display.DisplayObject;
	import mx.core.IFlexDisplayObject;
	import fly.net.SocketURLLoader;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.filesystem.FileMode;
	import fly.net.SocketHTTPFileRequest;
	import flash.system.Shell;
	import flash.events.InvokeEvent;
	import mx.events.StyleEvent;
	import flash.events.IEventDispatcher;
	import flash.utils.getDefinitionByName;
	import mx.managers.SystemManager;
	import mx.events.FlexEvent;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import mx.controls.Label;
	
	[Style(name="uploadIndicator", type="Class", inherit="no")]
	[Style(name="downloadIndicator", type="Class", inherit="no")]
	
	[Event(name="createdPopup", type="fly.uTorrent.events.UTorrentEvent")]

	public class UTorrent extends UTorrentVisual
	{
		private var _settingsUI:SettingsUI;
		private var _loader:SocketURLLoader;
		private var _actionLoader:SocketURLLoader;
		private var _uploadLoader:SocketURLLoader;
		private var _torrents:Torrents;
		private var _timer:Timer;
		private var _settings:Settings;
		private var _file:File;
		
		private var _filesToAddQueue_arr:Array;
		private var _processingFile_bool:Boolean;
		
		private var _initialized_bool:Boolean;
		
		private var _styleManagerDispatcher:IEventDispatcher;
		
		public function UTorrent()
		{
			_settings = Settings.instance;
			
			_loader = new SocketURLLoader();
			_loader.addEventListener(Event.COMPLETE, _loadCompleteHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);

			_actionLoader = new SocketURLLoader();
			_actionLoader.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
			
			_uploadLoader = new SocketURLLoader();
			_uploadLoader.addEventListener(Event.COMPLETE, _uploadCompleteHandler);
			_uploadLoader.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
			
			_file = new File();
			
			_torrents = new Torrents();
			
			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, _timerHandler);
			
			_filesToAddQueue_arr = new Array();
			
			Shell.shell.addEventListener(InvokeEvent.INVOKE, _shellInvokeHandler);
			
			addEventListener(FlexEvent.CREATION_COMPLETE, _creationCompleteHandler);
		};
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			_settingsUI = new SettingsUI();
			_settingsUI.addEventListener(ButtonClickEvent.BUTTON_CLICK, _settingsUIButtonClickHandler);
			
		};
		
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			
			torrentList.labelField = "name";
			torrentList.dataProvider = _torrents.torrents;
			torrentList.addEventListener(ListEvent.ITEM_CLICK, _torrentListChangeHandler);
			
			addEventListener(MouseEvent.CLICK, _clickHandler);
			
			_initializeButtons();
			
		};
		
		private function _creationCompleteHandler(e:FlexEvent):void
		{
			if (!Settings.found)
			{
				//load the default style
				_styleManagerDispatcher = _loadSkin();
				_styleManagerDispatcher.addEventListener(StyleEvent.COMPLETE, _initStyleCompleteHandler);
				cfDump("creationComplete");
			} else
			{
				_init();
			};				
			
		};
		
		private function _initStyleCompleteHandler(e:StyleEvent):void
		{
			_settingsClickHandler(null);
		};
		
		private function _shellInvokeHandler(e:InvokeEvent):void
		{
			var filePath_str:String;
			var file:File;
			for each (filePath_str in e.arguments)
			{
				file = new File(filePath_str);
				if (file.exists)
				{
					_filesToAddQueue_arr.push(file);
				};
			};
			
			if (_initialized_bool && _filesToAddQueue_arr.length && !_processingFile_bool)
			{
				_addNextFile();
			};
		};
		
		private function _initializeButtons():void
		{
			startBtn.visible = startBtn.includeInLayout = false;
			stopBtn.visible = stopBtn.includeInLayout = false;
			pauseBtn.visible = pauseBtn.includeInLayout = false;
			removeBtn.visible = removeBtn.includeInLayout = false;
			removeBtn.visible = removeBtn.includeInLayout = false;
			
			addBtn.enabled = false;
			
			settingsBtn.addEventListener(MouseEvent.CLICK, _settingsClickHandler);
			addBtn.addEventListener(MouseEvent.CLICK, _addClickHandler);
			stopBtn.addEventListener(MouseEvent.CLICK, _stopClickHandler);
			startBtn.addEventListener(MouseEvent.CLICK, _startClickHandler);
			pauseBtn.addEventListener(MouseEvent.CLICK, _pauseClickHandler);
			removeBtn.addEventListener(MouseEvent.CLICK, _removeClickHandler);
			minimizeBtn.addEventListener(MouseEvent.CLICK, _minimizeClickHandler);
			closeBtn.addEventListener(MouseEvent.CLICK, _closeClickHandler);
		};
		
		private function _addClickHandler(e:MouseEvent):void
		{
			cfDump("addClickHandler");
			//?action=add-file
			_file.browse();
		};
		
		private function _doAction(action:Function):void
		{
			var torrents_arr:Array = torrentList.selectedItems;
			var torrent:Torrent;
			
			var hashes_arr:Array = new Array();
			
			for each (torrent in torrents_arr)
			{
				hashes_arr.push(torrent.hash);
				
				switch (action)
				{
					case Commands.start:
						switch (torrent.filteredStatus)
						{
							case TorrentInfo.STATUS_QUEUED:
								action = Commands.forceStart;
								break;
						};
						break;
				};
			};
			
			var request:URLRequest = new URLRequest(Commands.getActionURL(action, hashes_arr));
			request.requestHeaders.push(_settings.authenticationHeader);
			
			_actionLoader.load(request);
		};
		
		private function _stopClickHandler(e:MouseEvent):void
		{
			_doAction(Commands.stop);
		};
		
		private function _startClickHandler(e:MouseEvent):void
		{
			_doAction(Commands.start);
		};
		
		private function _pauseClickHandler(e:MouseEvent):void
		{
			_doAction(Commands.pause);
		};
		
		private function _removeClickHandler(e:MouseEvent):void
		{
			_doAction(Commands.remove);
		};
		
		private function _minimizeClickHandler(e:MouseEvent):void
		{
			stage.nativeWindow.minimize();
		};
		
		private function _closeClickHandler(e:MouseEvent):void
		{
			stage.nativeWindow.close();
		};
		
		private function _clickHandler(e:MouseEvent):void
		{
			if (!torrentList.hitTestPoint(stage.mouseX, stage.mouseY) &&
				!addBtn.hitTestPoint(stage.mouseX, stage.mouseY) &&
				!removeBtn.hitTestPoint(stage.mouseX, stage.mouseY) &&
				!stopBtn.hitTestPoint(stage.mouseX, stage.mouseY) &&
				!startBtn.hitTestPoint(stage.mouseX, stage.mouseY) &&
				!pauseBtn.hitTestPoint(stage.mouseX, stage.mouseY) &&
				!settingsBtn.hitTestPoint(stage.mouseX, stage.mouseY))
			{
				cfDump("removing selection");
				cfDump(stage.getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY)));
				torrentList.selectedItem = null;
				_torrentListChangeHandler(null);
			};
		};
		
		private function _torrentListChangeHandler(e:ListEvent):void
		{
			_displayDownloadSpeed();
			_updateButtons();
		};
		
		private function _updateButtons():void
		{
			var torrents_arr:Array = torrentList.selectedItems;
			
			var torrentsSelected_bool:Boolean = Boolean(torrents_arr.length);
			var startEnabled_bool:Boolean;
			var resume_bool:Boolean;
			var pauseEnabled_bool:Boolean;
			var stopEnabled_bool:Boolean;
			
			removeBtn.visible = removeBtn.includeInLayout = torrentsSelected_bool;
			
			if (torrentsSelected_bool)
			{
				var torrent:Torrent;
				
				for each (torrent in torrents_arr)
				{
					startEnabled_bool = startEnabled_bool || 
										torrent.filteredStatus == TorrentInfo.STATUS_STOPPED ||
										torrent.filteredStatus == TorrentInfo.STATUS_FORCED_PAUSED ||
										torrent.filteredStatus == TorrentInfo.STATUS_PAUSED ||
										torrent.filteredStatus == TorrentInfo.STATUS_QUEUED;
					resume_bool = resume_bool || 
								  torrent.filteredStatus == TorrentInfo.STATUS_PAUSED;
					stopEnabled_bool = stopEnabled_bool || 
									   torrent.filteredStatus == TorrentInfo.STATUS_ACTIVE ||
									   torrent.filteredStatus == TorrentInfo.STATUS_FORCED_ACTIVE ||
									   torrent.filteredStatus == TorrentInfo.STATUS_CHECKING ||
									   torrent.filteredStatus == TorrentInfo.STATUS_FORCED_CHECKING ||
									   torrent.filteredStatus == TorrentInfo.STATUS_FORCED_PAUSED ||
									   torrent.filteredStatus == TorrentInfo.STATUS_PAUSED ||
									   torrent.filteredStatus == TorrentInfo.STATUS_QUEUED;
					pauseEnabled_bool = pauseEnabled_bool ||
										torrent.filteredStatus == TorrentInfo.STATUS_ACTIVE ||
										torrent.filteredStatus == TorrentInfo.STATUS_FORCED_ACTIVE;
				};
			};
			
			startBtn.visible = startBtn.includeInLayout = startEnabled_bool;
			stopBtn.visible = stopBtn.includeInLayout = stopEnabled_bool;
			pauseBtn.visible = pauseBtn.includeInLayout = pauseEnabled_bool;
			
			startBtn.setStyle("icon", resume_bool ? getStyle("resumeIcon") : getStyle("startIcon"));
			startBtn.toolTip = resume_bool ? "Resume" : "Start";
		};
		
		private var s:NativeWindow;
		
		private function _settingsClickHandler(e:MouseEvent):void
		{
			PopUpManager.addPopUp(_settingsUI, this, true);
			
			PopUpManager.centerPopUp(_settingsUI);
			
			var uTorrentEvent:UTorrentEvent = new UTorrentEvent(UTorrentEvent.CREATED_POPUP);
			uTorrentEvent.popup = _settingsUI;
			
			dispatchEvent(uTorrentEvent);
		};
		
		private function _settingsUIButtonClickHandler(e:ButtonClickEvent):void
		{
			if (Settings.found || e.kind == ButtonClickEventKind.OK)
			{
				PopUpManager.removePopUp(_settingsUI);
			};
			
			if (e.kind == ButtonClickEventKind.OK)
			{
				_timer.stop();
				_init();
			};
		};
		
		private function _init():void
		{
			_styleManagerDispatcher = _loadSkin();
			_styleManagerDispatcher.addEventListener(StyleEvent.COMPLETE, _styleManagerCompleteHandler);
		};
		
		private function _loadSkin():IEventDispatcher
		{
			var applicationResourceDirectory_str:String = File.applicationResourceDirectory.url;
			return StyleManager.loadStyleDeclarations(applicationResourceDirectory_str + "skins/current/" + _settings.skinName + ".swf");
		};
		
		private function _styleManagerCompleteHandler(e:StyleEvent):void
		{
			downImg.source = getStyle("downloadIndicator");
			upImg.source = getStyle("uploadIndicator");
			
			_initFileUpload();
			_startPolling();
			
			_initialized_bool = true;
		};
		
		private function _test():void
		{
			
			callLater(_test);
		};
		
		private function _initFileUpload():void
		{
			_file.addEventListener(Event.SELECT, _fileSelectHandler);

			if (_filesToAddQueue_arr.length && !_processingFile_bool)
			{
				_addNextFile();
			};

			addBtn.enabled = true;
		};
		
		private function _uploadCompleteHandler(e:Event):void
		{
			_processingFile_bool = false;
			
			if (_filesToAddQueue_arr.length)
			{
				_addNextFile();
			};
			
			cfDump(e, 5);
		};
		
		private function _completeHandler(e:Event):void
		{
			cfDump(e, 5);
		};
		
		private function _errorHandler(e:Event):void
		{
			cfDump(e, 5);
		};
		
		private function _fileSelectHandler(e:Event):void
		{
			var file:File = new File(_file.nativePath);
			_filesToAddQueue_arr.push(file);
			
			if (!_processingFile_bool)
			{
				_addNextFile();
			};			
		};
		
		private function _addNextFile():void
		{
			var file:File = _filesToAddQueue_arr.shift() as File;
			
			if (file.nativePath.substr(-8) == ".torrent")
			{
				var fileContent:ByteArray = new ByteArray();
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				fileStream.readBytes(fileContent);
				fileStream.close();
				
				_processingFile_bool = true;
				
				var request:SocketHTTPFileRequest = new SocketHTTPFileRequest(Commands.getActionURL(Commands.addFile));
				request.fileName = file.name;
				request.fileContent = fileContent;
				request.dataField = "torrent_file";
				request.requestHeaders.push(_settings.authenticationHeader);
				
				_uploadLoader.load(request);			
			};
		};
		
		private function _startPolling():void
		{

			_timer.start();
			_getData();
		};
		
		private function _timerHandler(e:TimerEvent):void
		{
			_getData();
		};
		
		private function _getData():void
		{
			var request:URLRequest = new URLRequest(Commands.getURL(Commands.list()));
			var authenticationHeader:URLRequestHeader = _settings.authenticationHeader;
			if (authenticationHeader)
			{
		        request.requestHeaders.push(authenticationHeader);		
		 	};
	        	// TODO test
			_loader.load(request);
		};
		
		
		private function _ioErrorHandler(e:IOErrorEvent):void
		{
			cfDump(e, 5);
		};
		
		private function _loadCompleteHandler(e:Event):void
		{
			var data_str:String = _loader.data;
			var data_obj:Object = JSON.decode(data_str);
			
			var torrents_arr:Array = data_obj.torrents;
			
			_torrents.updateTorrents(torrents_arr);
			
			if (torrentList.selectedItems.length)
			{
				_updateButtons();
			};
			
			_displayDownloadSpeed();
		};					
		
		private function _displayDownloadSpeed():void
		{
			var downloadSpeed_num:Number = 0;
			var uploadSpeed_num:Number = 0;
			var torrent_arr:Array = torrentList.selectedItems;
			var torrent:Torrent;
			
			if (torrent_arr.length)
			{
				for each (torrent in torrent_arr)
				{
					downloadSpeed_num += torrent.downloadSpeed;
					uploadSpeed_num += torrent.uploadSpeed;
				};
			} else
			{
				downloadSpeed_num = _torrents.totalDownloadSpeed;
				uploadSpeed_num = _torrents.totalUploadSpeed;
			};
			downTxt.text = BytesUtil.toString(downloadSpeed_num, 2) + "/s";
			upTxt.text = BytesUtil.toString(uploadSpeed_num, 2) + "/s";
		};
		
        static private var _initialized_bool:Boolean = _initialize();

        static private function _initialize():Boolean 
        {
        	/*
            if (!StyleManager.getStyleDeclaration("UTorrent"))
            {
                var newStyleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
                newStyleDeclaration.setStyle("uploadIndicator", Indicators.UPLOAD);
                newStyleDeclaration.setStyle("downloadIndicator", Indicators.DOWNLOAD);
                newStyleDeclaration.setStyle("settingsIcon", Icons.SETTINGS);
                newStyleDeclaration.setStyle("startIcon", Icons.START);
                newStyleDeclaration.setStyle("stopIcon", Icons.STOP);
                newStyleDeclaration.setStyle("pauseIcon", Icons.PAUSE);
                newStyleDeclaration.setStyle("removeIcon", Icons.REMOVE);
                newStyleDeclaration.setStyle("resumeIcon", Icons.RESUME);
                newStyleDeclaration.setStyle("addIcon", Icons.ADD);
                
                StyleManager.setStyleDeclaration("UTorrent", newStyleDeclaration, true);
            };
            */
            return true;
        };			
	};
};