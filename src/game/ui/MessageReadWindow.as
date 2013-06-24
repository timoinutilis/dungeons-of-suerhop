package game.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	
	import inutilib.DisplayUtils;
	import inutilib.media.SoundManager;
	import inutilib.ui.PositionRectangle;
	import inutilib.ui.Window;
	
	public class MessageReadWindow extends Window
	{
		[Embed(source = "../../../embed/ui_popups.swf", symbol="UIMessageRead")]
		private var UIMessageRead:Class;
		
		public function MessageReadWindow(text:String)
		{
			var ui:Sprite = new UIMessageRead() as Sprite;
			
			DisplayUtils.setText(ui, "text", text, GameDefs.k_TEXT_FORMAT);
						
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
			ui.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		private function onClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			if (buttonName == "buttonReturn")
			{
				close();
			}
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				close();
			}
		}

	}
}