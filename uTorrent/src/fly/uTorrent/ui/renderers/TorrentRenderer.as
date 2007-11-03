package fly.uTorrent.ui.renderers
{
	import mx.core.mx_internal;
	import fly.uTorrent.decode.Torrent;
	import fly.uTorrent.skins.Indicators;
	import fly.flex.controls.Indicator;
	import mx.styles.StyleManager;
	import mx.styles.CSSStyleDeclaration;
	import fly.uTorrent.decode.TorrentInfo;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import fly.utils.BytesUtil;
	
	[Style(name="uploadIndicator", type="Class", inherit="no")]
	[Style(name="downloadIndicator", type="Class", inherit="no")]
	[Style(name="stopIndicator", type="Class", inherit="no")]
	[Style(name="checkIndicator", type="Class", inherit="no")]
	[Style(name="pauseIndicator", type="Class", inherit="no")]
	[Style(name="queueIndicator", type="Class", inherit="no")]
	[Style(name="errorIndicator", type="Class", inherit="no")]
	[Style(name="unknownIndicator", type="Class", inherit="no")]
	
	public class TorrentRenderer extends TorrentRendererVisual
	{
		private var _data:Torrent;
		private var _dataChanged_bool:Boolean;
		private var _childrenCreated_bool:Boolean;
		private var _overlay:Sprite;
		private var _overlayWidth_num:Number;
		private var _overlayHeight_num:Number;
		private var _indicator:Class;
		
		public function TorrentRenderer()
		{
		};
		
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			
			_childrenCreated_bool = true;
			
			_overlay = new Sprite();
			_overlay.useHandCursor = true;
			_overlay.buttonMode = true;
			rawChildren.addChildAt(_overlay, 0);
			
			ratio.useHandCursor = ratio.buttonMode = true;
			background.useHandCursor = background.buttonMode = background.mouseEnabled = true;

			invalidateProperties();
		};
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (_dataChanged_bool && _childrenCreated_bool)
			{
				_dataChanged_bool = false;
				
				_processData();
			};
		};
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (_overlay && rawChildren.getChildIndex(_overlay) > 0)
			{
				rawChildren.setChildIndex(_overlay, 0);
			};
			
			if (_overlay && (_overlayWidth_num != unscaledWidth || _overlayHeight_num != unscaledHeight))
			{
				_overlay.graphics.clear();
				_overlay.graphics.beginFill(0, 0);
				_overlay.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				_overlay.graphics.endFill();
				
				_overlayWidth_num = unscaledWidth;
				_overlayHeight_num = unscaledHeight;
			};
		};
		
		private function _processData():void
		{
			if (_data)
			{
				var speed_str:String = "";
				if (_data.filteredStatus == TorrentInfo.STATUS_ACTIVE || _data.filteredStatus == TorrentInfo.STATUS_FORCED_ACTIVE)
				{
					speed_str = BytesUtil.toString(_data.percentageComplete == 1000 ? _data.uploadSpeed : _data.downloadSpeed, 2) + "/s";
				};
				
				//maybe extend label to be able to set minwidth to 0
				
				if (label1Txt.text != _data.name)
				{
					label1Txt.text = _data.name;
				};
				label2Txt.text =  speed_str;
				
				background.percentage = _data.downloaded / _data.size;
				ratio.ratio = _data.ratio / 1000;
				
				ratio.toolTip = (_data.ratio / 1000).toString();
				
				var toolTip_str:String = "";
				toolTip_str += _data.name + "\n\n";
				toolTip_str += "Seeds: " + _data.seedsConnected + " (" + _data.seeds + ")\n";
				toolTip_str += "Peers: " + _data.peersConnected + " (" + _data.peers + ")\n";
				
				if (background.toolTip != toolTip_str)
				{
					background.toolTip = toolTip_str;
				};
				
				_setStatusIcon();
			} else
			{
				label1Txt.text = "";
				label2Txt.text = "";
				
				background.percentage = 0;
				
				statusImg.source = null;
			};
		};
		
		private function _setStatusIcon():void
		{
			var status_uint:uint = _data.filteredStatus;
			var status_str:String;
			var indicator:Class;
			
			switch (status_uint)
			{
				case TorrentInfo.STATUS_FORCED_PAUSED:
				case TorrentInfo.STATUS_PAUSED:
					indicator = getStyle("pauseIndicator");
					statusImg.toolTip = "Paused";
					break;
				case TorrentInfo.STATUS_ACTIVE:
				case TorrentInfo.STATUS_FORCED_ACTIVE:
					if (_data.percentageComplete == 1000)
					{
						indicator = getStyle("uploadIndicator");
						statusImg.toolTip = "Seeding";
					} else
					{
						indicator = getStyle("downloadIndicator");
						statusImg.toolTip = "Downloading";
					};			
					break;
				case TorrentInfo.STATUS_QUEUED:
					indicator = getStyle("queueIndicator");
					statusImg.toolTip = "Queued";
					break;					
				case TorrentInfo.STATUS_CHECKING:
				case TorrentInfo.STATUS_FORCED_CHECKING:
					indicator = getStyle("checkIndicator");
					statusImg.toolTip = "Checking";
					break;					
				case TorrentInfo.STATUS_ERROR:
					indicator = getStyle("errorIndicator");	
					statusImg.toolTip = "Error";
					break;					
				case TorrentInfo.STATUS_STOPPED:
					indicator = getStyle("stopIndicator");
					statusImg.toolTip = "Stopped";
					break;					
				case TorrentInfo.STATUS_UNKNOWN:
				default:
					indicator = getStyle("unknownIndicator");
					statusImg.toolTip = "Unknown";
					break;					
			};
			
			if (_indicator != indicator)
			{
				_indicator = indicator;
				statusImg.source = indicator;
			};
			
		};
		
		override public function get data():Object
		{
			return _data;
		};
		
		override public function set data(data_obj:Object):void
		{
			_data = data_obj as Torrent;
			_dataChanged_bool = true;
			
			invalidateProperties();
		};
		
        static private var _initialized_bool:Boolean = _initialize();
    
        static private function _initialize():Boolean 
        {
        	/*
            if (!StyleManager.getStyleDeclaration("TorrentRenderer"))
            {
                var newStyleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
                newStyleDeclaration.setStyle("uploadIndicator", Indicators.UPLOAD);
                newStyleDeclaration.setStyle("downloadIndicator", Indicators.DOWNLOAD);
                newStyleDeclaration.setStyle("stopIndicator", Indicators.STOP);
                newStyleDeclaration.setStyle("checkIndicator", Indicators.CHECK);
                newStyleDeclaration.setStyle("pauseIndicator", Indicators.PAUSE);
                newStyleDeclaration.setStyle("errorIndicator", Indicators.ERROR);
                newStyleDeclaration.setStyle("queueIndicator", Indicators.QUEUE);
                newStyleDeclaration.setStyle("unknownIndicator", Indicators.UNKNOWN);
                
                StyleManager.setStyleDeclaration("TorrentRenderer", newStyleDeclaration, true);
            };
            */
            return true;
        };			
	};
};