package game.server
{
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	import game.GameDefs;
	import game.value.Savegame;
	
	public class GameServer
	{
		private static var s_instance:GameServer;

		public static function get instance():GameServer
		{
			if (s_instance == null)
			{
				if (GameDefs.k_USE_ONLINE_SERVER)
				{
					s_instance = new OnlineGameServer();
				}
				else
				{
					s_instance = new OfflineGameServer();
				}
			}
			return s_instance;
		}

		public function GameServer()
		{
			// override
		}
		
		public function loginFromFb(fbUserId:String, source:String, onCompleteFunc:Function):void
		{
			// override
		}
		
		public function requestFbUsers(fbUserIds:Array, onCompleteFunc:Function):void
		{
			// override
		}
		
		public function requestMap(mapId:int, onCompleteFunc:Function):void
		{
			// override
		}
		
		public function requestTopMapInfos(onCompleteFunc:Function):void
		{
			// override
		}
		
		public function requestUserMapInfos(userIds:Array, onlyPublished:Boolean, onCompleteFunc:Function):void
		{
			// override
		}

		public function requestMapInfo(mapId:int, onCompleteFunc:Function):void
		{
			// override
		}
		
		public function requestSavegame(userId:int, onCompleteFunc:Function):void
		{
			// override
		}

		public function requestUserInfo(userId:int, onCompleteFunc:Function):void
		{
			// override
		}

		public function requestMapStatus(userId:int, onCompleteFunc:Function):void
		{
			// override
		}

		public function sendMap(mapId:int, userId:int, mapName:String, unlockLevel:int, data:ByteArray, messages:String, onCompleteFunc:Function):void
		{
			// override
		}
		
		public function sendPublishMap(mapId:int, mapName:String, onCompleteFunc:Function):void
		{
			// override
		}
		
		public function sendMapStarted(mapId:int, userId:int, onCompleteFunc:Function):void
		{
			// override
		}

		public function sendMapStatistics(mapId:int, userId:int, seconds:int, completed:Boolean, score:int, onCompleteFunc:Function):void
		{
			// override
		}

		public function sendTotalScore(userId:int, totalScore:int, onCompleteFunc:Function):void
		{
			// override
		}

		public function sendDeleteMap(mapId:int, onCompleteFunc:Function):void
		{
			// override
		}
		
		public function sendLike(userId:int, mapId:int, onCompleteFunc:Function):void
		{
			// override
		}
		
		public function sendSavegame(userId:int, savegame:Savegame, onCompleteFunc:Function):void
		{
			// override
		}
		
		public function sendDeleteSavegame(userId:int, onCompleteFunc:Function):void
		{
			// override
		}

		public function sendLastInfo(userId:int, lastInfo:int, onCompleteFunc:Function):void
		{
			// override
		}

	}
}