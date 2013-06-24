package game.map
{
	import flash.display.MovieClip;
	
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;

	public class Shop extends GameSprite
	{
		public static const k_ARMOR:int = 0;
		public static const k_SHIELD:int = 1;
		public static const k_WEAPON:int = 2;
		
		private var m_type:int;
		
		public function Shop(gameMap:GameMap, type:int)
		{
			super(gameMap);
			m_type = type;
			
			var sprite:int = 0;
			switch (type)
			{
				case k_ARMOR:
					sprite = ObjectsDefs.k_SHOP_ARMOR;
					break;
				
				case k_SHIELD:
					sprite = ObjectsDefs.k_SHOP_SHIELD;
					break;

				case k_WEAPON:
					sprite = ObjectsDefs.k_SHOP_WEAPON;
					break;
			}
			var spriteClass:Class = m_gameMap.spriteClasses[sprite];
			movieClip = new spriteClass as MovieClip;
		}
		
		override public function createNew():GameSprite
		{
			var copy:Shop = new Shop(m_gameMap, m_type);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function get rawTile():int
		{
			switch (m_type)
			{
				case k_ARMOR: return RawTilesDefs.k_SHOP_ARMOR; break;
				case k_SHIELD: return RawTilesDefs.k_SHOP_SHIELD; break;
				case k_WEAPON: return RawTilesDefs.k_SHOP_WEAPON; break;
			}
			return 0;
		}

	}
}