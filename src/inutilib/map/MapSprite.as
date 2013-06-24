package inutilib.map
{
	import flash.display.Sprite;
	
	public class MapSprite extends Sprite
	{
		private var m_mapX:Number;
		private var m_mapY:Number;
		
		public function MapSprite()
		{
			super();
		}
		
		public function get mapX():Number
		{
			return m_mapX;
		}

		public function set mapX(mapX:Number):void
		{
			m_mapX = mapX;
		}
		
		public function get mapY():Number
		{
			return m_mapY;
		}

		public function set mapY(mapY:Number):void
		{
			m_mapY = mapY;
		}
	}
}