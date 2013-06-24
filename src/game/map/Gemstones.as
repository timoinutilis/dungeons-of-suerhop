package game.map
{
	import flash.display.MovieClip;
	
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;

	public class Gemstones extends PickUpSprite
	{
		public function Gemstones(gameMap:GameMap)
		{
			super(gameMap);
			var spriteClass:Class = m_gameMap.spriteClasses[ObjectsDefs.k_GEMSTONES];
			movieClip = new spriteClass as MovieClip;
			movieClip.gotoAndStop(1);
		}
		
		override public function createNew():GameSprite
		{
			var copy:Gemstones = new Gemstones(m_gameMap);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function get rawTile():int
		{
			return RawTilesDefs.k_GEMSTONES;
		}

	}
}