package de.inutilis.inutilib
{
	import flash.utils.getTimer;

	public class GameTime
	{
		public static const k_MAX_FRAME_MILLIS:int = 100;
		private static var s_lastTime:Number;
		private static var s_frameMillis:int;
		
		public static function update():void
		{
			var time:Number = getTimer();
			if (isNaN(s_lastTime))
			{
				s_frameMillis = 1;
			}
			else
			{
				s_frameMillis = time - s_lastTime;
				if (s_frameMillis > k_MAX_FRAME_MILLIS)
				{
					s_frameMillis = k_MAX_FRAME_MILLIS;
				}
			}
			s_lastTime = time;
		}
		
		public static function get frameMillis():int
		{
			return s_frameMillis;
		}
		
		public static function timeString(seconds:int):String
		{
			var hours:int = Math.floor(seconds / 3600);
			var min:int = Math.floor(seconds / 60) % 60;
			var sec:int = seconds % 60;
			
			if (hours >= 1)
			{
				return hours + ":" + (min >= 10 ? min : "0" + min) + ":" + (sec >= 10 ? sec : "0" + sec);
			}
			return min + ":" + (sec >= 10 ? sec : "0" + sec);
		}
		
		public static function dateMySqlToDate(date:String):Date
		{
			if (date == "" || date == "0000-00-00")
			{
				return null;
			}
			
			// Split time and date
			var aux:Array = date.split(" ");
			
			// Get the date part into an array
			var d:Array = String(aux[0]).split("-");

			// Get the hour part into an array
			var h:Array = String(aux[1]).split(":");

			if (h.length > 1)
			{
				return new Date(d[0], d[1] - 1, d[2], h[0], h[1], h[2]);
			}
			else
			{
				return new Date(d[0], d[1] - 1, d[2]);
			}
		}

	}
}