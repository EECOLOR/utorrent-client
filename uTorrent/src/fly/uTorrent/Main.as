package fly.uTorrent
{
	import fly.utils.cfDump;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import com.adobe.serialization.json.JSON;
	import mx.utils.ObjectUtil;
	import fly.uTorrent.decode.Torrent;
	import flash.net.URLRequestHeader;
	import fly.serialization.base64.Base64;
	import fly.utils.cfDumpClear;
	import mx.managers.PopUpManager;
	import fly.flex.events.ButtonClickEvent;
	import fly.flex.events.ButtonClickEventKind;
	import fly.uTorrent.ui.SettingsUI;
	import fly.uTorrent.ui.UTorrent;
	import mx.core.Application;
	import fly.uTorrent.ui.assets.CloseButton;
	import mx.containers.HBox;
	import mx.controls.Spacer;
	import fly.uTorrent.ui.assets.MinimizeButton;
	import flash.events.MouseEvent;
	
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import flash.events.EventPhase;
	import flash.display.DisplayObject;
	import fly.uTorrent.events.UTorrentEvent;
	import mx.core.UIComponent;
	import mx.managers.CursorManager;
	import fly.net.OutgoingLocalConnection;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	
	[Style(name="resizeCursor", type="Class", inherit="no")]
	
	public class Main extends Application
	{
		private var _uTorrent:UTorrent;
		private var _moveArea:UIComponent;
		private var _dragging_bool:Boolean;
		
		public function Main()
		{
			OutgoingLocalConnection.throwErrors = false;
			cfDumpClear();
			cfDump("uTorrent application started...");
			
			addEventListener(Event.ADDED_TO_STAGE, _addedToStageHandler);
		};
		
		private function _addedToStageHandler(e:Event):void
		{
		};
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			_uTorrent = new UTorrent();
			_uTorrent.addEventListener(MouseEvent.MOUSE_DOWN, _uTorrentMouseDownHandler);
			_uTorrent.percentWidth = 100;
			_uTorrent.percentHeight = 100;
			addChild(_uTorrent);
			
			_moveArea = new UIComponent();
			_moveArea.graphics.beginFill(0xFFFFFF, 0.5);
			_moveArea.graphics.drawRect(0, 0, 40, 40);
			_moveArea.graphics.endFill();
			_moveArea.setStyle("right", 10);
			_moveArea.setStyle("bottom", 10);
			_moveArea.useHandCursor = true;
			_moveArea.buttonMode = true;
			_moveArea.addEventListener(MouseEvent.MOUSE_DOWN, _moveAreaMouseDownHandler);
			addChild(_moveArea);
		};
		
		private function _uTorrentMouseDownHandler(e:MouseEvent):void
		{
			if (e.eventPhase != EventPhase.BUBBLING_PHASE)
			{
				stage.nativeWindow.startMove();
			};
		};
		
		private function _moveAreaMouseDownHandler(e:MouseEvent):void
		{
			stage.nativeWindow.startResize();
		};
		
	};
};