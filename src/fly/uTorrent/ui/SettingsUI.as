package fly.uTorrent.ui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import fly.uTorrent.Settings;
	import fly.uTorrent.events.ButtonClickEvent;
	import fly.uTorrent.events.ButtonClickEventKind;
	
	[Event(name="buttonClick", type="fly.flex.events.ButtonClickEvent")]
	
	public class SettingsUI extends SettingsUIVisual
	{
		private var _settings:Settings;
		
		public function SettingsUI()
		{
			_settings = Settings.instance;
		};
		
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			
			_addEventListeners();
			_setSettings();
		};
		
		private function _setSettings():void
		{
			usernameTxt.text = _settings.username;
			passwordTxt.text = _settings.password;
			urlTxt.text = _settings.url;
			portTxt.text = _settings.port ? _settings.port.toString() : null;
		};
		
		private function _addEventListeners():void
		{
			//okBtn.setStyle("icon", getStyle("okIcon"));
			//cancelBtn.setStyle("icons", getStyle("cancelIcon"));
			
			okBtn.addEventListener(MouseEvent.CLICK, _okClickHandler);
			cancelBtn.addEventListener(MouseEvent.CLICK, _cancelClickHandler);
			
			usernameTxt.addEventListener(Event.CHANGE, _textChangeHandler);
			passwordTxt.addEventListener(Event.CHANGE, _textChangeHandler);
			urlTxt.addEventListener(Event.CHANGE, _textChangeHandler);
			portTxt.addEventListener(Event.CHANGE, _textChangeHandler);
		};
		
		private function _textChangeHandler(e:Event):void
		{
			okBtn.enabled = Boolean(urlTxt.text.length) && Boolean(portTxt.text.length);
		};
		
		private function _saveValues():void
		{
			_settings.username = usernameTxt.text;
			_settings.password = passwordTxt.text;
			_settings.url = urlTxt.text;
			_settings.port = parseInt(portTxt.text);
			Settings.save();
		};
		
		private function _okClickHandler(e:MouseEvent):void
		{
			_saveValues();
			_dispatchEvent(ButtonClickEventKind.OK);
		};
		
		private function _cancelClickHandler(e:MouseEvent):void
		{
			_dispatchEvent(ButtonClickEventKind.CANCEL);
		};
		
		private function _dispatchEvent(kind_str:String):void
		{
			var buttonClickEvent:ButtonClickEvent = new ButtonClickEvent(ButtonClickEvent.BUTTON_CLICK);
			buttonClickEvent.kind = kind_str;
			
			dispatchEvent(buttonClickEvent);
		};
		
        static private var _initialized_bool:Boolean = _initialize();

        static private function _initialize():Boolean 
        {
        	/*
            if (!StyleManager.getStyleDeclaration("SettingsUI"))
            {
                var newStyleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
                newStyleDeclaration.setStyle("okIcon", Icons.OK);
                newStyleDeclaration.setStyle("cancelIcon", Icons.CANCEL);
                
                StyleManager.setStyleDeclaration("SettingsUI", newStyleDeclaration, true);
            };
            
            */
            return true;
        };			
	};
};