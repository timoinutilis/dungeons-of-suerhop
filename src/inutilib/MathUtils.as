package inutilib
{
	public class MathUtils
	{
		public static function randomInt(min:int, max:int):int
		{
			var value:int = Math.floor(Math.random() * (max - min + 1));
			return value + min;
		}
		
		public static function clamp(value:int, min:int, max:int):int
		{
			if (value < min)
			{
				return min;
			}
			if (value > max)
			{
				return max;
			}
			return value;
		}
		
		public static function packShorts(value1:int, value2:int):int
		{
			return ((value1 << 16) & 0xFFFF0000) | (value2 & 0x0000FFFF);
		}
		
		public static function firstShort(value:int):int
		{
			return (value & 0xFFFF0000) >> 16;
		}

		public static function secondShort(value:int):int
		{
			return value & 0x0000FFFF;
		}
		
		public static function interpolateSmoothstep(x:Number):Number
		{
			return x * x * (3 - 2 * x);
		}

		public static function interpolateSmoothstep2(x:Number):Number
		{
			return x * x * x * (x * (x * 6 - 15) + 10);
		}

	}
}