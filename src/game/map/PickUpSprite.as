package game.map
{
	public class PickUpSprite extends GameSprite
	{
		private var m_isPickedUp:Boolean;

		public function PickUpSprite(gameMap:GameMap)
		{
			super(gameMap);
		}
		
		override public function update():void
		{
			if (m_isPickedUp)
			{
				if (movieClip.currentFrame == movieClip.totalFrames)
				{
					m_gameMap.removeSpriteFromMap(this, false);
				}
			}
		}
		
		public function pickUp():void
		{
			movieClip.play();
			m_isPickedUp = true;
			m_gameMap.setRawTileObject(m_rawColumn, m_rawRow, 0);
		}

	}
}