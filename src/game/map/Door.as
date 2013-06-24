package game.map
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;
	import game.constants.TilesDefs;
	
	import de.inutilis.inutilib.map.MapSprite;

	public class Door extends GameSprite
	{
		public static const k_STATE_CLOSED:int = 0;
		public static const k_STATE_OPENING:int = 1;
		public static const k_STATE_OPEN:int = 2;
		
		
		private var m_isHorizontal:Boolean;
		private var m_state:int;
		
		public function Door(gameMap:GameMap, isOpen:Boolean)
		{
			super(gameMap);
			m_state = isOpen ? k_STATE_OPEN : k_STATE_CLOSED;
			refreshMovieClip();
		}
		
		override public function createNew():GameSprite
		{
			var copy:Door = new Door(m_gameMap, false);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}

		override public function onPutOnMap():void
		{
			refreshDirection();
			refreshMovieClip();
			
			zOrderOffset = m_isHorizontal ? 1 : -1;
		}
		
		private function refreshDirection():void
		{
			m_isHorizontal = (
				(m_gameMap.getRawTile(rawColumn, rawRow + 1) & RawTilesDefs.k_MASK_TILE) == RawTilesDefs.k_EARTH
				&& (m_gameMap.getRawTile(rawColumn, rawRow) & RawTilesDefs.k_MASK_TILE) == RawTilesDefs.k_FLOOR);
		}

		override public function get rawTile():int
		{
			return RawTilesDefs.k_DOOR;
		}
		
		override public function isPositionValid():Boolean
		{
			var tile1:int;
			var tile2:int;
			
			refreshDirection();
			if (m_isHorizontal)
			{
				tile1 = m_gameMap.getRawTile(m_rawColumn, m_rawRow - 1) & RawTilesDefs.k_MASK_TILE;
				tile2 = m_gameMap.getRawTile(m_rawColumn, m_rawRow + 1) & RawTilesDefs.k_MASK_TILE;
			}
			else
			{
				tile1 = m_gameMap.getRawTile(m_rawColumn - 1, m_rawRow) & RawTilesDefs.k_MASK_TILE;
				tile2 = m_gameMap.getRawTile(m_rawColumn + 1, m_rawRow) & RawTilesDefs.k_MASK_TILE;
			}
			if (tile1 != RawTilesDefs.k_EARTH || tile2 != RawTilesDefs.k_EARTH)
			{
				return false;
			}
			
			return super.isPositionValid();
		}

		public function get currentState():int
		{
			return m_state;
		}
		
		public function open():void
		{
			if (m_state == k_STATE_CLOSED)
			{
				movieClip.play();
				m_state = k_STATE_OPENING;
				m_gameMap.setRawTileObject(m_rawColumn, m_rawRow, RawTilesDefs.k_DOOR_OPEN);
			}
		}
		
		private function refreshMovieClip():void
		{
			var spriteClass:Class;
			if (m_isHorizontal)
			{
				spriteClass = m_gameMap.spriteClasses[ObjectsDefs.k_DOOR_HORIZONTAL];
			}
			else
			{
				spriteClass = m_gameMap.spriteClasses[ObjectsDefs.k_DOOR_VERTICAL];
			}
			movieClip = new spriteClass as MovieClip;
			movieClip.gotoAndStop(m_state == k_STATE_CLOSED ? 1 : movieClip.totalFrames);
		}
		
		override public function update():void
		{
			if (m_state == k_STATE_OPENING && movieClip.currentFrame == movieClip.totalFrames)
			{
				movieClip.stop();
				m_state = k_STATE_OPEN;
			}
		}

	}
}