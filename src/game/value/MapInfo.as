package game.value
{
	import inutilib.StringUtils;

	public class MapInfo
	{
		public var mapId:int;
		public var userId:int;
		public var name:String;
		public var unlockLevel:int;
		public var numPlayed:int;
		public var numSuccesses:int;
		public var time:int;
		public var published:Boolean;
		public var creationDate:Date;
		public var numLikes:int;
		public var global:Boolean;
		public var preSort:int;
		
		public var m_averageTime:int;
		public var m_successRatio:Number;
		public var m_dateInMillis:Number;
		
		public function MapInfo()
		{
		}
		
		public function calcAdditionalInfos():void
		{
			m_averageTime = Math.max(1, Math.round(time / numSuccesses));
			m_successRatio = numSuccesses / numPlayed;
			m_dateInMillis = creationDate.time;
			name = StringUtils.toTitle(name);
			
			preSort = 0;
			switch (mapId)
			{
				case 173: preSort = 10; break;
				case 174: preSort = 9; break;
				case 175: preSort = 8; break;
				case 176: preSort = 7; break;
			}
		}
	}
}