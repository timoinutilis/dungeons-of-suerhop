package game
{
	import com.adobe.utils.ArrayUtil;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.ApplicationDomain;
	import flash.system.Security;
	import flash.text.Font;
	import flash.utils.ByteArray;
	
	import game.states.InitializingState;
	import game.states.MenuState;
	import game.ui.UserOptionsWindow;
	import game.value.UserInfo;
	
	import de.inutilis.inutilib.ArrayUtils;
	import de.inutilis.inutilib.GameKeys;
	import de.inutilis.inutilib.GameTime;
	import de.inutilis.inutilib.UserOptions;
	import de.inutilis.inutilib.debug.StageConsole;
	import de.inutilis.inutilib.fx.FxManager;
	import de.inutilis.inutilib.media.MusicPlayer;
	import de.inutilis.inutilib.statemachine.State;
	import de.inutilis.inutilib.statemachine.StateMachine;
	import de.inutilis.inutilib.ui.SplashScreen;
	import de.inutilis.inutilib.ui.WindowManager;
	
	import mx.resources.ResourceManager;
	
	[SWF(width = "760", height = "570", frameRate = "30")]
	
	[Frame(factoryClass = "game.Preloader")]
	
	[ResourceBundle("default")]
	
	public class MagicStone extends Sprite
	{
		[Embed(source="../../embed/playtime.ttf", fontFamily="_playtime", fontStyle="normal", fontWeight="normal", embedAsCFF = false)]
		public static var Font1:Class;

		public static var s_userInfo:UserInfo;
		public static var s_mapStatus:Object;
		public static var s_consoleHotKeyEnabled:Boolean = true;

		private static var s_bgContainer:Sprite;
		private static var s_uiContainer:Sprite;
		private static var s_stageConsole:StageConsole;
				
		private var m_mainStateMachine:StateMachine;
		
		public function MagicStone()
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			ResourceManager.getInstance().installCompiledResourceBundles(ApplicationDomain.currentDomain, GameDefs.k_LOCALES, ["default"]);
			ResourceManager.getInstance().localeChain = [GameDefs.k_DEFAULT_LOCALE];
			
			s_bgContainer = new Sprite();
			s_uiContainer = new Sprite();
			addChild(s_bgContainer);
			addChild(s_uiContainer);
			
			UserOptions.instance.init("inutilis/DungeonsOfSuerhop");
			
			m_mainStateMachine = new StateMachine();
			
			var state:State = new InitializingState(m_mainStateMachine);
			m_mainStateMachine.setState(state);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public static function get gameStage():Stage
		{
			return s_bgContainer.stage;
		}
		
		public static function get bgContainer():Sprite
		{
			return s_bgContainer;
		}

		public static function get uiContainer():Sprite
		{
			return s_uiContainer;
		}
		
		public static function log(text:String):void
		{
			if (Config.debugConsole)
			{
				if (s_stageConsole == null)
				{
					s_stageConsole = new StageConsole(gameStage);
				}
				s_stageConsole.log(text);
			}
		}

		private function onEnterFrame(e:Event):void
		{
			GameTime.update();
			GameKeys.instance.update();
			m_mainStateMachine.update();
			WindowManager.instance.update();
			FxManager.instance.update();
			SplashScreen.instance.update();
			MusicPlayer.instance.update();
		}
		
		private function onAddedToStage(e:Event):void
		{
			Parameters.setParameters(LoaderInfo(this.root.loaderInfo).parameters);
			GameKeys.instance.stage = stage;
			MusicPlayer.instance.updateTime = 1000 / stage.frameRate;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			var optionsWindow:UserOptionsWindow = new UserOptionsWindow();
			optionsWindow.open();
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.charCode)
			{
				case 100: // d
					if (s_consoleHotKeyEnabled && s_stageConsole != null)
					{
						if (s_stageConsole.isVisible)
						{
							s_stageConsole.hide();
						}
						else
						{
							s_stageConsole.show();
							s_stageConsole.copyToClipboard();
						}
					}
					break;
			}
		}
	}
}