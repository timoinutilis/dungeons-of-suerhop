package game.map
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;
	
	public class Key extends PickUpSprite
	{		
		public function Key(gameMap:GameMap)
		{
			super(gameMap);
			var spriteClass:Class = m_gameMap.spriteClasses[ObjectsDefs.k_KEY];
			movieClip = new spriteClass as MovieClip;
			movieClip.gotoAndStop(1);
		}
		
		override public function createNew():GameSprite
		{
			var copy:Key = new Key(m_gameMap);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function get rawTile():int
		{
			return RawTilesDefs.k_KEY;
		}
		
	}
}