package game.map
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;
	
	public class Potion extends PickUpSprite
	{		
		public function Potion(gameMap:GameMap)
		{
			super(gameMap);
			var spriteClass:Class = m_gameMap.spriteClasses[ObjectsDefs.k_POTION];
			movieClip = new spriteClass as MovieClip;
			movieClip.gotoAndStop(1);
		}
		
		override public function createNew():GameSprite
		{
			var copy:Potion = new Potion(m_gameMap);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function get rawTile():int
		{
			return RawTilesDefs.k_POTION;
		}
		
	}
}