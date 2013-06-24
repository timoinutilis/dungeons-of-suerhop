package game
{
	import mx.resources.ResourceManager;

	public class Parameters
	{
		private static var m_fbUserId:String = "1";
		private static var m_configUrl:String = "../config.xml";
		private static var m_mapId:int = 0;
		private static var m_requestIds:String = "";
		private static var m_source:String = "";

		public static function setParameters(paramObj:Object):void
		{
			if (paramObj.hasOwnProperty("fbUserId"))
			{
				m_fbUserId = paramObj["fbUserId"];
			}

			if (paramObj.hasOwnProperty("configUrl"))
			{
				m_configUrl = paramObj["configUrl"];
			}

			if (paramObj.hasOwnProperty("mapId"))
			{
				m_mapId = int(paramObj["mapId"]);
			}

			if (paramObj.hasOwnProperty("requestIds"))
			{
				m_requestIds = paramObj["requestIds"];
			}
			
			if (paramObj.hasOwnProperty("localeChain"))
			{
				ResourceManager.getInstance().localeChain = [(paramObj["localeChain"] as String), GameDefs.k_DEFAULT_LOCALE];
			}

			if (paramObj.hasOwnProperty("source"))
			{
				m_source = paramObj["source"];
			}

		}
		
		public static function get fbUserId():String
		{
			return m_fbUserId;
		}

		public static function get configUrl():String
		{
			return m_configUrl;
		}

		public static function get mapId():int
		{
			return m_mapId;
		}
		
		public static function resetMapId():void
		{
			m_mapId = 0;
		}

		public static function get requestIds():String
		{
			return m_requestIds;
		}

		public static function resetRequestIds():void
		{
			m_requestIds = "";
		}
		
		public static function get source():String
		{
			return m_source;
		}
		
	}
}