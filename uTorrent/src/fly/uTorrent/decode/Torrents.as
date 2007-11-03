package fly.uTorrent.decode
{
	import mx.collections.ArrayCollection;
	import fly.utils.copyObject;
	import fly.utils.cfDump;
	
	public class Torrents
	{
		private var _torrentsByHash:Object;
		private var _torrents:ArrayCollection;
		
		private var _totalDownloadSpeed_num:Number;
		private var _totalUploadSpeed_num:Number;
		
		public function Torrents()
		{
			_torrentsByHash = new Object();
			_torrents = new ArrayCollection(new Array());
		};
		
		public function updateTorrents(torrents_arr:Array):void
		{
			var torrent_arr:Array;
			var hash_str:String;
			var torrent:Torrent;
			
			_totalDownloadSpeed_num = 0;
			_totalUploadSpeed_num = 0;
			
			var unknownTorrents_obj:Object = new Object();
			
			for (hash_str in _torrentsByHash)
			{
				unknownTorrents_obj[hash_str] = _torrentsByHash[hash_str];
			};
			
			for each (torrent_arr in torrents_arr)
			{
				hash_str = torrent_arr[TorrentInfo.HASH];
				
				if (_torrentsByHash.hasOwnProperty(hash_str))
				{
					torrent = _torrentsByHash[hash_str];
					torrent.parseData(torrent_arr);	
					_torrents.itemUpdated(torrent);
				} else
				{
					torrent = new Torrent(torrent_arr);
					_torrentsByHash[hash_str] = torrent;
					_torrents.addItem(torrent);
				};
				
				if (unknownTorrents_obj.hasOwnProperty(hash_str))
				{
					delete unknownTorrents_obj[hash_str];
				};
				
				_totalDownloadSpeed_num += torrent.downloadSpeed;
				_totalUploadSpeed_num += torrent.uploadSpeed;
			};
			
			for (hash_str in unknownTorrents_obj)
			{
				torrent = unknownTorrents_obj[hash_str];
				_torrents.removeItemAt(_torrents.getItemIndex(torrent));
				delete _torrentsByHash[hash_str];
			};
		};
		
		public function get torrents():ArrayCollection
		{
			return _torrents;
		};
		
		public function get totalDownloadSpeed():Number
		{
			return _totalDownloadSpeed_num;
		};
		
		public function get totalUploadSpeed():Number
		{
			return _totalUploadSpeed_num;
		};
	};
};