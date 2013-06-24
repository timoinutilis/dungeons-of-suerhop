package game.states
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	import game.server.GameServer;
	import game.server.answers.Answer;
	import game.server.answers.AnswerMap;
	import game.ui.LoadingScreen;
	import game.ui.PopupWindow;
	import game.value.MapInfo;
	import game.value.MapStatus;
	import game.value.Savegame;
	
	import de.inutilis.inutilib.map.IDImagesLoader;
	import de.inutilis.inutilib.social.SocialUserManager;
	import de.inutilis.inutilib.statemachine.State;
	import de.inutilis.inutilib.statemachine.StateMachine;
	
	import mx.resources.ResourceManager;
	
	public class MapLoaderState extends State
	{
		public static const k_GO_TO_MAP_EDITOR:int = 0;
		public static const k_GO_TO_INGAME:int = 1;
		
		private var m_loadingScreen:LoadingScreen;
		
		private var m_numLoadingSteps:int;
		private var m_loadingStep:int;
		
		private var m_goTo:int;
		private var m_cameFrom:int;
		private var m_mapInfo:MapInfo;
		private var m_tilesLoader:IDImagesLoader;
		private var m_discoverTilesLoader:IDImagesLoader;
		private var m_spritesLoader:IDImagesLoader;
		private var m_levelData:ByteArray;
		private var m_levelMessages:String;
		private var m_savegame:Savegame;

		public function MapLoaderState(stateMachine:StateMachine, goTo:int, cameFrom:int, mapInfo:MapInfo, savegame:Savegame = null)
		{
			super(stateMachine);
			m_goTo = goTo;
			m_cameFrom = cameFrom;
			m_mapInfo = mapInfo;
			m_savegame = savegame;
			
			m_numLoadingSteps = (mapInfo != null) ? 3 : 2;
			if (m_goTo == k_GO_TO_INGAME)
			{
				m_numLoadingSteps++;
			}
		}
		
		override public function start():void
		{
			m_loadingScreen = new LoadingScreen(MagicStone.bgContainer.stage.stageWidth, MagicStone.bgContainer.stage.stageHeight, false);
			MagicStone.bgContainer.addChildAt(m_loadingScreen, 0);

			m_tilesLoader = new IDImagesLoader(IDImagesLoader.k_TYPE_BITMAP_DATA);
			m_tilesLoader.addEventListener(Event.COMPLETE, onLoadingComplete, false, 0, true);
			m_tilesLoader.requestFromXML(Config.resPath + FileDefs.k_URL_TILES_XML, Config.resPath + FileDefs.k_PATH_TILES);

			if (m_goTo == k_GO_TO_INGAME)
			{
				m_discoverTilesLoader = new IDImagesLoader(IDImagesLoader.k_TYPE_BITMAP_DATA);
				m_discoverTilesLoader.addEventListener(Event.COMPLETE, onLoadingComplete, false, 0, true);
				m_discoverTilesLoader.requestFromXML(Config.resPath + FileDefs.k_URL_DISCOVER_TILES_XML, Config.resPath + FileDefs.k_PATH_TILES);
				
				InGameState.requestGameSounds();
			}
			else if (m_goTo == k_GO_TO_MAP_EDITOR)
			{
				MapEditorState.requestEditorSounds();
			}

			m_spritesLoader = new IDImagesLoader(IDImagesLoader.k_TYPE_SWF_CLASS);
			m_spritesLoader.addEventListener(Event.COMPLETE, onLoadingComplete, false, 0, true);
			m_spritesLoader.requestFromXML(Config.resPath + FileDefs.k_URL_OBJECTS_XML, Config.resPath + FileDefs.k_PATH_OBJECTS);
			
			if (m_mapInfo != null)
			{
				GameServer.instance.requestMap(m_mapInfo.mapId, onMapComplete);
				if (m_goTo == k_GO_TO_INGAME)
				{
					if (!SocialUserManager.instance.isGuest())
					{
						GameServer.instance.sendMapStarted(m_mapInfo.mapId, SocialUserManager.instance.playerUserId, onMapStartedComplete);
					}
					if (!MagicStone.s_mapStatus.hasOwnProperty(m_mapInfo.mapId))
					{
						var mapStatus:MapStatus = new MapStatus();
						mapStatus.status = MapStatus.k_STATUS_PLAYED;
						mapStatus.score = 0;
						MagicStone.s_mapStatus[m_mapInfo.mapId] = mapStatus;
					}
				}
			}
		}
		
		override public function end():void
		{
			MagicStone.bgContainer.removeChild(m_loadingScreen);
			m_loadingScreen = null;
		}
		
		override public function update():void
		{
			
		}
		
		private function onMapStartedComplete(answer:Answer):void
		{
			// ignore
		}
		
		private function onMapComplete(answer:AnswerMap):void
		{
			if (answer.isOk)
			{
				m_levelData = answer.levelData;
				m_levelMessages = answer.levelMessages;
				onLoadingComplete(null);
			}
			else
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorMap"));
				popup.open();
			}
		}

		private function onLoadingComplete(e:Event):void
		{
			m_loadingStep++;
			
			if (m_loadingStep >= m_numLoadingSteps)
			{
				var state:State = null;
				switch (m_goTo)
				{
					case k_GO_TO_INGAME:
						state = new InGameState(m_stateMachine, m_tilesLoader, m_discoverTilesLoader, m_spritesLoader, m_levelData, m_levelMessages, m_mapInfo, m_savegame, m_cameFrom);
						break;
					
					case k_GO_TO_MAP_EDITOR:
						state = new MapEditorState(m_stateMachine, m_tilesLoader, m_spritesLoader, m_levelData, m_levelMessages, m_mapInfo);
				}
				m_stateMachine.setState(state);
			}
		}

	}
}