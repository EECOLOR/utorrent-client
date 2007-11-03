package fly.uTorrent.decode
{
	public class TorrentInfo
	{
		static public const HASH:uint = 0;					//String
		static public const STATUS:uint = 1;				//Set of bits (see Status bits)
		static public const NAME:uint = 2;					//String
		static public const SIZE:uint = 3;					//bytes
		static public const PERCENTAGE_COMPLETE:uint = 4;	//1000 == 100%
		static public const DOWNLOADED:uint = 5;			//bytes
		static public const UPLOADED:uint = 6;				//bytes
		static public const RATIO:uint = 7;					//1000 == 1
		static public const UPLOAD_SPEED:uint = 8;			//bytes
		static public const DOWNLOAD_SPEED:uint = 9;		//bytes
		static public const LABEL:uint = 11;				//String
		static public const PEERS_CONNECTED:uint = 12;		//uint
		static public const PEERS:uint = 13;				//uint
		static public const SEEDS_CONNECTED:uint = 14;		//uint
		static public const SEEDS:uint = 15;				//uint
		
		/**
		 * Status bits:
		 * If non of the bits is set, the torrent is stopped
		 */
		static public const STATUS_PAUSED:uint = 1 | 8 | 32 | 64;
		static public const STATUS_FORCED_PAUSED:uint = 1 | 8 | 32;
		static public const STATUS_ACTIVE:uint = 1 | 8 | 64;			//percentage == 1000 ? SEEDING : DOWNLOADING
		static public const STATUS_FORCED_ACTIVE:uint = 1 | 8;
		static public const STATUS_QUEUED:uint = 8 | 64;	
		static public const STATUS_CHECKING:uint = 2 | 4;
		static public const STATUS_FORCED_CHECKING:uint = 2;
		static public const STATUS_ERROR:uint = 8 | 16;
		static public const STATUS_STOPPED:uint = 8;
		static public const STATUS_UNKNOWN:uint = 0;
	};
};