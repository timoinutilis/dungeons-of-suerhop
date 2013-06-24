package game.states
{
	import com.facebook.graph.Facebook;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.system.ApplicationDomain;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	import game.server.GameServer;
	import game.server.answers.AnswerMapInfo;
	import game.server.answers.AnswerMapInfos;
	import game.server.answers.AnswerSavegame;
	import game.ui.PopupWindow;
	import game.value.MapInfo;
	import game.value.Savegame;
	
	import de.inutilis.inutilib.DisplayUtils;
	import de.inutilis.inutilib.media.SoundManager;
	import de.inutilis.inutilib.social.SocialUserManager;
	import de.inutilis.inutilib.statemachine.State;
	import de.inutilis.inutilib.statemachine.StateMachine;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.SplashScreen;
	import de.inutilis.inutilib.ui.Window;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	public class MenuMainState extends State
	{
		[Embed(source = "../../../embed/ui_menus.swf", symbol="UIMenuMain")]
		private var UIMenuMain:Class;

		private static var s_savegame:Savegame = null;
		private static var s_savegameMapInfo:MapInfo = null;
		private static var s_savegameChecked:Boolean = false;

		private var m_parentStateMachine:StateMachine;
		private var m_window:Window;

		public function MenuMainState(stateMachine:StateMachine, parentStateMachine:StateMachine)
		{
			super(stateMachine);
			m_parentStateMachine = parentStateMachine;
		}
		
		override public function start():void
		{
			SplashScreen.instance.queuePlay("moveToMain", "moveToMainEnd", "main");
			if (s_savegameChecked || SocialUserManager.instance.isGuest())
			{
				createWindow();
			}
			else
			{
				GameServer.instance.requestSavegame(SocialUserManager.instance.playerUserId, onSavegame);
			}
		}
		
		override public function end():void
		{
			if (m_window != null)
			{
				m_window.close();
			}
		}
				
		private function onSavegame(answer:AnswerSavegame):void
		{
			if (answer.isOk)
			{
				s_savegameChecked = true;
				s_savegame = answer.savegame;
			}
			createWindow();
		}
		
		private function createWindow():void
		{
			m_window = new Window(MagicStone.uiContainer, new UIMenuMain as Sprite, 300, PositionRectangle.k_CENTER);
			
			var resourceManager:IResourceManager = ResourceManager.getInstance();
			DisplayUtils.setButtonText(m_window.ui, "buttonCredits", resourceManager.getString("default", "buttonCredits"), GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setButtonText(m_window.ui, "buttonContinue", resourceManager.getString("default", "buttonContinue"), GameDefs.k_TEXT_FORMAT_BOLD);
			DisplayUtils.setButtonText(m_window.ui, "buttonPlay", resourceManager.getString("default", "buttonPlay"), GameDefs.k_TEXT_FORMAT_BOLD);
			DisplayUtils.setButtonText(m_window.ui, "buttonFriends", resourceManager.getString("default", "buttonFriends"), GameDefs.k_TEXT_FORMAT_BOLD);
			DisplayUtils.setButtonText(m_window.ui, "buttonOwn", resourceManager.getString("default", "buttonOwn"), GameDefs.k_TEXT_FORMAT_BOLD);
			DisplayUtils.setButtonText(m_window.ui, "buttonInvite", resourceManager.getString("default", "buttonInviteFriends"), GameDefs.k_TEXT_FORMAT_BOLD);
			
			if (s_savegame == null)
			{
				// hide "continue saved game"
				m_window.ui.getChildByName("buttonContinue").visible = false;
			}
			m_window.ui.addEventListener(MouseEvent.CLICK, onWindowClick, false, 0, true);
			m_window.open();
			
			SoundManager.instance.play(FileDefs.k_URL_SFX_WINDOW);
		}
		
		private function onWindowClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			
			trace("buttonName: " + buttonName);
			
			var state:State;
			var window:PopupWindow;
			switch (buttonName)
			{
				case "buttonCredits":
					state = new MenuCreditsState(m_stateMachine);
					m_stateMachine.setState(state);
					m_stateMachine.addState(this);
					break;
				
				case "buttonContinue":
					if (s_savegameMapInfo == null)
					{
						GameServer.instance.requestMapInfo(s_savegame.mapId, onSavegameMapInfoComplete);
						m_window.close();
						m_window = null;
					}
					else
					{
						continueGame();
					}
					break;
				
				case "buttonPlay":
					state = new MenuTopMapsState(m_stateMachine, m_parentStateMachine);
					m_stateMachine.setState(state);
					break;
				
				case "buttonFriends":
					if (SocialUserManager.instance.isGuest())
					{
						window = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textOnlySocial"));
						window.open();
					}
					else
					{
						state = new MenuFriendMapsState(m_stateMachine, m_parentStateMachine);
						m_stateMachine.setState(state);
					}
					break;
				
				case "buttonOwn":
					if (SocialUserManager.instance.isGuest())
					{
						window = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textOnlySocial"));
						window.open();
					}
					else
					{
						state = new MenuOwnMapsState(m_stateMachine, m_parentStateMachine);
						m_stateMachine.setState(state);
					}
					break;
				
				case "buttonInvite":
					invite();
					break;
			}
		}
		
		private function continueGame():void
		{
			SplashScreen.instance.queuePlay("mainToMap", "mainToMapEnd");
			var state:State = new MapLoaderState(m_stateMachine, MapLoaderState.k_GO_TO_INGAME, InGameState.k_CAME_FROM_MENU, s_savegameMapInfo, s_savegame);
			m_stateMachine.setState(state);
		}
		
		private function onSavegameMapInfoComplete(answer:AnswerMapInfo):void
		{
			if (answer.isOk)
			{
				s_savegameMapInfo = answer.mapInfo;
				continueGame();
			}
			else
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorInfo"));
				popup.open();
			}
		}
		
		private function invite():void
		{
			if (Config.useFacebook)
			{
				MagicStone.log("Fb Invite");
				
				var name:String = SocialUserManager.instance.getPlayerUser().name;
				var message:String = ResourceManager.getInstance().getString("default", "textInviteMsg").replace("%1", name);
				var params:Object = new Object();
				params.title = ResourceManager.getInstance().getString("default", "textInviteTitle");
				params.message = message;
				Facebook.ui("apprequests", params);
			}
			else
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textOnlySocial"));
				popup.open();
			}
		}

		public static function resetSavegameInfo():void
		{
			s_savegameChecked = false;
			s_savegame = null;
			s_savegameMapInfo = null;
		}
		
		public static function clearSavegameInfo():void
		{
			s_savegameChecked = true;
			s_savegame = null;
			s_savegameMapInfo = null;
		}
		
		public static function get savegame():Savegame
		{
			return s_savegame;
		}

	}
}