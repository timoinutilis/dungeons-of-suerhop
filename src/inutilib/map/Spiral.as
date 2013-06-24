package inutilib.map
{
	import flashx.textLayout.elements.BreakElement;

	public class Spiral
	{
		public static const k_DIR_LEFT:int = 0;
		public static const k_DIR_UP:int = 1;
		public static const k_DIR_RIGHT:int = 2;
		public static const k_DIR_DOWN:int = 3;
		
		private var m_column:int;
		private var m_row:int;
		private var m_direction:int;
		private var m_startDirection:int;
		private var m_step:int;
		private var m_maxStep:int;
		
		public function Spiral()
		{
		}
		
		public function start(column:int = 0, row:int = 0, startDirection:int = k_DIR_LEFT):void
		{
			m_column = column;
			m_row = row;
			m_direction = startDirection;
			m_startDirection = startDirection;
			m_step = 0;
			m_maxStep = 1;
		}
		
		public function next():void
		{
			switch (m_direction)
			{
				case k_DIR_LEFT:
					m_column--;
					break;
				
				case k_DIR_UP:
					m_row--;
					break;
				
				case k_DIR_RIGHT:
					m_column++;
					break;

				case k_DIR_DOWN:
					m_row++;
					break;
			}
						
			m_step++;
			if (m_step == m_maxStep)
			{
				if (m_direction == ((m_startDirection + 1) % 4) || m_direction == ((m_startDirection + 3) % 4))
				{
					m_maxStep++;
				}

				m_direction = (m_direction + 1) % 4;
				m_step = 0;
			}
		}
		
		public function get currentColumn():int
		{
			return m_column;
		}

		public function get currentRow():int
		{
			return m_row;
		}
	
	}
}