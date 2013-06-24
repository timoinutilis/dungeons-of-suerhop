package game.states
{
	import com.adobe.serialization.json.JSON;
	import com.facebook.graph.Facebook;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.ui.Keyboard;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	import game.InfoSystem;
	import game.MagicStone;
	import game.server.GameServer;
	import game.server.answers.Answer;
	import game.ui.AfterPlayWindow;
	import game.ui.LevelUpWindow;
	import game.ui.PopupWindow;
	import game.ui.TextInputWindow;
	import game.value.MapInfo;
	import game.value.MapStatus;
	
	import inutilib.DisplayUtils;
	import inutilib.social.SocialUserManager;
	import inutilib.statemachine.State;
	import inutilib.statemachine.StateMachine;
	
	import mx.resources.ResourceManager;
	
	public class WinState extends State
	{
		[Embed(source = "../../../embed/end_game_anims.swf", symbol="WinAnim")]
		private var WinAnim:Class;

		private var m_parentStateMachine:StateMachine;
		private var m_mapInfo:MapInfo;
		private var m_seconds:int;
		private var m_score:int;
		private var m_cameFrom:int;
		
		private var m_winAnim:MovieClip;
		private var m_winAnimFinished:Boolean;
		private var m_winAnimSkipped:Boolean;
		private var m_window:AfterPlayWindow;
		private var m_waitPopup:PopupWindow;
		private var m_nameInputWindow:TextInputWindow;
		
		private var m_justPublished:Boolean;
		private var m_oldHighscore:int;
		private var m_leveledUp:Boolean;
		
		public function WinState(stateMachine:StateMachine, parentStateMachine:StateMachine, mapInfo:MapInfo, seconds:int, score:int, cameFrom:int)
		{
			super(stateMachine);
			m_parentStateMachine = parentStateMachine;
			m_mapInfo = mapInfo;
			m_seconds = seconds;
			m_score = score;
			m_cameFrom = cameFrom;
		}
		
		override public function start():void
		{
			if (m_mapInfo.published)
			{
				MagicStone.s_userInfo.addStatistics(m_seconds, true);
				
				var mapStatus:MapStatus = MagicStone.s_mapStatus[m_mapInfo.mapId] as MapStatus;
				m_oldHighscore = mapStatus.score;

				mapStatus.status = MapStatus.k_STATUS_COMPLETED;
				mapStatus.score = Math.max(m_score, mapStatus.score);
				
				if (!SocialUserManager.instance.isGuest())
				{
					GameServer.instance.sendMapStatistics(m_mapInfo.mapId, SocialUserManager.instance.playerUserId, m_seconds, true, m_score, onStatistics);
					if (MenuMainState.savegame != null && MenuMainState.savegame.mapId == m_mapInfo.mapId)
					{
						GameServer.instance.sendDeleteSavegame(SocialUserManager.instance.playerUserId, onDeletedSavegame);
						MenuMainState.clearSavegameInfo();
					}
					
					ogCompletedDungeon();
				}

				if (m_mapInfo.global && m_score > m_oldHighscore)
				{
					// new highscore -> update player's total score
					var oldLevel:int = MagicStone.s_userInfo.getLevel();
					MagicStone.s_userInfo.totalScore += (m_score - m_oldHighscore);
					
					if (!SocialUserManager.instance.isGuest())
					{
						GameServer.instance.sendTotalScore(SocialUserManager.instance.playerUserId, MagicStone.s_userInfo.totalScore, onTotalScore);
					}
					
					if (MagicStone.s_userInfo.getLevel() != oldLevel)
					{
						m_leveledUp = true;
					}
				}
			}


			m_winAnim = new WinAnim as MovieClip;
			m_winAnim.x = MagicStone.gameStage.stageWidth / 2;
			m_winAnim.y = MagicStone.gameStage.stageHeight / 2;
			DisplayUtils.setText(m_winAnim.getChildByName("textSprite") as Sprite, "text", ResourceManager.getInstance().getString("default", "textWin"), GameDefs.k_TEXT_FORMAT_BOLD, true);
			MagicStone.bgContainer.addChild(m_winAnim);
			
			MagicStone.gameStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		override public function end():void
		{
			MagicStone.bgContainer.removeChild(m_winAnim);
			MagicStone.gameStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER && !m_winAnimFinished && !m_winAnimSkipped)
			{
				m_winAnimSkipped = true;
				onAnimFinished();
			}
		}

		override public function update():void
		{
			if (!m_winAnimFinished && m_winAnim.currentFrame == m_winAnim.totalFrames)
			{
				m_winAnim.stop();
				m_winAnimFinished = true;
				if (!m_winAnimSkipped)
				{
					onAnimFinished();
				}
			}
		}
		
		private function onDeletedSavegame(e:Answer):void
		{
			// ignore
		}

		private function onStatistics(e:Answer):void
		{
			// ignore
		}
		
		private function onTotalScore(e:Answer):void
		{
			// ignore
		}
		
		private function onAnimFinished():void
		{
			if (m_mapInfo.published)
			{
				createAfterPlayWindow(false);
			}
			else
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_YES_NO, ResourceManager.getInstance().getString("default", "textPublishNowOrChange"), false);
				popup.ui.addEventListener(MouseEvent.CLICK, onPublishClick, false, 0, true);
				popup.open();
			}
		}
		
		private function onPublishClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			if (buttonName == PopupWindow.k_BUTTON_YES)
			{
				renameMap();
			}
			else if (buttonName == PopupWindow.k_BUTTON_NO)
			{
				returnFromGame();
			}
		}
		
		private function renameMap():void
		{
			m_nameInputWindow = new TextInputWindow(ResourceManager.getInstance().getString("default", "textEnterMapName"), m_mapInfo.name, false);
			m_nameInputWindow.ui.addEventListener(MouseEvent.CLICK, onNameInputClick, false, 0, true);
			m_nameInputWindow.open();
		}
		
		private function onNameInputClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			if (buttonName == TextInputWindow.k_BUTTON_ACCEPT)
			{
				m_mapInfo.name = m_nameInputWindow.inputText;
				m_cameFrom = InGameState.k_CAME_FROM_MENU; // don't go back to editor after publishing!
				publishMap();
			}
			else if (buttonName == TextInputWindow.k_BUTTON_CANCEL)
			{
				returnFromGame();
			}
		}
		
		private function publishMap():void
		{
			m_waitPopup = new PopupWindow(PopupWindow.k_TYPE_WAIT, ResourceManager.getInstance().getString("default", "textPublished"));
			m_waitPopup.open();
			GameServer.instance.sendPublishMap(m_mapInfo.mapId, m_mapInfo.name, onPublishComplete);
			MagicStone.s_userInfo.addStatistics(m_seconds, true);
			GameServer.instance.sendMapStatistics(m_mapInfo.mapId, SocialUserManager.instance.playerUserId, m_seconds, true, m_score, onStatistics);
			ogCreatedDungeon();
		}
		
		private function onPublishComplete(answer:Answer):void
		{
			m_waitPopup.close();
			m_waitPopup = null;
			
			if (answer.isOk)
			{
				MenuOwnMapsState.reinitMaps();
				createAfterPlayWindow(true);
			}
			else
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorPublishing"));
				popup.open();
			}
		}
		
		private function createAfterPlayWindow(justPublished:Boolean):void
		{
			var title:String;
			var inviteText:String;
			var shareText:String;
			var text:String;

			m_justPublished = justPublished;

			// only allow liking dungeons of other people
			var allowLiking:Boolean = (m_mapInfo.userId != SocialUserManager.instance.playerUserId) && !SocialUserManager.instance.isGuest();
			
			if (justPublished)
			{
				title = ResourceManager.getInstance().getString("default", "textJustPublishedTitle");
				inviteText = ResourceManager.getInstance().getString("default", "textJustPublishedInvite");
				shareText = ResourceManager.getInstance().getString("default", "textJustPublishedShare");
				text = "";
			}
			else
			{
				title = ResourceManager.getInstance().getString("default", "textCompletedTitle").replace("%1", m_mapInfo.name);
				inviteText = ResourceManager.getInstance().getString("default", "textCompletedInvite");
				shareText = ResourceManager.getInstance().getString("default", "textCompletedShare");
				
				if (allowLiking)
				{
					text = ResourceManager.getInstance().getString("default", "textDidYouLike");
				}
				else
				{
					text = "";
				}
			}
			
			m_window = new AfterPlayWindow(allowLiking ? AfterPlayWindow.k_TYPE_YES_NO : AfterPlayWindow.k_TYPE_OK, title, inviteText, shareText, text, m_score, m_oldHighscore);
			m_window.open();
			
			m_window.ui.addEventListener(MouseEvent.CLICK, onWindowClick, false, 0, true);
		}
		
		private function onWindowClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			
			switch (buttonName)
			{
				case AfterPlayWindow.k_BUTTON_OK:
					checkLevelUp();
					break;
				
				case AfterPlayWindow.k_BUTTON_YES:
					GameServer.instance.sendLike(SocialUserManager.instance.playerUserId, m_mapInfo.mapId, onLiked);
					checkLevelUp();
					break;
				
				case AfterPlayWindow.k_BUTTON_NO:
					checkLevelUp();
					break;
				
				case AfterPlayWindow.k_BUTTON_INVITE:
					invite();
					break;
				
				case AfterPlayWindow.k_BUTTON_SHARE:
					share();
					break;
			}
		}
		
		private function onLiked(answer:Answer):void
		{
			// ignore
		}
		
		private function checkLevelUp():void
		{
			if (m_leveledUp)
			{
				if (m_window != null)
				{
					m_window.close();
					m_window = null;
				}

				var popup:LevelUpWindow = new LevelUpWindow(
					ResourceManager.getInstance().getString("default", "textLeveledUp1").replace("%1", MagicStone.s_userInfo.getLevel()),
					ResourceManager.getInstance().getString("default", "textLeveledUp2"));
				
				popup.ui.addEventListener(MouseEvent.CLICK, onLevelUpClick, false, 0, true);
				popup.open();
			}
			else
			{
				checkInfoPopup();
			}
		}
		
		private function onLevelUpClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			if (buttonName == PopupWindow.k_BUTTON_OK)
			{
				checkInfoPopup();
			}
		}
		
		private function checkInfoPopup():void
		{
			if (MagicStone.s_userInfo.numPlayed % 2 == 0)
			{
				var infoSystem:InfoSystem = new InfoSystem();
				
				var info:int = infoSystem.getNextInfo();
				if (info != InfoSystem.k_NO_INFO)
				{
					if (m_window != null)
					{
						m_window.close();
						m_window = null;
					}

					infoSystem.showInfo(info, returnFromGame);
				}
				else
				{
					returnFromGame();
				}
			}
			else
			{
				returnFromGame();
			}
		}
		
		private function invite():void
		{
			if (Config.useFacebook)
			{
				MagicStone.log("Fb Invite");
				
				var message:String;
				var name:String = SocialUserManager.instance.getPlayerUser().name;
				if (m_justPublished)
				{
					message = ResourceManager.getInstance().getString("default", "textCreatedAndInvitedMsg").replace("%1", name).replace("%2", m_mapInfo.name);
				}
				else
				{
					message = ResourceManager.getInstance().getString("default", "textPlayedAndInvitedMsg").replace("%1", name).replace("%2", m_mapInfo.name);
				}
				var params:Object = new Object();
				params.title = ResourceManager.getInstance().getString("default", "textInviteTitle");
				params.message = message;
				params.data = m_mapInfo.mapId;
				Facebook.ui("apprequests", params);
			}
			else
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textOnlySocial"));
				popup.open();
			}
		}
		
		private function share():void
		{
			if (Config.useFacebook)
			{
				MagicStone.log("Fb Share");

				var message:String;
				var name:String = SocialUserManager.instance.getPlayerUser().name;
				var source:String;
				if (m_justPublished)
				{
					message = ResourceManager.getInstance().getString("default", "textShareCreated").replace("%1", name).replace("%2", m_mapInfo.name);
					source = "share_crea";
				}
				else
				{
					message = ResourceManager.getInstance().getString("default", "textSharePlayed").replace("%1", name).replace("%2", m_mapInfo.name);
					source = "share_play";
				}
				var params:Object = new Object();
				params.link = Config.appUrl + "?map_id=" + m_mapInfo.mapId + "&source=" + source;
				params.picture = Config.resPath + FileDefs.k_URL_LOGO_WALL;
				params.name = message;
				params.caption = ResourceManager.getInstance().getString("default", "textShareDescription");
				Facebook.ui("feed", params);
			}
			else
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textOnlySocial"));
				popup.open();
			}
		}
		
		private function ogCompletedDungeon():void
		{
			if (Config.useFacebook)
			{
				MagicStone.log("Fb OpenGraph Completed Dungeon");
				
				var dungeonUrl:String = Config.appUrl + "og/dungeon.php?id=" + m_mapInfo.mapId;
				Facebook.api("/me/dungeonsofsuerhop:complete", onFBOG, {dungeon:dungeonUrl}, "POST");
			}
		}
		
		private function ogCreatedDungeon():void
		{
			if (Config.useFacebook)
			{
				MagicStone.log("Fb OpenGraph Created Dungeon");
				
				var dungeonUrl:String = Config.appUrl + "og/dungeon.php?id=" + m_mapInfo.mapId;
				Facebook.api("/me/dungeonsofsuerhop:create", onFBOG, {dungeon:dungeonUrl}, "POST");
			}
		}
		
		private function onFBOG(result:Object, fail:Object):void
		{
			if (result != null)
			{
				MagicStone.log("FB OpenGraph result: " + com.adobe.serialization.json.JSON.encode(result));
			}
			else
			{
				MagicStone.log("FB OpenGraph failed: " + fail);
			}
		}
		
		private function returnFromGame():void
		{
			if (m_window != null)
			{
				m_window.close();
			}
			
			InGameState.returnFromGame(m_parentStateMachine, m_cameFrom, m_mapInfo);
		}
		
	}
}