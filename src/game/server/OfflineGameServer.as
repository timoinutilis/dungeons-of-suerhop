package game.server
{
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	
	import game.MagicStone;
	import game.value.MapInfo;
	import game.server.answers.Answer;
	import game.server.answers.AnswerMap;
	import game.server.answers.AnswerMapInfos;
	
	import inutilib.ArrayUtils;
	import inutilib.map.MapData;

	public class OfflineGameServer extends GameServer
	{
		private var m_sharedObject:SharedObject;
		private var m_mapDatas:Array;
		
		public function OfflineGameServer()
		{
			super();
			m_mapDatas = new Array();
			
			m_sharedObject = SharedObject.getLocal("inutilis.de/magicstone", "/");
			loadMaps();
		}
		
		private function saveMaps():void
		{
			for each (var mapData:OfflineMapData in m_mapDatas)
			{
				m_sharedObject.data[mapData.mapId] = mapData;
			}
			trace("DB saved");
		}
		
		private function loadMaps():void
		{
			for each (var object:Object in m_sharedObject.data)
			{
				var mapData:OfflineMapData = new OfflineMapData();
				mapData.mapId = object.mapId;
				mapData.userId = object.playerId;
				mapData.mapName = object.mapName;
				mapData.totalSeconds = object.totalSeconds;
				mapData.totalCompleted = object.totalCompleted;
				mapData.totalPlayed = object.totalPlayed;
				mapData.published = object.published;
				mapData.levelData = object.levelData;
				mapData.levelMessages = object.levelMessages;
				
				m_mapDatas[mapData.mapId] = mapData;
			}
			MagicStone.log("DB loaded");
		}
		
		override public function requestMap(mapId:int, onCompleteFunc:Function):void
		{
			MagicStone.log("OFFLINE SERVER: requestMap mapId = " + mapId);

			var answer:AnswerMap = new AnswerMap();
			var mapData:OfflineMapData = m_mapDatas[mapId];
			if (mapData != null)
			{
				answer.isOk = true;
				answer.mapId = mapId;
				answer.userId = mapData.userId;
				answer.mapName = mapData.mapName;
				answer.levelData = mapData.levelData;
				answer.levelData.position = 0;
				answer.levelMessages = mapData.levelMessages;
			}
			else
			{
				answer.isOk = false;
			}
			
			var timer:AnswerTimer = new AnswerTimer(onCompleteFunc, answer);
			timer.start();
		}
		
		override public function requestTopMapInfos(onCompleteFunc:Function):void
		{
			MagicStone.log("OFFLINE SERVER: requestTopMapInfos");
			
			var mapData:OfflineMapData;
			
			var selection:Array = new Array();
			for each (mapData in m_mapDatas)
			{
				if (mapData.published)
				{
					selection.push(mapData);
				}
			}

			var answer:AnswerMapInfos = new AnswerMapInfos();
			if (selection.length > 0)
			{
				answer.isOk = true;
				answer.mapInfos = new Array();
				
				var num:int = Math.min(10, selection.length);
				for (var i:int = 0; i < num; i++)
				{
					mapData = selection[i];
					answer.mapInfos.push(createMapInfo(mapData));
				}
			}
			else
			{
				answer.isOk = false;
			}
			
			var timer:AnswerTimer = new AnswerTimer(onCompleteFunc, answer);
			timer.start();
		}
		
		override public function requestUserMapInfos(userIds:Array, onlyPublished:Boolean, onCompleteFunc:Function):void
		{
			MagicStone.log("OFFLINE SERVER: requestPlayerMapInfos playerIds = " + userIds);
		}
		
		override public function sendMap(mapId:int, userId:int, mapName:String, unlockLevel:int, data:ByteArray, messages:String, onCompleteFunc:Function):void
		{
			MagicStone.log("OFFLINE SERVER: sendMap mapId = " + mapId + ", userId = " + userId + ", mapName = " + mapName + ", data = " + data);
			
			var mapData:OfflineMapData;
			
			if (mapId == 0)
			{
				// find unused id
				mapId = 1;
				for each (mapData in m_mapDatas)
				{
					if (mapData.mapId >= mapId)
					{
						mapId = mapData.mapId + 1;
					}
				}
			}
			
			mapData = new OfflineMapData();
			mapData.mapId = mapId;
			mapData.userId = userId;
			mapData.mapName = mapName;
			mapData.totalSeconds = 0;
			mapData.totalCompleted = 0;
			mapData.totalPlayed = 0;
			mapData.published = false;
			mapData.levelData = data;
			mapData.levelMessages = messages;

			m_mapDatas[mapId] = mapData;
			
			var answer:Answer = new Answer();
			answer.isOk = true;
			answer.insertId = mapId;
			
			saveMaps();
			
			var timer:AnswerTimer = new AnswerTimer(onCompleteFunc, answer);
			timer.start();
		}

		override public function sendPublishMap(mapId:int, mapName:String, onCompleteFunc:Function):void
		{
			MagicStone.log("OFFLINE SERVER: sendPublishMap mapId = " + mapId);
			
			var answer:Answer = new Answer();
			var mapData:OfflineMapData = m_mapDatas[mapId];

			if (mapData != null)
			{
				mapData.published = true;
				mapData.mapName = mapName;
				answer.isOk = true;
			}
			else
			{
				answer.isOk = false;
			}
			
			saveMaps();
			
			var timer:AnswerTimer = new AnswerTimer(onCompleteFunc, answer);
			timer.start();
		}

		override public function sendMapStatistics(mapId:int, userId:int, seconds:int, completed:Boolean, score:int, onCompleteFunc:Function):void
		{
			MagicStone.log("OFFLINE SERVER: sendMapStatistics mapId = " + mapId + ", seconds = " + seconds + ", completed = " + completed);
			
			var answer:Answer = new Answer();
			
			var mapData:OfflineMapData = m_mapDatas[mapId];
			if (mapData != null)
			{
				answer.isOk = true;
				mapData.totalSeconds += seconds;
				if (completed)
				{
					mapData.totalCompleted++;
				}
				mapData.totalPlayed++;
			}
			else
			{
				answer.isOk = false;
			}
			
			saveMaps();
			
			var timer:AnswerTimer = new AnswerTimer(onCompleteFunc, answer);
			timer.start();
		}
		
		private function createMapInfo(mapData:OfflineMapData):MapInfo
		{
			var mapInfo:MapInfo = new MapInfo();
			mapInfo.mapId = mapData.mapId;
			mapInfo.userId = mapData.userId;
			mapInfo.name = mapData.mapName;
			mapInfo.numPlayed = mapData.totalPlayed;
			mapInfo.numSuccesses = mapData.totalCompleted;
			mapInfo.time = mapData.totalSeconds;
			mapInfo.published = mapData.published;
			return mapInfo;
		}
	}
}


import flash.events.TimerEvent;
import flash.utils.Timer;

import game.GameDefs;
import game.MagicStone;
import game.server.answers.Answer;

class AnswerTimer extends Timer
{
	private var m_answer:Answer;
	private var m_onCompleteFunc:Function;
	
	public function AnswerTimer(onCompleteFunc:Function, answer:Answer)
	{
		super(GameDefs.k_OFFLINE_SERVER_DELAY, 1);
		m_answer = answer;
		m_onCompleteFunc = onCompleteFunc;
		
		addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
	}
	
	private function onComplete(e:TimerEvent):void
	{
		MagicStone.log("OFFLINE SERVER answer isOk = " + m_answer.isOk);
		removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		m_onCompleteFunc(m_answer);
	}
	
}
