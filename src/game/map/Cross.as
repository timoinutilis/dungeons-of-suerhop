package game.map
{
	import flash.display.MovieClip;
	
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;

	public class Cross extends GameSprite
	{
		public function Cross(gameMap:GameMap)
		{
			super(gameMap);
			
			zOrderOffset = -1;
			
			var spriteClass:Class = m_gameMap.spriteClasses[ObjectsDefs.k_CROSS];
			movieClip = new spriteClass as MovieClip;
		}
		
		override public function createNew():GameSprite
		{
			var copy:Cross = new Cross(m_gameMap);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function get rawTile():int
		{
			return RawTilesDefs.k_CROSS;
		}

		override public function getUnlockLevel():int
		{
			return 3;
		}
	}
}