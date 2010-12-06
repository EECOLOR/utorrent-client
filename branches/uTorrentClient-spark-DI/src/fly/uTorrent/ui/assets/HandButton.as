package fly.uTorrent.ui.assets
{
	import spark.components.Button;

	public class HandButton extends Button
	{
		public function HandButton()
		{
			useHandCursor = true;
			buttonMode = true;
		}
		
		override public function get enabled():Boolean
		{
			return super.enabled;
		}
		
		override public function set enabled(enabled_bool:Boolean):void
		{
			super.enabled = enabled_bool;
			
			useHandCursor = enabled_bool;
			buttonMode = enabled_bool;
		}
	}
}