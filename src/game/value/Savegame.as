package game.value
{
	import flash.utils.ByteArray;

	public class Savegame
	{
		public var mapId:int;
		public var mcColumn:int;
		public var mcRow:int;
		public var health:int;
		public var numCoins:int;
		public var numKeys:int;
		public var armor:int;
		public var shield:int;
		public var weapon:int;
		public var time:int;
		public var score:int;
		public var dataDiff:ByteArray;
		
		public function Savegame()
		{
		}
	}
}