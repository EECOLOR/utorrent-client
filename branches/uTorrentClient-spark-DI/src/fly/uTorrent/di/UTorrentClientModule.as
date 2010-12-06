package fly.uTorrent.di
{
	import ee.di.AbstractModule;
	
	import fly.uTorrent.Commands;
	import fly.uTorrent.Settings;
	import fly.uTorrent.di.annotations.SettingsUI;
	import fly.uTorrent.di.annotations.UTorrent;
	
	import mx.core.IUIComponent;
	
	import skins.SettingsUISkin;
	import skins.UTorrentSkin;
	
	import spark.components.supportClasses.Skin;

	public class UTorrentClientModule extends AbstractModule
	{
		protected override function configure():void
		{
			bind(Settings).asSingleton();
			bind(Commands).asSingleton();
			
			bind(Skin).annotatedWith(SettingsUI).to(SettingsUISkin);
			bind(Skin).annotatedWith(UTorrent).to(UTorrentSkin);
		}
	}
}