package fly.uTorrent.decode
{
	import fly.utils.BytesUtil;
	
	public class Torrent
	{
		public var hash:String;
		public var status:Number;
		public var name:String;
		public var size:Number;
		public var percentageComplete:Number;
		public var downloaded:Number;
		public var uploaded:Number;
		public var ratio:int;
		public var uploadSpeed:Number;
		public var downloadSpeed:Number;
		public var label:String;
		public var peersConnected:Number;
		public var peers:Number;
		public var seedsConnected:Number;
		public var seeds:Number;
		
		private var _filteredStatus_uint:uint;
		
		public function Torrent(data_arr:Array)
		{
			parseData(data_arr);
			//cfDump(name + "\n1: " + Boolean(status & 1) + "\n2: " + Boolean(status & 2) + "\n4: " + Boolean(status & 4) + "\n8: " + Boolean(status & 8) + "\n16: " + Boolean(status & 16) + "\n32: " + Boolean(status & 32) + "\n64: " + Boolean(status & 64));
			//cfDump(toString());
		};
		
		public function parseData(data_arr:Array):void
		{
			hash = data_arr[TorrentInfo.HASH];
			status = data_arr[TorrentInfo.STATUS];
			name = data_arr[TorrentInfo.NAME];
			size = data_arr[TorrentInfo.SIZE];
			percentageComplete = data_arr[TorrentInfo.PERCENTAGE_COMPLETE];
			downloaded = data_arr[TorrentInfo.DOWNLOADED];
			uploaded = data_arr[TorrentInfo.UPLOADED];
			ratio = data_arr[TorrentInfo.RATIO];
			uploadSpeed = data_arr[TorrentInfo.UPLOAD_SPEED];
			downloadSpeed = data_arr[TorrentInfo.DOWNLOAD_SPEED];
			label = data_arr[TorrentInfo.LABEL];
			peersConnected = data_arr[TorrentInfo.PEERS_CONNECTED];
			peers = data_arr[TorrentInfo.PEERS];
			seedsConnected = data_arr[TorrentInfo.SEEDS_CONNECTED];
			seeds = data_arr[TorrentInfo.SEEDS];
			
			_setFilteredStatus()
		};
		
		private function _setFilteredStatus():void
		{
			var status_uint:uint;
			
			if (uint(status & TorrentInfo.STATUS_PAUSED) == TorrentInfo.STATUS_PAUSED)
			{
				status_uint = TorrentInfo.STATUS_PAUSED;
			} else if (uint(status & TorrentInfo.STATUS_FORCED_PAUSED) == TorrentInfo.STATUS_FORCED_PAUSED)
			{
				status_uint = TorrentInfo.STATUS_FORCED_PAUSED;
			} else if (uint(status & TorrentInfo.STATUS_ACTIVE) == TorrentInfo.STATUS_ACTIVE)
			{
				status_uint = TorrentInfo.STATUS_ACTIVE;
			} else if (uint(status & TorrentInfo.STATUS_FORCED_ACTIVE) == TorrentInfo.STATUS_FORCED_ACTIVE)
			{
				status_uint = TorrentInfo.STATUS_FORCED_ACTIVE;
			} else if (uint(status & TorrentInfo.STATUS_QUEUED) == TorrentInfo.STATUS_QUEUED)
			{
				status_uint = TorrentInfo.STATUS_QUEUED;
			} else if (uint(status & TorrentInfo.STATUS_CHECKING) == TorrentInfo.STATUS_CHECKING)
			{
				status_uint = TorrentInfo.STATUS_CHECKING;
			} else if (uint(status & TorrentInfo.STATUS_FORCED_CHECKING) == TorrentInfo.STATUS_FORCED_CHECKING)
			{
				status_uint = TorrentInfo.STATUS_FORCED_CHECKING;
			} else if (uint(status & TorrentInfo.STATUS_ERROR) == TorrentInfo.STATUS_ERROR)
			{
				status_uint = TorrentInfo.STATUS_ERROR;
			} else if (uint(status & TorrentInfo.STATUS_STOPPED) == TorrentInfo.STATUS_STOPPED)
			{
				status_uint = TorrentInfo.STATUS_STOPPED;
			} else
			{
				status_uint = TorrentInfo.STATUS_UNKNOWN;
			};
			
			_filteredStatus_uint = status_uint;
		};
		
		public function get filteredStatus():uint
		{
			return _filteredStatus_uint;
		};
		
		public function toString():String
		{
			var s:String = "";
			s += name + " (" + BytesUtil.toString(size, 2) + ")\n";
			s += "downloaded: " + BytesUtil.toString(downloaded, 2) + " uploaded: " + BytesUtil.toString(uploaded, 2) + "\n";
			s += "downloadSpeed: " + BytesUtil.toString(downloadSpeed, 2) + "/s uploadSpeed: " + BytesUtil.toString(uploadSpeed, 2) + "/s\n";
			s += "ratio: " + ratio + "\n";
			
			return s;
		};
	};
};