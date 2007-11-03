package fly.uTorrent.events
{
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class UTorrentEvent extends Event
	{
		static public const CREATED_POPUP:String = "createdPopup";
		
		public function UTorrentEvent(type_str:String, bubbles_bool:Boolean = false, cancelable_bool:Boolean = false)
		{
			super(type_str, bubbles_bool, cancelable_bool);
		};
		
		public var popup:DisplayObject;
	};
};