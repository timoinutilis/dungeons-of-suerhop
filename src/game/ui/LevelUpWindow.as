package game.ui
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	
	import inutilib.DisplayUtils;
	import inutilib.media.SoundManager;
	import inutilib.ui.PositionRectangle;
	import inutilib.ui.Window;
	
	import mx.resources.ResourceManager;

	public class LevelUpWindow extends Window
	{
		[Embed(source = "../../../embed/ui_popups.swf", symbol="UILevelUp")]
		private var UILevelUp:Class;
		
		private var m_buttonOk:SimpleButton;

		public function LevelUpWindow(text1:String, text2:String)
		{
			var ui:Sprite = new UILevelUp() as Sprite;
			
			DisplayUtils.setText(ui, "text1", text1, GameDefs.k_TEXT_FORMAT_BOLD);
			DisplayUtils.setText(ui, "text2", text2, GameDefs.k_TEXT_FORMAT);

			m_buttonOk = DisplayUtils.setButtonText(ui, "buttonOk", ResourceManager.getInstance().getString("default", "buttonOk"), GameDefs.k_TEXT_FORMAT_BOLD);

			ui.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			
			super(MagicStone.uiContainer, ui, 200, PositionRectangle.k_CENTER, true);
		}
		
		override public function open():void
		{
			super.open();
			SoundManager.instance.play(FileDefs.k_URL_SFX_PAPER);
			ui.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		override public function close():void
		{
			super.close();
			SoundManager.instance.play(FileDefs.k_URL_SFX_PAPER_CLOSE);
		}

		private function onClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			if (buttonName == "buttonOk")
			{
				close();
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.CLICK);
				m_buttonOk.dispatchEvent(mouseEvent);
			}
		}

	}
}