package game.states
{
	import com.adobe.serialization.json.JSON;
	import com.facebook.graph.Facebook;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.net.URLRequestMethod;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	import game.Parameters;
	import game.server.GameServer;
	import game.server.answers.AnswerMapInfo;
	import game.ui.PopupWindow;
	import game.value.MapInfo;
	
	import de.inutilis.inutilib.media.ImageManager;
	import de.inutilis.inutilib.media.MusicPlayer;
	import de.inutilis.inutilib.social.SocialUserManager;
	import de.inutilis.inutilib.statemachine.State;
	import de.inutilis.inutilib.statemachine.StateMachine;
	import de.inutilis.inutilib.ui.SplashScreen;
	
	import mx.resources.ResourceManager;

	public class MenuState extends State
	{
		private var m_subStateMachine:StateMachine;
		private var m_directStart:Boolean;
		private var m_mapInfo:MapInfo;
		private var m_fbRequestId:String;
		private var m_splashEntered:Boolean;
		
		public function MenuState(stateMachine:StateMachine)
		{
			super(stateMachine);
			m_subStateMachine = new StateMachine();
		}
		
		override public function start():void
		{
			SplashScreen.instance.container = MagicStone.bgContainer;
			SplashScreen.instance.queuePlay("return", "returnEnd", "main");
			SplashScreen.instance.queueCallback(onEntered);
			
			MusicPlayer.instance.play(Config.resPath + FileDefs.k_URL_MUSIC_TITLE, GameDefs.k_MUSIC_FADE_TIME);

			
			if (Parameters.mapId != 0)
			{
				m_directStart = true;
				GameServer.instance.requestMapInfo(Parameters.mapId, onMapInfo);
			}
			else if (Config.useFacebook && Parameters.requestIds.length > 0)
			{
				var requestIds:Array = Parameters.requestIds.split(",");
				m_fbRequestId = requestIds[0];
				Facebook.api("/" + m_fbRequestId, onFbRequest);
				m_directStart = true;
			}
		}
		
		override public function end():void
		{
			SplashScreen.instance.removeCallback(onEntered);
			
			m_subStateMachine.quit();
		}
		
		override public function update():void
		{
			super.update();
			m_subStateMachine.update();
		}
		
		private function onFbRequest(result:Object, fail:Object):void
		{
			if (result != null)
			{
				MagicStone.log("onFbRequest ok");
				var mapId:int = int(result as String);
				GameServer.instance.requestMapInfo(mapId, onMapInfo);
			}
			else
			{
				MagicStone.log("onFbRequest failed: " + fail);
				m_directStart = false;
				if (m_splashEntered)
				{
					goToMainMenu();
				}
			}
		}
		
		private function onMapInfo(answer:AnswerMapInfo):void
		{
			if (answer.isOk)
			{
				m_mapInfo = answer.mapInfo;
				checkShowPlayPopup();
			}
			else
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorInfo"));
				popup.open();
			}
		}
		
		private function onEntered():void
		{
			m_splashEntered = true;
			
			if (m_directStart)
			{
				checkShowPlayPopup();
			}
			else
			{
				goToMainMenu();
			}
		}
		
		private function checkShowPlayPopup():void
		{
			var popup:PopupWindow;

			// check for popup when everything is loaded
			if (m_mapInfo != null && m_splashEntered)
			{
				// only allow published maps to be played from here
				if (m_mapInfo.published)
				{
					if (m_mapInfo.unlockLevel > MagicStone.s_userInfo.getLevel())
					{
						// map is locked
						popup = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textPlayNowLocked").replace("%1", m_mapInfo.name).replace("%2", m_mapInfo.unlockLevel));
						popup.ui.addEventListener(MouseEvent.CLICK, onCannotPlayNowClick, false, 0, true);
						popup.open();
					}
					else
					{
						// ask for play
						popup = new PopupWindow(PopupWindow.k_TYPE_YES_NO, ResourceManager.getInstance().getString("default", "textPlayMapNow").replace("%1", m_mapInfo.name));
						popup.ui.addEventListener(MouseEvent.CLICK, onPlayNowClick, false, 0, true);
						popup.open();
					}
				}
				else
				{
					goToMainMenu();
				}
			}
		}
		
		private function goToMainMenu():void
		{
			var state:State = new MenuMainState(m_subStateMachine, m_stateMachine);
			m_subStateMachine.setState(state);
		}
		
		private function onCannotPlayNowClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			if (buttonName == PopupWindow.k_BUTTON_OK)
			{
				goToMainMenu();
			}
		}
		
		private function onPlayNowClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			if (buttonName == PopupWindow.k_BUTTON_YES)
			{
				SplashScreen.instance.queuePlay("mainToMap", "mainToMapEnd");

				// don't allow liking own maps
				var allowLiking:Boolean = (m_mapInfo.userId != SocialUserManager.instance.playerUserId);
				// play!
				var state:State = new MapLoaderState(m_stateMachine, MapLoaderState.k_GO_TO_INGAME, InGameState.k_CAME_FROM_MENU, m_mapInfo);
				m_stateMachine.setState(state);
				Parameters.resetMapId();
				Parameters.resetRequestIds();
				
				if (Config.useFacebook)
				{
					if (m_fbRequestId != null)
					{
						Facebook.deleteObject("/" + m_fbRequestId, onFbRequestDelete);
						m_fbRequestId = null;
					}
				}
			}
			else if (buttonName == PopupWindow.k_BUTTON_NO)
			{
				Parameters.resetMapId();
				goToMainMenu();
			}
		}
		
		private function onFbRequestDelete(result:Object, fail:Object):void
		{
			if (result != null)
			{
				MagicStone.log("fbRequest deleted ok: " + result);
			}
			else
			{
				MagicStone.log("fbRequest deleted failed: " + fail);
			}
		}
	}
}