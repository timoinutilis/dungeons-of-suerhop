package game.states
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import game.GameDefs;
	import game.MagicStone;
	import game.server.GameServer;
	import game.server.answers.Answer;
	import game.ui.PopupWindow;
	import game.value.MapInfo;
	
	import de.inutilis.inutilib.DisplayUtils;
	import de.inutilis.inutilib.GameTime;
	import de.inutilis.inutilib.social.SocialUserManager;
	import de.inutilis.inutilib.statemachine.State;
	import de.inutilis.inutilib.statemachine.StateMachine;
	
	import mx.resources.ResourceManager;
	
	public class GameOverState extends State
	{
		[Embed(source = "../../../embed/end_game_anims.swf", symbol="GameOverAnim")]
		private var GameOverAnim:Class;

		private var m_parentStateMachine:StateMachine;
		private var m_mapInfo:MapInfo;
		private var m_seconds:int;
		private var m_cameFrom:int;
		private var m_gameOverDelay:int;
		
		private var m_gameOverAnim:MovieClip;
		private var m_gameOverAnimFinished:Boolean;
		private var m_gameOverAnimSkipped:Boolean;

		
		public function GameOverState(stateMachine:StateMachine, parentStateMachine:StateMachine, mapInfo:MapInfo, seconds:int, cameFrom:int, gameOverDelay:int)
		{
			super(stateMachine);
			m_parentStateMachine = parentStateMachine;
			m_mapInfo = mapInfo;
			m_seconds = seconds;
			m_cameFrom = cameFrom;
			m_gameOverDelay = gameOverDelay;
		}
		
		override public function start():void
		{
			if (m_gameOverDelay == 0)
			{
				startReally();
			}
		}
		
		private function startReally():void
		{
			if (m_mapInfo.published)
			{
				MagicStone.s_userInfo.addStatistics(m_seconds, false);
				if (!SocialUserManager.instance.isGuest())
				{
					GameServer.instance.sendMapStatistics(m_mapInfo.mapId, SocialUserManager.instance.playerUserId, m_seconds, false, 0, onStatistics);
				}
			}
			
			m_gameOverAnim = new GameOverAnim as MovieClip;
			m_gameOverAnim.x = MagicStone.gameStage.stageWidth / 2;
			m_gameOverAnim.y = MagicStone.gameStage.stageHeight / 2;
			DisplayUtils.setText(m_gameOverAnim.getChildByName("textSprite") as Sprite, "text", ResourceManager.getInstance().getString("default", "textGameOver"), GameDefs.k_TEXT_FORMAT_BOLD, true);
			MagicStone.bgContainer.addChild(m_gameOverAnim);
			
			MagicStone.gameStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		override public function end():void
		{
			MagicStone.bgContainer.removeChild(m_gameOverAnim);
			MagicStone.gameStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER && !m_gameOverAnimFinished && !m_gameOverAnimSkipped)
			{
				m_gameOverAnimSkipped = true;
				onAnimFinished();
			}
		}

		override public function update():void
		{
			if (m_gameOverDelay > 0)
			{
				m_gameOverDelay -= GameTime.frameMillis;
				if (m_gameOverDelay <= 0)
				{
					m_gameOverDelay = 0;
					startReally();
				}
			}
			else if (!m_gameOverAnimFinished && m_gameOverAnim.currentFrame == m_gameOverAnim.totalFrames)
			{
				m_gameOverAnim.stop();
				m_gameOverAnimFinished = true;
				if (!m_gameOverAnimSkipped)
				{
					onAnimFinished();
				}
			}
		}
		
		private function onStatistics(e:Answer):void
		{
			// ignore
		}

		private function onAnimFinished():void
		{
			var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_YES_NO, ResourceManager.getInstance().getString("default", "textTryAgain"));
			popup.ui.addEventListener(MouseEvent.CLICK, onTryAgainClick, false, 0, true);
			popup.open();
		}
		
		private function onTryAgainClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			var state:State;
			if (buttonName == PopupWindow.k_BUTTON_YES)
			{
				// reload map
				state = new MapLoaderState(m_parentStateMachine, MapLoaderState.k_GO_TO_INGAME, m_cameFrom, m_mapInfo);
				m_parentStateMachine.setState(state);
			}
			else if (buttonName == PopupWindow.k_BUTTON_NO)
			{
				// exit
				InGameState.returnFromGame(m_parentStateMachine, m_cameFrom, m_mapInfo);
			}
		}

	}
}