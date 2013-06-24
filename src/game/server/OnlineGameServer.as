package game.server
{
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import game.MagicStone;
	import game.value.Savegame;
	
	import inutilib.Base64;
	import inutilib.MathUtils;

	public class OnlineGameServer extends GameServer
	{
		public function OnlineGameServer()
		{
			super();
		}
		
		override public function loginFromFb(fbUserId:String, source:String, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.fb_user_id = fbUserId;
			variables.source = source;
			
			var login:ServerLogin = new ServerLogin(variables, onCompleteFunc);
			login.login();
		}

		override public function requestFbUsers(fbUserIds:Array, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.fb_user_ids = fbUserIds.join(",");
			
			var request:ServerRequest = new ServerRequest(ServerRequest.k_FB_USERS, variables, onCompleteFunc);
			request.request();
		}

		override public function requestMap(mapId:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.map_id = mapId;
			
			var request:ServerRequest = new ServerRequest(ServerRequest.k_MAP, variables, onCompleteFunc);
			request.request();
		}
				
		override public function requestTopMapInfos(onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			
			var request:ServerRequest = new ServerRequest(ServerRequest.k_TOP_MAP_INFOS, variables, onCompleteFunc);
			request.request();
		}
		
		override public function requestUserMapInfos(userIds:Array, onlyPublished:Boolean, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.user_ids = userIds.join(",");
			variables.only_published = onlyPublished;
			
			var request:ServerRequest = new ServerRequest(ServerRequest.k_USER_MAP_INFOS, variables, onCompleteFunc);
			request.request();
		}
		
		override public function requestMapInfo(mapId:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.map_id = mapId;
			
			var request:ServerRequest = new ServerRequest(ServerRequest.k_MAP_INFO, variables, onCompleteFunc);
			request.request();
		}

		override public function requestSavegame(userId:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.user_id = userId;
			
			var request:ServerRequest = new ServerRequest(ServerRequest.k_SAVEGAME, variables, onCompleteFunc);
			request.request();
		}

		override public function requestUserInfo(userId:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.user_id = userId;
			
			var request:ServerRequest = new ServerRequest(ServerRequest.k_USER_INFO, variables, onCompleteFunc);
			request.request();
		}
		
		override public function requestMapStatus(userId:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.user_id = userId;
			
			var request:ServerRequest = new ServerRequest(ServerRequest.k_MAP_STATUS, variables, onCompleteFunc);
			request.request();
		}

		override public function sendMap(mapId:int, userId:int, mapName:String, unlockLevel:int, data:ByteArray, messages:String, onCompleteFunc:Function):void
		{
			var dataString:String = binaryToString(data);

			var variables:URLVariables = new URLVariables();
			variables.map_id = mapId;
			variables.user_id = userId;
			variables.map_name = mapName;
			variables.unlock_level = unlockLevel;
			variables.data = dataString;
			variables.messages = messages;
			
			var send:ServerSend = new ServerSend(ServerSend.k_MAP, variables, onCompleteFunc);
			send.send();
		}
		
		override public function sendPublishMap(mapId:int, mapName:String, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.map_id = mapId;
			variables.map_name = mapName;
			
			var send:ServerSend = new ServerSend(ServerSend.k_PUBLISH_MAP, variables, onCompleteFunc);
			send.send();
		}
		
		override public function sendMapStarted(mapId:int, userId:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.map_id = mapId;
			variables.user_id = userId;

			var send:ServerSend = new ServerSend(ServerSend.k_MAP_STARTED, variables, onCompleteFunc);
			send.send();
		}
		
		override public function sendMapStatistics(mapId:int, userId:int, seconds:int, completed:Boolean, score:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.map_id = mapId;
			variables.user_id = userId;
			variables.seconds = seconds;
			variables.completed = (completed ? 1 : 0);
			variables.score = score;
			
			var send:ServerSend = new ServerSend(ServerSend.k_MAP_STATISTICS, variables, onCompleteFunc);
			send.send();
		}
		
		override public function sendTotalScore(userId:int, totalScore:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.user_id = userId;
			variables.total_score = totalScore;
			
			var send:ServerSend = new ServerSend(ServerSend.k_TOTAL_SCORE, variables, onCompleteFunc);
			send.send();
		}
		
		override public function sendDeleteMap(mapId:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.map_id = mapId;
			
			var send:ServerSend = new ServerSend(ServerSend.k_DELETE_MAP, variables, onCompleteFunc);
			send.send();
		}
		
		override public function sendLike(userId:int, mapId:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.user_id = userId;
			variables.map_id = mapId;
			
			var send:ServerSend = new ServerSend(ServerSend.k_LIKE, variables, onCompleteFunc);
			send.send();
		}
		
		override public function sendSavegame(userId:int, savegame:Savegame, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.user_id = userId;
			variables.map_id = savegame.mapId;
			variables.mc_column = savegame.mcColumn;
			variables.mc_row = savegame.mcRow;
			variables.health = savegame.health;
			variables.num_coins = savegame.numCoins;
			variables.num_keys = savegame.numKeys;
			variables.armor = savegame.armor;
			variables.shield = savegame.shield;
			variables.weapon = savegame.weapon;
			variables.time = savegame.time;
			variables.score = savegame.score;
			variables.data_diff = binaryToString(savegame.dataDiff);
			
			var send:ServerSend = new ServerSend(ServerSend.k_SAVEGAME, variables, onCompleteFunc);
			send.send();
		}
		
		override public function sendDeleteSavegame(userId:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.user_id = userId;

			var send:ServerSend = new ServerSend(ServerSend.k_DELETE_SAVEGAME, variables, onCompleteFunc);
			send.send();
		}

		override public function sendLastInfo(userId:int, lastInfo:int, onCompleteFunc:Function):void
		{
			var variables:URLVariables = new URLVariables();
			variables.user_id = userId;
			variables.last_info = lastInfo;
			
			var send:ServerSend = new ServerSend(ServerSend.k_LAST_INFO, variables, onCompleteFunc);
			send.send();
		}

		public static function binaryToString(data:ByteArray):String
		{
			data.deflate();
			var base64:String = Base64.encodeByteArray(data);
			MagicStone.log("base 64: " + base64);
			return base64;
		}
		
		public static function stringToBinary(dataString:String):ByteArray
		{
			var data:ByteArray = Base64.decodeToByteArray(dataString);
			data.inflate();
			return data;
		}

	}
}