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
	import game.server.answers.AnswerFbUsers;
	import game.server.answers.AnswerMap;
	import game.server.answers.AnswerMapInfo;
	import game.server.answers.AnswerMapInfos;
	import game.server.answers.AnswerMapStatus;
	import game.server.answers.AnswerSavegame;
	import game.server.answers.AnswerUserId;
	import game.server.answers.AnswerUserInfo;
	import game.value.MapInfo;
	import game.value.MapStatus;
	import game.value.Savegame;
	import game.value.UserInfo;
	
	import de.inutilis.inutilib.GameTime;
	import de.inutilis.inutilib.MathUtils;

	public class ServerRequest
	{
		public static const k_MAP:String = "map";
		public static const k_USER_MAP_INFOS:String = "user_map_infos";
		public static const k_FB_USERS:String = "fb_users";
		public static const k_MAP_INFO:String = "map_info";
		public static const k_TOP_MAP_INFOS:String = "top_map_infos";
		public static const k_SAVEGAME:String = "savegame";
		public static const k_USER_INFO:String = "user_info";
		public static const k_MAP_STATUS:String = "map_status";
		
		private static const k_SQL_TRUE:String = "1";
		
		private var m_type:String;
		private var m_onCompleteFunc:Function;
		private var m_loader:URLLoader;
		private var m_request:URLRequest;
		
		public function ServerRequest(type:String, variables:URLVariables, onCompleteFunc:Function)
		{
			m_type = type;
			m_onCompleteFunc = onCompleteFunc;
			
			variables.type = type;
			
			m_request = new URLRequest(GameDefs.k_ONLINE_SERVER_REQUEST_URL);
			m_request.method = URLRequestMethod.POST;
			m_request.data = variables;

			m_loader = new URLLoader();
			m_loader.addEventListener(Event.COMPLETE, onComplete);
			m_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			m_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			
			MagicStone.log("REQUEST: " + variables.toString());
		}
		
		public function request():void
		{
			m_loader.load(m_request);
			m_request = null;
		}
		
		private function onComplete(event:Event):void
		{
			var jsonData:String = m_loader.data as String;
			var data:* = com.adobe.serialization.json.JSON.decode(jsonData);
			MagicStone.log("RESULT: " + jsonData);
			var isOk:Boolean = data.isOk as Boolean;
			var error:String = data.error as String;
			var result:Array = data.result as Array;
			var row:Array;
			var mapInfo:MapInfo;
			var answer:Answer = null;

			switch (m_type)
			{
				case k_MAP:
					var answerMap:AnswerMap = new AnswerMap();
					if (isOk)
					{
						row = result[0];
						answerMap.mapId = int(row[0] as String);
						answerMap.userId = int(row[1] as String);
						answerMap.mapName = row[2] as String;
						answerMap.published = ((row[3] as String) == k_SQL_TRUE);
						answerMap.levelData = OnlineGameServer.stringToBinary(row[4] as String);
						answerMap.levelMessages = row[5] as String;
					}
					answer = answerMap;
					break;

				case k_USER_MAP_INFOS:
				case k_TOP_MAP_INFOS:
					var answerMapInfos:AnswerMapInfos = new AnswerMapInfos();
					if (isOk)
					{
						var mapInfoArray:Array = new Array();
						for each (row in result)
						{
							mapInfo = new MapInfo();
							mapInfo.mapId = int(row[0] as String);
							mapInfo.userId = int(row[1] as String);
							mapInfo.name = row[2] as String;
							mapInfo.unlockLevel = int(row[3] as String);
							mapInfo.numPlayed = int(row[4] as String);
							mapInfo.numSuccesses = int(row[5] as String);
							mapInfo.time = int(row[6] as String);
							mapInfo.published = ((row[7] as String) == k_SQL_TRUE);
							mapInfo.creationDate = GameTime.dateMySqlToDate(row[8] as String);
							mapInfo.numLikes = int(row[9] as String);
							mapInfo.global = ((row[10] as String) == k_SQL_TRUE);
							mapInfo.calcAdditionalInfos();
							mapInfoArray.push(mapInfo);
						}
						answerMapInfos.mapInfos = mapInfoArray;
					}
					answer = answerMapInfos;
					break;
				
				case k_FB_USERS:
					var answerFbUsers:AnswerFbUsers = new AnswerFbUsers();
					if (isOk)
					{
						var fbUserIds:Array = new Array();
						var userIds:Array = new Array();
						for each (row in result)
						{
							fbUserIds.push(row[0] as String);
							userIds.push(int(row[1] as String));
						}
						answerFbUsers.fbUserIds = fbUserIds;
						answerFbUsers.userIds = userIds;
					}
					answer = answerFbUsers;
					break;

				case k_MAP_INFO:
					var answerMapInfo:AnswerMapInfo = new AnswerMapInfo();
					if (isOk)
					{
						row = result[0];
						mapInfo = new MapInfo();
						mapInfo.mapId = int(row[0] as String);
						mapInfo.userId = int(row[1] as String);
						mapInfo.name = row[2] as String;
						mapInfo.unlockLevel = int(row[3] as String);
						mapInfo.numPlayed = int(row[4] as String);
						mapInfo.numSuccesses = int(row[5] as String);
						mapInfo.time = int(row[6] as String);
						mapInfo.published = ((row[7] as String) == k_SQL_TRUE);
						mapInfo.creationDate = GameTime.dateMySqlToDate(row[8] as String);
						mapInfo.numLikes = int(row[9] as String);
						mapInfo.global = ((row[10] as String) == k_SQL_TRUE);
						mapInfo.calcAdditionalInfos();
						answerMapInfo.mapInfo = mapInfo;
					}
					answer = answerMapInfo;
					break;
				
				case k_SAVEGAME:
					var answerSavegame:AnswerSavegame = new AnswerSavegame();
					if (isOk && result.length > 0)
					{
						row = result[0];
						var savegame:Savegame = new Savegame();
						savegame.mapId = int(row[0] as String);
						savegame.mcColumn = int(row[1] as String);
						savegame.mcRow = int(row[2] as String);
						savegame.health = int(row[3] as String);
						savegame.numCoins = int(row[4] as String);
						savegame.numKeys = int(row[5] as String);
						savegame.armor = int(row[6] as String);
						savegame.shield = int(row[7] as String);
						savegame.weapon = int(row[8] as String);
						savegame.time = int(row[9] as String);
						savegame.score = int(row[10] as String);
						savegame.dataDiff = OnlineGameServer.stringToBinary(row[11] as String);
						answerSavegame.savegame = savegame;
					}
					answer = answerSavegame;
					break;
				
				case k_USER_INFO:
					var answerUserInfo:AnswerUserInfo = new AnswerUserInfo();
					if (isOk && result.length > 0)
					{
						row = result[0];
						var userInfo:UserInfo = new UserInfo();
						userInfo.numPlayed = int(row[0] as String);
						userInfo.numSuccesses = int(row[1] as String);
						userInfo.time = int(row[2] as String);
						userInfo.totalScore = int(row[3] as String);
						userInfo.lastInfo = int(row[4] as String);
						answerUserInfo.userInfo = userInfo;
					}
					answer = answerUserInfo;
					break;
				
				case k_MAP_STATUS:
					var answerMapStatus:AnswerMapStatus = new AnswerMapStatus();
					if (isOk)
					{
						answerMapStatus.mapStatus = new Object();
						for each (row in result)
						{
							var mapStatus:MapStatus = new MapStatus();
							mapStatus.status = int(row[1] as String);
							mapStatus.score = int(row[2] as String);
							answerMapStatus.mapStatus[int(row[0] as String)] = mapStatus; 
						}
					}
					answer = answerMapStatus;
					break;

			}
			answer.isOk = isOk;
			answer.error = error;
			m_onCompleteFunc(answer);
			removeListeners();
		}
		
		private function onError(event:ErrorEvent):void
		{
			MagicStone.log("ERROR: " + event);
			var answer:Answer;
			switch (m_type)
			{
				case k_MAP:
					answer = new AnswerMap();
					break;
				
				case k_USER_MAP_INFOS:
				case k_TOP_MAP_INFOS:
					answer = new AnswerMapInfos();
					break;
				
				case k_FB_USERS:
					answer = new AnswerFbUsers();
					break;

				case k_MAP_INFO:
					answer = new AnswerMapInfo();
					break;
				
				case k_SAVEGAME:
					answer = new AnswerSavegame();
					break;
				
				case k_USER_INFO:
					answer = new AnswerUserInfo();
					break;
				
				case k_MAP_STATUS:
					answer = new AnswerMapStatus();
					break;
			}
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