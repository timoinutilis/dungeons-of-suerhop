package game.map
{
	import flash.display.MovieClip;
	
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;

	public class Treasure extends PickUpSprite
	{
		public function Treasure(gameMap:GameMap)
		{
			super(gameMap);
			var spriteClass:Class = m_gameMap.spriteClasses[ObjectsDefs.k_TREASURE];
			movieClip = new spriteClass as MovieClip;
			movieClip.gotoAndStop(1);
		}
		
		override public function createNew():GameSprite
		{
			var copy:Treasure = new Treasure(m_gameMap);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function get rawTile():int
		{
			return RawTilesDefs.k_TREASURE;
		}

	}
}