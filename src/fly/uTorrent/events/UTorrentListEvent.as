package fly.uTorrent.events
{
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class UTorrentListEvent extends Event
	{
		static public const LIST:String = "list";
		
		public function UTorrentListEvent(type_str:String, bubbles_bool:Boolean = false, cancelable_bool:Boolean = false)
		{
			super(type_str, bubbles_bool, cancelable_bool);
		};
		
		public var torrents:Array;
	};
};