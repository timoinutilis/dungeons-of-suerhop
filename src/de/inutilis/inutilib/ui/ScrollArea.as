package de.inutilis.inutilib.ui
{
	import flash.display.DisplayObjectContainer;
	
	import de.inutilis.inutilib.GameTime;
	import de.inutilis.inutilib.MathUtils;

	public class ScrollArea
	{
		protected var m_container:DisplayObjectContainer;
		private var m_originalContainerY:Number;
		private var m_scrollPosition:Number;
		private var m_timer:int;
		private var m_scrollTime:int;
		private var m_scrollStart:Number;
		protected var m_scrollEnd:Number;

		public function ScrollArea(container:DisplayObjectContainer)
		{
			m_container = container;

			m_originalContainerY = m_container.y;
			m_scrollPosition = 0;
			m_scrollStart = 0;
			m_scrollEnd = 0;
		}
		
		public function scrollTo(y:Number, scrollTime:int):void
		{
			m_scrollTime = scrollTime;
			m_timer = 0;
			m_scrollStart = m_scrollPosition;
			m_scrollEnd = y;
		}
		
		public function scrollFromTo(fromY:Number, toY:Number, scrollTime:int, timeStart:int = 0):void
		{
			m_scrollTime = scrollTime;
			m_timer = timeStart;
			m_scrollStart = fromY;
			m_scrollPosition = fromY;
			m_scrollEnd = toY;
		}
		
		public function update():void
		{
			if (m_scrollPosition != m_scrollEnd)
			{
				m_timer += GameTime.frameMillis;
				if (m_timer >= m_scrollTime)
				{
					m_scrollPosition = m_scrollEnd;
				}
				else
				{
					var dist:Number = m_scrollEnd - m_scrollStart;
					var factor:Number = MathUtils.interpolateSmoothstep2(m_timer / m_scrollTime);
					m_scrollPosition = m_scrollStart + (factor * dist);
				}
				m_container.y = m_originalContainerY - Math.round(m_scrollPosition);
			}
		}

	}
}