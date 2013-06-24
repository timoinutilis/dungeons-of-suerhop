package game.server
{
	import flash.utils.ByteArray;

	public class OfflineMapData
	{
		public var mapId:int;
		public var userId:int;
		public var mapName:String;
		public var totalSeconds:int;
		public var totalCompleted:int;
		public var totalPlayed:int;
		public var published:Boolean;
		public var levelData:ByteArray;
		public var levelMessages:String;

		public function OfflineMapData()
		{
		}
	}
}