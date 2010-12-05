package fly.uTorrent.ui.renderers
{
	import mx.core.UIComponent;
	import mx.styles.StyleManager;
	import mx.styles.CSSStyleDeclaration;
	import flash.display.LineScaleMode;

	[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	[Style(name="backgroundAlpha", type="uint", format="Color", inherit="no")]
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	[Style(name="borderAlpha", type="uint", format="Color", inherit="no")]
	[Style(name="borderThickness", type="Number", inherit="no")]

	public class TorrentRendererBackground extends UIComponent
	{
		private var _percentage_num:Number;
		private var _percentageChanged_bool:Boolean;
		
		private var _width_num:Number;
		private var _height_num:Number;
		
		public function TorrentRendererBackground()
		{
			
		};
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (!isNaN(_percentage_num) && (_percentageChanged_bool || _width_num != unscaledWidth || _height_num != unscaledHeight))
			{
				_percentageChanged_bool = false;
				graphics.clear();
				graphics.beginFill(getStyle("backgroundColor"), getStyle("backgroundAlpha"));
				graphics.drawRect(0, 0, _percentage_num * unscaledWidth, unscaledHeight);
				graphics.endFill();
				
				/*
					draw the hit area
				*/
				graphics.beginFill(0, 0);
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
				
				var borderThickness_num:Number = getStyle("borderThickness");
				var halfBorderThickness_num:Number = borderThickness_num / 2;
				
				graphics.lineStyle(borderThickness_num, getStyle("borderColor"), getStyle("borderAlpha"), true, LineScaleMode.NONE);
				graphics.drawRect(halfBorderThickness_num, halfBorderThickness_num, unscaledWidth - borderThickness_num, unscaledHeight - borderThickness_num);
				
				_width_num = unscaledWidth;
				_height_num = unscaledHeight;
			};
		};
		
		public function get percentage():Number
		{
			return _percentage_num;
		};
		
		public function set percentage(percentage_num:Number):void
		{
			if (_percentage_num != percentage_num)
			{
				_percentage_num = percentage_num;
				_percentage_num = Math.min(1, _percentage_num);
				_percentage_num = Math.max(0, _percentage_num);
				_percentageChanged_bool = true;
				
				invalidateDisplayList();
			};
		};
	};
};