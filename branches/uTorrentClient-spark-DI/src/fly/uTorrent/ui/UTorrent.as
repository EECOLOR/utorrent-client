package fly.uTorrent.ui
{
	import com.adobe.serialization.json.JSON;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import fly.flex.controls.ExtendedList;
	import fly.net.SocketHTTPFileRequest;
	import fly.net.SocketURLLoader;
	import fly.uTorrent.Commands;
	import fly.uTorrent.Settings;
	import fly.uTorrent.decode.Torrent;
	import fly.uTorrent.decode.TorrentInfo;
	import fly.uTorrent.decode.Torrents;
	import fly.uTorrent.events.ButtonClickEvent;
	import fly.uTorrent.events.ButtonClickEventKind;
	import fly.uTorrent.events.UTorrentEvent;
	import fly.uTorrent.events.UTorrentListEvent;
	import fly.utils.BytesUtil;
	
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.StyleEvent;
	import mx.managers.PopUpManager;
	import mx.styles.StyleManager;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	[Style(name="uploadIndicator", type="Class", inherit="no")]
	[Style(name="downloadIndicator", type="Class", inherit="no")]
	
	[Event(name="createdPopup", type="fly.uTorrent.events.UTorrentEvent")]

	public class UTorrent extends SkinnableComponent// UTorrentVisual
	{
		[SkinPart(required="true")]
		public var settingsUI:SettingsUI;
		
		[SkinPart(required="true")]
		public var torrentList:ExtendedList;
		
		[SkinPart(required="true")]
		public var  startBtn:Button;
		
		[SkinPart(required="true")]
		public var  stopBtn:Button;
		
		[SkinPart(required="true")]
		public var  pauseBtn:Button;
		
		[SkinPart(required="true")]
		public var  removeBtn:Button;
		
		[SkinPart(required="true")]
		public var  addBtn:Button;
		
		[SkinPart(required="true")]
		public var  settingsBtn:Button;
		
		[SkinPart(required="true")]
		public var  minimizeBtn:Button;
		
		[SkinPart(required="true")]
		public var  closeBtn:Button;
		
		[SkinPart(required="true")]
		public var  downTxt:Label;
		
		[SkinPart(required="true")]
		public var  upTxt:Label;
		
		private var _torrents:Torrents;
		private var _settings:Settings;
		private var _commands:Commands;
		private var _file:File;
		
		private var _initialized_bool:Boolean;
		
		private var _styleManagerDispatcher:IEventDispatcher;
		
		public function UTorrent()
		{
			_torrents = new Torrents();
			
			var nativeApplication:NativeApplication = NativeApplication.nativeApplication;
			nativeApplication.addEventListener(InvokeEvent.INVOKE, _shellInvokeHandler);
			
			_file = new File();
			_file.addEventListener(Event.SELECT, _fileSelectHandler);
		}
		
		[Inject]
		public function inject(settings:Settings, commands:Commands):void
		{
			_settings = settings;
			_commands = commands;
			_commands.addEventListener(UTorrentListEvent.LIST, _listHandler);
			
			addEventListener(MouseEvent.CLICK, _clickHandler);
		}
		
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			
			switch (instance)
			{
				case settingsUI:
					settingsUI.addEventListener(ButtonClickEvent.BUTTON_CLICK, _settingsUIButtonClickHandler);
					break;
				case torrentList:
					torrentList.labelField = "name";
					torrentList.dataProvider = _torrents.torrents;
					torrentList.addEventListener(ListEvent.ITEM_CLICK, _torrentListChangeHandler);
					break;
				case startBtn:
					startBtn.visible = startBtn.includeInLayout = false;
					startBtn.addEventListener(MouseEvent.CLICK, _startClickHandler);
					break;
				case stopBtn:
					stopBtn.visible = stopBtn.includeInLayout = false;
					stopBtn.addEventListener(MouseEvent.CLICK, _stopClickHandler);
					break;
				case pauseBtn:
					pauseBtn.visible = pauseBtn.includeInLayout = false;
					pauseBtn.addEventListener(MouseEvent.CLICK, _pauseClickHandler);
					break;
				case removeBtn:
					removeBtn.visible = removeBtn.includeInLayout = false;
					removeBtn.addEventListener(MouseEvent.CLICK, _removeClickHandler);
					break;
				case addBtn:
					addBtn.enabled = false;
					addBtn.addEventListener(MouseEvent.CLICK, _addClickHandler);
					break;
				case settingsBtn:
					settingsBtn.addEventListener(MouseEvent.CLICK, _settingsClickHandler);
					break;
				case minimizeBtn:
					minimizeBtn.addEventListener(MouseEvent.CLICK, _minimizeClickHandler);
					break;
				case closeBtn:
					closeBtn.addEventListener(MouseEvent.CLICK, _closeClickHandler);
					break;
			}
		}

		protected override function partRemoved(partName:String, instance:Object):void
		{
			switch (instance)
			{
				case settingsUI:
					settingsUI.removeEventListener(ButtonClickEvent.BUTTON_CLICK, _settingsUIButtonClickHandler);
					break;
				case torrentList:
					torrentList.removeEventListener(ListEvent.ITEM_CLICK, _torrentListChangeHandler);
					break;
				case startBtn:
					startBtn.removeEventListener(MouseEvent.CLICK, _startClickHandler);
					break;
				case stopBtn:
					stopBtn.removeEventListener(MouseEvent.CLICK, _stopClickHandler);
					break;
				case pauseBtn:
					pauseBtn.removeEventListener(MouseEvent.CLICK, _pauseClickHandler);
					break;
				case removeBtn:
					removeBtn.removeEventListener(MouseEvent.CLICK, _removeClickHandler);
					break;
				case addBtn:
					addBtn.removeEventListener(MouseEvent.CLICK, _addClickHandler);
					break;
				case settingsBtn:
					settingsBtn.removeEventListener(MouseEvent.CLICK, _settingsClickHandler);
					break;
				case minimizeBtn:
					minimizeBtn.removeEventListener(MouseEvent.CLICK, _minimizeClickHandler);
					break;
				case closeBtn:
					closeBtn.removeEventListener(MouseEvent.CLICK, _closeClickHandler);
					break;
			}

			super.partRemoved(partName,instance);
		}

		private function _shellInvokeHandler(e:InvokeEvent):void
		{
			var filePath_str:String;
			var file:File;
			for each (filePath_str in e.arguments)
			{
				file = new File(filePath_str);
				if (file.exists)
				{
					_commands.addFile(file);
				}
			}
		}
		
		private function _addClickHandler(e:MouseEvent):void
		{
			_file.browse();
		}
		
		private function _stopClickHandler(e:MouseEvent):void
		{
			_commands.stop(torrentList.selectedItems);
		}
		
		private function _startClickHandler(e:MouseEvent):void
		{
			_commands.start(torrentList.selectedItems);
		}
		
		private function _pauseClickHandler(e:MouseEvent):void
		{
			_commands.pause(torrentList.selectedItems);
		}
		
		private function _removeClickHandler(e:MouseEvent):void
		{
			_commands.remove(torrentList.selectedItems);
		}
		
		private function _minimizeClickHandler(e:MouseEvent):void
		{
			stage.nativeWindow.minimize();
		}
		
		private function _closeClickHandler(e:MouseEvent):void
		{
			stage.nativeWindow.close();
		}
		
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
				torrentList.selectedItem = null;
				_torrentListChangeHandler(null);
			}
		}
		
		private function _torrentListChangeHandler(e:ListEvent):void
		{
			_displayDownloadSpeed();
			_updateButtons();
		}
		
		private function _fileSelectHandler(e:Event):void
		{
			var file:File = new File(_file.nativePath);
			_commands.addFile(file);
		}
		
		private function _listHandler(e:UTorrentListEvent):void
		{
			_torrents.updateTorrents(e.torrents);
			
			if (torrentList.selectedItems.length)
			{
				_updateButtons();
			}
			
			_displayDownloadSpeed();
		}
		
		private function _settingsClickHandler(e:MouseEvent):void
		{
			PopUpManager.addPopUp(settingsUI, this, true);
			
			PopUpManager.centerPopUp(settingsUI);
			
			var uTorrentEvent:UTorrentEvent = new UTorrentEvent(UTorrentEvent.CREATED_POPUP);
			uTorrentEvent.popup = settingsUI;
			
			dispatchEvent(uTorrentEvent);
		}
		
		private function _settingsUIButtonClickHandler(e:ButtonClickEvent):void
		{
			if (_settings.found || e.kind == ButtonClickEventKind.OK)
			{
				PopUpManager.removePopUp(settingsUI);
			}
			
			if (e.kind == ButtonClickEventKind.OK)
			{
				_commands.stopPolling();
			}
		}
		
		private function _updateButtons():void
		{
			var torrents:Array = torrentList.selectedItems;
			
			var torrentsSelected:Boolean = Boolean(torrents.length);
			var startEnabled:Boolean;
			var resume:Boolean;
			var pauseEnabled:Boolean;
			var stopEnabled:Boolean;
			
			removeBtn.visible = removeBtn.includeInLayout = torrentsSelected;
			
			if (torrentsSelected)
			{
				var torrent:Torrent;
				
				for each (torrent in torrents)
				{
					startEnabled = startEnabled || 
										torrent.filteredStatus == TorrentInfo.STATUS_STOPPED ||
										torrent.filteredStatus == TorrentInfo.STATUS_FORCED_PAUSED ||
										torrent.filteredStatus == TorrentInfo.STATUS_PAUSED ||
										torrent.filteredStatus == TorrentInfo.STATUS_QUEUED;
					resume = resume || 
								  torrent.filteredStatus == TorrentInfo.STATUS_PAUSED;
					stopEnabled = stopEnabled || 
									   torrent.filteredStatus == TorrentInfo.STATUS_ACTIVE ||
									   torrent.filteredStatus == TorrentInfo.STATUS_FORCED_ACTIVE ||
									   torrent.filteredStatus == TorrentInfo.STATUS_CHECKING ||
									   torrent.filteredStatus == TorrentInfo.STATUS_FORCED_CHECKING ||
									   torrent.filteredStatus == TorrentInfo.STATUS_FORCED_PAUSED ||
									   torrent.filteredStatus == TorrentInfo.STATUS_PAUSED ||
									   torrent.filteredStatus == TorrentInfo.STATUS_QUEUED;
					pauseEnabled = pauseEnabled ||
										torrent.filteredStatus == TorrentInfo.STATUS_ACTIVE ||
										torrent.filteredStatus == TorrentInfo.STATUS_FORCED_ACTIVE;
				}
			}
			
			startBtn.visible = startBtn.includeInLayout = startEnabled;
			stopBtn.visible = stopBtn.includeInLayout = stopEnabled;
			pauseBtn.visible = pauseBtn.includeInLayout = pauseEnabled;
			
			startBtn.setStyle("icon", resume ? getStyle("resumeIcon") : getStyle("startIcon"));
			startBtn.toolTip = resume ? "Resume" : "Start";
		}
		
		private function _displayDownloadSpeed():void
		{
			var downloadSpeed_num:Number = 0;
			var uploadSpeed_num:Number = 0;
			var torrents:Array = torrentList.selectedItems;
			var torrent:Torrent;
			
			if (torrents.length)
			{
				for each (torrent in torrents)
				{
					downloadSpeed_num += torrent.downloadSpeed;
					uploadSpeed_num += torrent.uploadSpeed;
				}
			} else
			{
				downloadSpeed_num = _torrents.totalDownloadSpeed;
				uploadSpeed_num = _torrents.totalUploadSpeed;
			}
			downTxt.text = BytesUtil.toString(downloadSpeed_num, 2) + "/s";
			upTxt.text = BytesUtil.toString(uploadSpeed_num, 2) + "/s";
		}
	}
}