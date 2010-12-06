package fly.uTorrent.ui
{
	import ee.di.extensions.spark.SkinnableComponent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import fly.uTorrent.Settings;
	import fly.uTorrent.events.ButtonClickEvent;
	import fly.uTorrent.events.ButtonClickEventKind;
	
	import mx.core.IUIComponent;
	
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.components.supportClasses.Skin;
	
	[Event(name="buttonClick", type="fly.flex.events.ButtonClickEvent")]
	
	public class SettingsUI extends SkinnableComponent
	{
		private var _settings:Settings;
		
		[SkinPart(required="true")]
		public var usernameTxt:TextInput;
		
		[SkinPart(required="true")]
		public var passwordTxt:TextInput;
		
		[SkinPart(required="true")]
		public var urlTxt:TextInput;
		
		[SkinPart(required="true")]
		public var portTxt:TextInput;
		
		[SkinPart(required="true")]
		public var okBtn:Button;
		
		[SkinPart(required="true")]
		public var cancelBtn:Button;
		
		public function SettingsUI()
		{
		}
		
		[Inject]
		[SettingsUI]
		public function set injectSkin(value:Skin):void
		{
			setSkin(value);
		}
		
		public function setSettings(settings:Settings):void
		{
			_settings = settings;
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case usernameTxt:
					usernameTxt.addEventListener(Event.CHANGE, _textChangeHandler);
					usernameTxt.text = _settings.username;
					break;
				case passwordTxt:
					passwordTxt.addEventListener(Event.CHANGE, _textChangeHandler);
					passwordTxt.text = _settings.password;
					break;
				case urlTxt:
					urlTxt.addEventListener(Event.CHANGE, _textChangeHandler);
					urlTxt.text = _settings.url;
					break;
				case portTxt:
					portTxt.addEventListener(Event.CHANGE, _textChangeHandler);
					portTxt.text = _settings.port ? _settings.port.toString() : null;
					break;
				case okBtn:
					okBtn.addEventListener(MouseEvent.CLICK, _okClickHandler);
					break;
				case cancelBtn:
					cancelBtn.addEventListener(MouseEvent.CLICK, _cancelClickHandler);
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			switch (instance)
			{
				case usernameTxt:
					usernameTxt.removeEventListener(Event.CHANGE, _textChangeHandler);
					break;
				case passwordTxt:
					passwordTxt.removeEventListener(Event.CHANGE, _textChangeHandler);
					break;
				case urlTxt:
					urlTxt.removeEventListener(Event.CHANGE, _textChangeHandler);
					break;
				case portTxt:
					portTxt.removeEventListener(Event.CHANGE, _textChangeHandler);
					break;
				case okBtn:
					okBtn.removeEventListener(MouseEvent.CLICK, _okClickHandler);
					break;
				case cancelBtn:
					cancelBtn.addEventListener(MouseEvent.CLICK, _cancelClickHandler);
					break;
			}
			
			super.partRemoved(partName, instance);
		}
		
		private function _textChangeHandler(e:Event):void
		{
			okBtn.enabled = Boolean(urlTxt.text.length) && Boolean(portTxt.text.length);
		}
		
		private function _saveValues():void
		{
			_settings.username = usernameTxt.text;
			_settings.password = passwordTxt.text;
			_settings.url = urlTxt.text;
			_settings.port = parseInt(portTxt.text);
			_settings.save();
		}
		
		private function _okClickHandler(e:MouseEvent):void
		{
			_saveValues();
			_dispatchEvent(ButtonClickEventKind.OK);
		}
		
		private function _cancelClickHandler(e:MouseEvent):void
		{
			_dispatchEvent(ButtonClickEventKind.CANCEL);
		}
		
		private function _dispatchEvent(kind_str:String):void
		{
			var buttonClickEvent:ButtonClickEvent = new ButtonClickEvent(ButtonClickEvent.BUTTON_CLICK);
			buttonClickEvent.kind = kind_str;
			
			dispatchEvent(buttonClickEvent);
		}
	}
}