package inutilib.ui
{

	public class WindowManager
	{
		private static var s_instance:WindowManager;
		
		private var m_windows:Array;
		private var m_numExclusives:int;

		public static function get instance():WindowManager
		{
			if (s_instance == null)
			{
				s_instance = new WindowManager();
			}
			return s_instance;
		}

		public function WindowManager()
		{
			m_windows = new Array();
		}
		
		public function addWindow(window:Window):void
		{
			m_windows.push(window);
			if (window.exclusive)
			{
				m_numExclusives++;
			}
		}
		
		public function removeWindow(window:Window):void
		{
			m_windows.splice(m_windows.indexOf(window), 1);
			if (window.exclusive)
			{
				m_numExclusives--;
			}
		}
		
		public function hasExclusiveWindow():Boolean
		{
			return (m_numExclusives > 0);
		}
		
		public function update():void
		{
			for each (var window:Window in m_windows)
			{
				window.update();
			}
		}
	}
}