package fly.uTorrent.events
{
	import flash.events.Event;
	
	public class ButtonClickEvent extends Event
	{
		static public const BUTTON_CLICK:String = "buttonClick";
		
		public var kind:String;
		
		public function ButtonClickEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var clone:ButtonClickEvent = new ButtonClickEvent(type, bubbles, cancelable);
			clone.kind = kind;
			
			return clone;
		}
	}
}