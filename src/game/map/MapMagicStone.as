package game.map
{
	import flash.display.MovieClip;
	
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;

	public class MapMagicStone extends GameSprite
	{
		public function MapMagicStone(gameMap:GameMap)
		{
			super(gameMap);
			var spriteClass:Class = m_gameMap.spriteClasses[ObjectsDefs.k_MAGIC_STONE];
			movieClip = new spriteClass as MovieClip;
		}
		
		override public function createNew():GameSprite
		{
			var copy:MapMagicStone = new MapMagicStone(m_gameMap);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function get rawTile():int
		{
			return RawTilesDefs.k_MAGIC_STONE;
		}

	}
}