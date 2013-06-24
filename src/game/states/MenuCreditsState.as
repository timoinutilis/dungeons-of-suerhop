package game.states
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import game.GameDefs;
	import game.MagicStone;
	
	import inutilib.statemachine.State;
	import inutilib.statemachine.StateMachine;
	
	public class MenuCreditsState extends State
	{
		private static const k_FADE_PER_FRAME:Number = 0.05;
		
		private var m_container:DisplayObjectContainer;
		private var m_blocker:Sprite;
		private var m_textField:TextField;
		private var m_fadeOut:Boolean;
		
		public function MenuCreditsState(stateMachine:StateMachine)
		{
			super(stateMachine);
			m_container = MagicStone.uiContainer;
		}
		
		override public function start():void
		{
			m_blocker = new Sprite();
			m_blocker.graphics.beginFill(0x000000, 0.5);
			m_blocker.graphics.drawRect(0, 0, m_container.stage.stageWidth, m_container.stage.stageHeight);
			m_blocker.alpha = 0.0;
			m_container.addChild(m_blocker);

			m_textField = new TextField();
			m_textField.autoSize = TextFieldAutoSize.CENTER;
			m_textField.embedFonts = true;				
			m_textField.defaultTextFormat = GameDefs.k_CREDITS_TEXT_FORMAT;
			m_textField.text = "Dungeons of Suerhop (" + GameDefs.k_VERSION + ")\r\r" +
				"Code, Graphics, Music, Sounds\rTimo Kloss\r\r" +
				"Main Character Animations\rAna Vilanueva\r\r" +
				"Logo Design\rJesús Paniagua\r\r" +
				"Translations\rAnalía R. Basic (ES), Antoine Cabrol (FR)\r\r" +
				"Thanks to\rXavier Noguera\r\r" +
				"Inutilis Software 2011";
			
			m_textField.y = m_container.stage.stageHeight;
			m_textField.x = (m_container.stage.stageWidth - m_textField.width) / 2;
			m_textField.mouseEnabled = false;
			
			m_container.addChild(m_textField);
			
			m_blocker.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}
		
		override public function end():void
		{
			m_container.removeChild(m_textField);
			m_container.removeChild(m_blocker);
		}
		
		override public function update():void
		{
			m_textField.y -= 1;
			if (m_fadeOut)
			{
				if (m_blocker.alpha > 0)
				{
					m_blocker.alpha -= k_FADE_PER_FRAME;
					m_textField.alpha -= k_FADE_PER_FRAME;
				}
				else
				{
					m_stateMachine.exitCurrentState();
				}
			}
			else if (m_textField.y < -m_textField.height)
			{
				m_fadeOut = true;
			}
			else
			{
				if (m_blocker.alpha < 1)
				{
					m_blocker.alpha += k_FADE_PER_FRAME;
				}
			}
		}
		
		private function onClick(e:MouseEvent):void
		{
			m_fadeOut = true;
		}
	}
}