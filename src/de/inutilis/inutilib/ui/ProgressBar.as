package de.inutilis.inutilib.ui
{
	import flash.display.Sprite;
	
	import de.inutilis.inutilib.GameTime;

	public class ProgressBar
	{
		private var m_sprite:Sprite;
		private var m_actualValue:Number;
		private var m_maxValue:Number;
		private var m_shownValue:Number;
		private var m_fullWidth:Number;
		private var m_speed:Number;
		
		public function ProgressBar(sprite:Sprite, maxValue:Number, currentValue:Number = 0)
		{
			m_sprite = sprite;
			m_maxValue = maxValue;
			m_actualValue = currentValue;
			m_shownValue = currentValue;
			
			m_fullWidth = m_sprite.width;
			m_speed = 0;
			
			refreshSprite();
		}
		
		public function set currentValue(value:Number):void
		{
			m_actualValue = value;
			m_speed = (m_actualValue - m_shownValue);
		}
		
		public function set maxValue(value:Number):void
		{
			m_maxValue = value;
		}
		
		public function update():void
		{
			if (m_speed != 0)
			{
				m_shownValue += m_speed * GameTime.frameMillis / 1000;
				if (   (m_speed > 0 && m_shownValue >= m_actualValue)
					|| (m_speed < 0 && m_shownValue <= m_actualValue) )
				{
					m_shownValue = m_actualValue;
					m_speed = 0;
				}
				
				refreshSprite();
			}
		}
		
		private function refreshSprite():void
		{
			m_sprite.width = m_fullWidth * m_shownValue / m_maxValue;
		}
	}
}