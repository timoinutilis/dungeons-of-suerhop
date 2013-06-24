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
	
	import de.inutilis.inutilib.DisplayUtils;
	import de.inutilis.inutilib.media.SoundManager;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.Window;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	public class AfterPlayWindow extends Window
	{
		[Embed(source = "../../../embed/ui_popups.swf", symbol="UIAfterPlay")]
		private var UIAfterPlay:Class;
		
		public static const k_TYPE_OK:int = 0;
		public static const k_TYPE_YES_NO:int = 1;
		
		public static const k_BUTTON_OK:String = "buttonOk";
		public static const k_BUTTON_YES:String = "buttonYes";
		public static const k_BUTTON_NO:String = "buttonNo";
		public static const k_BUTTON_INVITE:String = "buttonInvite";
		public static const k_BUTTON_SHARE:String = "buttonShare";
		
		private var m_buttonOk:SimpleButton;
		
		public function AfterPlayWindow(type:int, titleText:String, inviteText:String, shareText:String, text:String, score:int, highscore:int)
		{
			var ui:Sprite = new UIAfterPlay() as Sprite;
			
			var res:IResourceManager = ResourceManager.getInstance();
			m_buttonOk = DisplayUtils.setButtonText(ui, "buttonOk", res.getString("default", "buttonOk"), GameDefs.k_TEXT_FORMAT_BOLD);
			var buttonYes:SimpleButton = DisplayUtils.setButtonText(ui, "buttonYes", res.getString("default", "buttonYes"), GameDefs.k_TEXT_FORMAT_BOLD);
			var buttonNo:SimpleButton = DisplayUtils.setButtonText(ui, "buttonNo", res.getString("default", "buttonNo"), GameDefs.k_TEXT_FORMAT_BOLD);
			DisplayUtils.setButtonText(ui, "buttonInvite", res.getString("default", "buttonInvite"), GameDefs.k_TEXT_FORMAT_BOLD);
			DisplayUtils.setButtonText(ui, "buttonShare", res.getString("default", "buttonShare"), GameDefs.k_TEXT_FORMAT_BOLD);
			
			switch (type)
			{
				case k_TYPE_OK:
					buttonYes.visible = false;
					buttonNo.visible = false;
					break;
				
				case k_TYPE_YES_NO:
					m_buttonOk.visible = false;
					break;				
			}
			
			var highscoreText:String = (highscore > 0) ? res.getString("default", (score >= highscore) ? "textCompletedHighscoreOld" : "textCompletedHighscore").replace("%1", highscore) : "";
			
			DisplayUtils.setText(ui, "textTitle", titleText, GameDefs.k_TEXT_FORMAT_BOLD);
			DisplayUtils.setText(ui, "textScore", res.getString("default", "textCompletedScore").replace("%1", score), GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(ui, "textHighscore", highscoreText, GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(ui, "textInvite", inviteText, GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(ui, "textShare", shareText, GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(ui, "text", text, GameDefs.k_TEXT_FORMAT);
			
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
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				if (m_buttonOk.visible)
				{
					var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.CLICK);
					m_buttonOk.dispatchEvent(mouseEvent);
				}
			}
		}

	}
}