package de.inutilis.inutilib.ui
{
	import flash.events.Event;
	
	public class WindowEvent extends Event
	{
		public static const k_CLICK:String = "click";
		public static const k_CLOSE:String = "close";
		public static const k_ACCEPT:String = "accept";
		
		private var m_data:Object;
		
		public function WindowEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			m_data = data;
		}
		
		public function get data():Object
		{
			return m_data;
		}
	}
}