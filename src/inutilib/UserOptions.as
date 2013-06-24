package inutilib
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;

	public class UserOptions extends EventDispatcher
	{
		public static const k_MUSIC:String = "user_option_music";
		public static const k_SFX:String = "user_option_sfx";

		private static var s_instance:UserOptions;
		
		private var m_sharedObject:SharedObject;

		public static function get instance():UserOptions
		{
			if (s_instance == null)
			{
				s_instance = new UserOptions();
			}
			return s_instance;
		}

		public function UserOptions()
		{
		}
		
		public function init(filename:String):void
		{
			m_sharedObject = SharedObject.getLocal(filename, "/");
		}
		
		public function setBoolean(name:String, value:Boolean):void
		{
			m_sharedObject.data[name] = value;
			dispatchEvent(new Event(name));
		}

		public function getBoolean(name:String):Boolean
		{
			if (m_sharedObject.data.hasOwnProperty(name))
			{
				return m_sharedObject.data[name] as Boolean;
			}
			return true;
		}
	}
}