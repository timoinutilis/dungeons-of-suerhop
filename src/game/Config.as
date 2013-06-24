package game
{
	public class Config
	{
		private static const k_XML_TRUE:String = "true";

		private static var m_useFacebook:Boolean = false;
		private static var m_appId:String = "";
		private static var m_userId:String = "";
		private static var m_appUrl:String = "";
		private static var m_resPath:String = "../res/";
		private static var m_debugConsole:Boolean = true;
		
		public static function setConfig(xml:XML):void
		{
			if (xml.hasOwnProperty("useFacebook"))
			{
				m_useFacebook = (xml.useFacebook.toString() == k_XML_TRUE);
			}

			if (xml.hasOwnProperty("userId"))
			{
				m_userId = xml.userId.toString();
			}

			if (xml.hasOwnProperty("appId"))
			{
				m_appId = xml.appId.toString();
			}
			
			if (xml.hasOwnProperty("appUrl"))
			{
				m_appUrl = xml.appUrl.toString();
			}
			
			if (xml.hasOwnProperty("resPath"))
			{
				m_resPath = xml.resPath.toString();
			}
			
			if (xml.hasOwnProperty("debugConsole"))
			{
				m_debugConsole = (xml.debugConsole.toString() == k_XML_TRUE);
			}
		}

		public static function get useFacebook():Boolean
		{
			return m_useFacebook;
		}
		
		public static function get userId():String
		{
			return m_userId;
		}

		public static function get appId():String
		{
			return m_appId;
		}

		public static function get appUrl():String
		{
			return m_appUrl;
		}
		
		public static function get resPath():String
		{
			return m_resPath;
		}

		public static function get debugConsole():Boolean
		{
			return m_debugConsole;
		}

	}
}