package game.server
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import game.GameDefs;
	import game.MagicStone;
	import game.server.answers.Answer;

	public class ServerSend
	{
		public static const k_MAP:String = "map";
		public static const k_PUBLISH_MAP:String = "publish_map";
		public static const k_DELETE_MAP:String = "delete_map";
		public static const k_MAP_STARTED:String = "map_started";
		public static const k_MAP_STATISTICS:String = "map_statistics";
		public static const k_TOTAL_SCORE:String = "total_score";
		public static const k_LIKE:String = "like";
		public static const k_SAVEGAME:String = "savegame";
		public static const k_DELETE_SAVEGAME:String = "delete_savegame";
		public static const k_LAST_INFO:String = "last_info";
		
		private var m_type:String;
		private var m_onCompleteFunc:Function;
		private var m_loader:URLLoader;
		private var m_request:URLRequest;
		
		public function ServerSend(type:String, variables:URLVariables, onCompleteFunc:Function)
		{
			m_type = type;
			m_onCompleteFunc = onCompleteFunc;
			
			variables.type = type;
			
			m_request = new URLRequest(GameDefs.k_ONLINE_SERVER_SEND_URL);
			m_request.method = URLRequestMethod.POST;
			m_request.data = variables;
			
			m_loader = new URLLoader();
			m_loader.addEventListener(Event.COMPLETE, onComplete);
			m_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			m_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			
			MagicStone.log("SEND: " + variables.toString());
		}
		
		public function send():void
		{
			m_loader.load(m_request);
			m_request = null;
		}
		
		private function onComplete(event:Event):void
		{
			var jsonData:String = m_loader.data as String;
			var data:* = com.adobe.serialization.json.JSON.decode(jsonData);
			MagicStone.log("RESULT: " + jsonData);
			
			var answer:Answer = new Answer();
			answer.isOk = data.isOk as Boolean;
			answer.error = data.error as String;
			answer.insertId = data.result as int;
			m_onCompleteFunc(answer);

			removeListeners();
		}
		
		private function onError(event:ErrorEvent):void
		{
			MagicStone.log("ERROR: " + event);
			var answer:Answer = new Answer();
			answer.isOk = false;
			answer.error = event.text;
			m_onCompleteFunc(answer);
			removeListeners();
		}
		
		private function removeListeners():void
		{
			m_loader.removeEventListener(Event.COMPLETE, onComplete);
			m_loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			m_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		}
	}
}