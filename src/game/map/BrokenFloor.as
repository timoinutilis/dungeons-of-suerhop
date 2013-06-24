package game.map
{
	import flash.display.MovieClip;
	
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;
	
	import inutilib.DisplayUtils;

	public class BrokenFloor extends GameSprite
	{
		public static const k_STATE_ONE_TIME_SAFE:int = 0;
		public static const k_STATE_GOOD:int = 1;
		public static const k_STATE_BAD:int = 2;
		public static const k_STATE_HOLE:int = 3;
		
		private var m_state:int;
		
		public function BrokenFloor(gameMap:GameMap, state:int, showStateIcon:Boolean)
		{
			super(gameMap);
			m_state = state;
			
			zOrderOffset = -1;
			
			var object:int = ObjectsDefs.k_BROKEN_FLOOR;
			switch (m_state)
			{
				case k_STATE_GOOD:
				case k_STATE_BAD:
					object = ObjectsDefs.k_BROKEN_FLOOR_2;
					break;

				case k_STATE_HOLE:
					object = ObjectsDefs.k_BROKEN_FLOOR_2;
					break;
			}
			
			var spriteClass:Class = m_gameMap.spriteClasses[object];
			movieClip = new spriteClass as MovieClip;

			movieClip.gotoAndStop(m_state == k_STATE_HOLE ? movieClip.totalFrames : 1);
			
			var stateIcon:MovieClip = movieClip.getChildByName("stateIcon") as MovieClip;
			if (stateIcon != null)
			{
				if (showStateIcon && m_state != k_STATE_HOLE)
				{
					stateIcon.gotoAndStop(m_state == k_STATE_GOOD ? 1 : 2);
				}
				else
				{
					stateIcon.visible = false;
				}
			}
		}
		
		override public function createNew():GameSprite
		{
			var copy:BrokenFloor = new BrokenFloor(m_gameMap, m_state, true);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function get rawTile():int
		{
			switch (m_state)
			{
				case k_STATE_ONE_TIME_SAFE:
					return RawTilesDefs.k_BROKEN_FLOOR;
					
				case k_STATE_GOOD:
					return RawTilesDefs.k_BROKEN_FLOOR_2_GOOD;
					
				case k_STATE_BAD:
					return RawTilesDefs.k_BROKEN_FLOOR_2_BAD;
					
				case k_STATE_HOLE:
					return RawTilesDefs.k_HOLE;
			}
			return 0;
		}
		
		override public function update():void
		{
			if (movieClip.currentFrame == movieClip.totalFrames)
			{
				movieClip.stop();
			}
		}
		
		override public function onPutOnMap():void
		{
			createWallMask();
		}
		
		public function brake():void
		{
			movieClip.play();
			m_state = k_STATE_HOLE;
			m_gameMap.setRawTileObject(m_rawColumn, m_rawRow, rawTile);
		}
		
		override public function getUnlockLevel():int
		{
			return 3;
		}
	}
}