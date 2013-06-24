package game.value
{
	import game.GameDefs;

	public class UserInfo
	{
		public var numPlayed:int;
		public var numSuccesses:int;
		public var time:int;
		public var totalScore:int;
		public var lastInfo:int;

		public function UserInfo()
		{
		}
		
		public function addStatistics(seconds:int, completed:Boolean):void
		{
			numPlayed++;
			if (completed)
			{
				numSuccesses++;
				time += seconds;
			}
		}
		
		public function getLevel():int
		{
			return int(totalScore / GameDefs.k_POINTS_PER_LEVEL) + 1;
		}
	}
}