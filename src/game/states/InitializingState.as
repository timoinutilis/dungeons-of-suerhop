package game.states
{
	import com.adobe.serialization.json.JSON;
	import com.facebook.graph.Facebook;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.Font;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	import game.Parameters;
	import game.server.GameServer;
	import game.server.answers.AnswerFbUsers;
	import game.server.answers.AnswerMapStatus;
	import game.server.answers.AnswerUserId;
	import game.server.answers.AnswerUserInfo;
	import game.ui.LoadingScreen;
	import game.ui.PopupWindow;
	import game.value.UserInfo;
	
	import inutilib.DisplayUtils;
	import inutilib.media.SoundManager;
	import inutilib.social.SocialUser;
	import inutilib.social.SocialUserManager;
	import inutilib.statemachine.State;
	import inutilib.statemachine.StateMachine;
	import inutilib.ui.SplashScreen;
	
	import mx.resources.ResourceManager;
	
	public class InitializingState extends State
	{
		private var m_fbNames:Object;
		private var m_playerUserId:int;
		private var m_friendsLoaded:Boolean;

		public function InitializingState(stateMachine:StateMachine)
		{
			super(stateMachine);
		}
		
		override public function start():void
		{
			loadConfig();
		}
		
		override public function end():void
		{
			
		}
		
		private function startGame():void
		{
			var state:State = new MenuState(m_stateMachine);
			m_stateMachine.setState(state);
		}
		
		private function loadConfig():void
		{
			var request:URLRequest = new URLRequest(Parameters.configUrl);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onConfigComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onConfigError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onConfigError);
			loader.load(request);
		}

		private function onConfigComplete(e:Event):void
		{
			var loader:URLLoader = e.target as URLLoader;
			var xml:XML = new XML(loader.data);
			Config.setConfig(xml);
			
			MagicStone.log("Loaded Config");
			
			((MagicStone.gameStage.getChildAt(0) as DisplayObjectContainer).getChildAt(0) as LoadingScreen).progress = 0.9;
			
			SplashScreen.instance.container = MagicStone.bgContainer;
			SplashScreen.instance.load(Config.resPath + FileDefs.k_URL_SPLASH_SCREEN, "SplashAnims", onLoadedSplash);
			SplashScreen.instance.queuePlay("enter", "main");
			
			loadUISounds();

			if (Config.useFacebook)
			{
				Facebook.init(Config.appId, onFacebookInit);
			}
			else if (Config.userId.length > 0)
			{
				m_playerUserId = int(Config.userId);
				var user:SocialUser = new SocialUser("Player", Config.resPath + "profile.png");
				SocialUserManager.instance.setPlayerUser(m_playerUserId, user);
				
				for (var id:int = 1; id <= 4; id++)
				{
					if (id != m_playerUserId)
					{
						user = new SocialUser("Friend " + id, Config.resPath + "profile.png");
						SocialUserManager.instance.addFriendUser(id, user);
					}
				}
				m_friendsLoaded = true;
				
				GameServer.instance.requestUserInfo(m_playerUserId, onUserInfo);
			}
			else
			{
				// play as guest
				MagicStone.s_userInfo = new UserInfo();
				MagicStone.s_mapStatus = new Object();
				startGame();
			}
		}
		
		private function onLoadedSplash():void
		{
			// remove LoadingScreen
			(MagicStone.gameStage.getChildAt(0) as DisplayObjectContainer).removeChildAt(0);
		}

		private function onConfigError(e:ErrorEvent):void
		{
			MagicStone.log("ERROR: " + e);
			var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorConfig"));
			popup.open();
		}
				
		private function onFacebookInit(success:Object, fail:Object):void
		{
			MagicStone.log("Facebook Init " + ((success != null) ? "ok" : "failed: " + fail));
			if (success != null)
			{
				var source:String = (Parameters.requestIds.length > 0) ? "request" : Parameters.source;
				GameServer.instance.loginFromFb(Parameters.fbUserId, source, onLoginComplete);
			}
			else
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, "Error in Facebook Init.");
				popup.open();
			}
		}
		
		private function onLoginComplete(answer:AnswerUserId):void
		{
			if (answer.isOk)
			{
				m_playerUserId = answer.userId;
				Facebook.api("/me", onFbMe);
				GameServer.instance.requestUserInfo(m_playerUserId, onUserInfo);
			}
			else
			{
				MagicStone.log("Login Error: " + answer.error);
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, "Error in Login.");
				popup.open();
			}
		}
		
		private function onUserInfo(answer:AnswerUserInfo):void
		{
			if (answer.isOk)
			{
				if (answer.userInfo != null)
				{
					MagicStone.s_userInfo = answer.userInfo;
				}
				else
				{
					MagicStone.s_userInfo = new UserInfo();
				}
				GameServer.instance.requestMapStatus(m_playerUserId, onMapStatus);
			}
			else
			{
				MagicStone.log("UserInfo Error: " + answer.error);
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorUserInfo"));
				popup.open();
			}
		}
		
		private function onMapStatus(answer:AnswerMapStatus):void
		{
			if (answer.isOk)
			{
				MagicStone.s_mapStatus = answer.mapStatus;
				checkForStart();
			}
			else
			{
				MagicStone.log("MapStatus Error: " + answer.error);
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, "Error in Map Status");
				popup.open();
			}
		}
		
		private function onFbMe(result:Object, fail:Object):void
		{
			if (result != null)
			{
				MagicStone.log("FB me result: " + com.adobe.serialization.json.JSON.encode(result));
				var user:SocialUser = new SocialUser(result.name, "https://graph.facebook.com/me/picture");
				SocialUserManager.instance.setPlayerUser(m_playerUserId, user);
	
				Facebook.api("/me/friends", onFbFriends);
			}
			else
			{
				MagicStone.log("FB me failed: " + fail);
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, "Error in Facebook Me.");
				popup.open();
			}
		}
		
		private function onFbFriends(result:Object, fail:Object):void
		{
			if (result != null)
			{
				MagicStone.log("FB friends result: " + com.adobe.serialization.json.JSON.encode(result));
				var friends:Array = result as Array;
				var fbUserIds:Array = new Array();
				m_fbNames = new Object();
				for each (var friend:Object in friends)
				{
					m_fbNames[friend.id] = friend.name;
					fbUserIds.push(friend.id);
				}
				
				GameServer.instance.requestFbUsers(fbUserIds, onFbUsersComplete);
			}
			else
			{
				MagicStone.log("FB friends failed: " + fail);
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, "Error in Facebook Friends.");
				popup.open();
			}
		}
		
		private function onFbUsersComplete(answer:AnswerFbUsers):void
		{
			if (answer.isOk)
			{
				for (var i:int = 0; i < answer.fbUserIds.length; i++)
				{
					var fbUserId:String = answer.fbUserIds[i] as String;
					var userId:int = answer.userIds[i] as int;
					
					MagicStone.log("fbUser added " + fbUserId + ", id " + userId);
					
					var user:SocialUser = new SocialUser(m_fbNames[fbUserId], "https://graph.facebook.com/" + fbUserId + "/picture");
					SocialUserManager.instance.addFriendUser(userId, user);
				}
				m_friendsLoaded = true;
				checkForStart();
			}
			else
			{
				MagicStone.log("FbUsers Error: " + answer.error);
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorUsers"));
				popup.open();
			}
		}
		
		private function loadUISounds():void
		{
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_PAPER, FileDefs.k_URL_SFX_PAPER);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_PAPER_CLOSE, FileDefs.k_URL_SFX_PAPER_CLOSE);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_WINDOW, FileDefs.k_URL_SFX_WINDOW);
		}
		
		private function checkForStart():void
		{
			if (m_friendsLoaded && MagicStone.s_mapStatus != null)
			{
				startGame();
			}
		}
	}
}