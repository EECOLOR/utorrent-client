package fly.flex.controls
{
	import mx.controls.List;
	import flash.display.Sprite;
	import mx.controls.listClasses.IListItemRenderer;
	import flash.display.Graphics;
	import mx.styles.StyleManager;
	import mx.styles.CSSStyleDeclaration;

	[Style(name="rollOverAlpha", type="Number", inherit="yes")]
	[Style(name="selectionAlpha", type="Number", inherit="yes")]
	
	public class ExtendedList extends List
	{
    	override protected function drawHighlightIndicator(
                                indicator:Sprite, x:Number, y:Number,
                                width:Number, height:Number, color:uint,
                                itemRenderer:IListItemRenderer):void
	    {
	        var g:Graphics = Sprite(indicator).graphics;
	        g.clear();
	        g.beginFill(color, getStyle("rollOverAlpha"));
	        g.drawRect(0, 0, width, height);
	        g.endFill();
	        
	        indicator.x = x;
	        indicator.y = y;
	    };
	    
	    override protected function drawSelectionIndicator(
	                                indicator:Sprite, x:Number, y:Number,
	                                width:Number, height:Number, color:uint,
	                                itemRenderer:IListItemRenderer):void
	    {
	        var g:Graphics = Sprite(indicator).graphics;
	        g.clear();
	        g.beginFill(color, getStyle("selectionAlpha"));
	        g.drawRect(0, 0, width, height);
	        g.endFill();
	        
	        indicator.x = x;
	        indicator.y = y;
	    }	    
	    
	    override public function styleChanged(styleProp_str:String):void
	    {
	    	if (styleProp_str == "rollOverAlpha" || styleProp_str == "selectionAlpha")
	    	{
	    		invalidateDisplayList();
	    	};
	    };
    
        static private var _initialized_bool:Boolean = _initialize();
    
        static private function _initialize():Boolean 
        {
            if (!StyleManager.getStyleDeclaration("ExtendedList"))
            {
                var newStyleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
                newStyleDeclaration.setStyle("rollOverAlpha", 1);
                newStyleDeclaration.setStyle("selectionAlpha", 1);
                
                StyleManager.setStyleDeclaration("ExtendedList", newStyleDeclaration, true);
            };
            
            return true;
        };
	};
};