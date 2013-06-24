package inutilib.ui
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class PositionRectangle extends Rectangle
	{
		public static const k_TOP_LEFT:int = 0;
		public static const k_TOP_CENTER:int = 1;
		public static const k_TOP_RIGHT:int = 2;
		public static const k_CENTER_LEFT:int = 3;
		public static const k_CENTER:int = 4;
		public static const k_CENTER_RIGHT:int = 5;
		public static const k_BOTTOM_LEFT:int = 6;
		public static const k_BOTTOM_CENTER:int = 7;
		public static const k_BOTTOM_RIGHT:int = 8;
		
		
		public function PositionRectangle(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0)
		{
			super(x, y, width, height);
		}
		
		public function getPoint(position:int):Point
		{
			switch (position)
			{
				case k_TOP_LEFT:
					return topLeft;
					
				case k_TOP_CENTER:
					return new Point(left + width / 2, top);
					
				case k_TOP_RIGHT:
					return new Point(right, top);
					
				case k_CENTER_LEFT:
					return new Point(left, top + height / 2);
					
				case k_CENTER:
					return new Point(left + width / 2, top + height / 2);
					
				case k_CENTER_RIGHT:
					return new Point(right, top + height / 2);
					
				case k_BOTTOM_LEFT:
					return new Point(left, bottom);
					
				case k_BOTTOM_CENTER:
					return new Point(left + width / 2, bottom);
					
				case k_BOTTOM_RIGHT:
					return bottomRight;
			}
			throw new Error("undefined position");
		}
		
		public function getOppositePoint(position:int):Point
		{
			switch (position)
			{
				case k_TOP_LEFT: position = k_BOTTOM_RIGHT; break;
				case k_TOP_CENTER: position = k_BOTTOM_CENTER; break;
				case k_TOP_RIGHT: position = k_BOTTOM_LEFT; break;
				case k_CENTER_LEFT: position = k_CENTER_RIGHT; break;
				case k_CENTER_RIGHT: position = k_CENTER_LEFT; break;
				case k_BOTTOM_LEFT: position = k_TOP_RIGHT; break;
				case k_BOTTOM_CENTER: position = k_TOP_CENTER; break;
				case k_BOTTOM_RIGHT: position = k_TOP_LEFT; break;
			}
			return getPoint(position);
		}
		
	}
}