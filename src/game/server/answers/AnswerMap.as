package game.server.answers
{
	import flash.utils.ByteArray;

	public class AnswerMap extends Answer
	{
		public var mapId:int;
		public var userId:int;
		public var mapName:String;
		public var published:Boolean;
		public var levelData:ByteArray;
		public var levelMessages:String;
		
		public function AnswerMap()
		{
		}
	}
}