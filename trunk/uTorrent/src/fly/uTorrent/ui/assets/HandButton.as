package fly.uTorrent.ui.assets
{
	import mx.controls.Button;
	import fly.utils.cfDump;
	import mx.core.mx_internal;

	public class HandButton extends Button
	{
		private var _childrenCreated_bool:Boolean;
		
		public function HandButton()
		{
			useHandCursor = true;
			buttonMode = true;
		};
		
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			_childrenCreated_bool = true;
		};
		
		/*
			Needed to make runtime skins work
		*/
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			if (_childrenCreated_bool)
			{
				mx_internal::viewSkin();
			};
		};
		
		override public function get enabled():Boolean
		{
			return super.enabled;
		};
		
		override public function set enabled(enabled_bool:Boolean):void
		{
			super.enabled = enabled_bool;
			
			useHandCursor = enabled_bool;
			buttonMode = enabled_bool;
		};
	};
};