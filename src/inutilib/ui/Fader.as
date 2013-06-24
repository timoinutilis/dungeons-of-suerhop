package inutilib.ui
{
	import flash.display.Sprite;
	
	import inutilib.GameTime;
	
	public class Fader extends Sprite
	{
		public static const k_FADE_IN:int = 0;
		public static const k_FADE_OUT:int = 1;
		
		private var m_time:int;
		private var m_fade:int;
		private var m_timer:int;
		private var m_finished:Boolean;
		
		public function Fader(color:int, width:int, height:int, time:int, fade:int = k_FADE_IN)
		{
			super();
			m_time = time;
			m_fade = fade;
			
			graphics.beginFill(color);
			graphics.drawRect(0, 0, width, height);
			mouseEnabled = false;
			
			reset(fade);
		}
		
		public function reset(fade:int = k_FADE_IN):void
		{
			m_fade = fade;
			m_finished = false;
			if (m_fade == k_FADE_OUT)
			{
				alpha = 0;
				m_timer = 0;
			}
			else
			{
				alpha = 1;
				m_timer = m_time;
			}
		}
		
		public function update():void
		{
			if (!m_finished)
			{
				if (m_fade == k_FADE_OUT)
				{
					m_timer += GameTime.frameMillis;
					if (m_timer >= m_time)
					{
						m_timer = m_time;
						m_finished = true;
					}
				}
				else
				{
					m_timer -= GameTime.frameMillis;
					if (m_timer <= 0)
					{
						m_timer = 0;
						m_finished = true;
					}
				}
				
				alpha = m_timer / m_time;
			}
		}
		
		public function get finished():Boolean
		{
			return m_finished;
		}
		
	}
}