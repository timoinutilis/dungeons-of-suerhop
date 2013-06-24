package game.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
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
	
	import mx.resources.ResourceManager;
	
	public class PopupWindow extends Window
	{
		[Embed(source = "../../../embed/ui_popups.swf", symbol="UIPopup")]
		private var UIPopup:Class;
		
		public static const k_TYPE_OK:int = 0;
		public static const k_TYPE_YES_NO:int = 1;
		public static const k_TYPE_WAIT:int = 2;
		
		public static const k_BUTTON_OK:String = "buttonOk";
		public static const k_BUTTON_YES:String = "buttonYes";
		public static const k_BUTTON_NO:String = "buttonNo";
		
		private var m_buttonOk:SimpleButton;
		private var m_buttonYes:SimpleButton;
		private var m_textField:TextField;
		private var m_waitAnim:MovieClip;
		private var m_allowYesByKey:Boolean;

		public function PopupWindow(type:int, text:String, allowYesByKey:Boolean = true)
		{
			m_allowYesByKey = allowYesByKey;
			
			var ui:Sprite = new UIPopup() as Sprite;
			
			m_buttonOk = DisplayUtils.setButtonText(ui, k_BUTTON_OK, ResourceManager.getInstance().getString("default", "buttonOk"), GameDefs.k_TEXT_FORMAT_BOLD);
			m_buttonYes = DisplayUtils.setButtonText(ui, k_BUTTON_YES, ResourceManager.getInstance().getString("default", "buttonYes"), GameDefs.k_TEXT_FORMAT_BOLD);
			var buttonNo:SimpleButton = DisplayUtils.setButtonText(ui, k_BUTTON_NO, ResourceManager.getInstance().getString("default", "buttonNo"), GameDefs.k_TEXT_FORMAT_BOLD);
			m_textField = DisplayUtils.setText(ui, "text", text, GameDefs.k_TEXT_FORMAT);
			m_waitAnim = ui.getChildByName("waitAnim") as MovieClip;
			
			switch (type)
			{
				case k_TYPE_OK:
					m_buttonYes.visible = false;
					buttonNo.visible = false;
					m_waitAnim.visible = false;
					break;
				
				case k_TYPE_YES_NO:
					m_buttonOk.visible = false;
					m_waitAnim.visible = false;
					break;
				
				case k_TYPE_WAIT:
					m_buttonYes.visible = false;
					buttonNo.visible = false;
					m_buttonOk.visible = false;
					m_textField.visible = false;
					break;
			}
			
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

		public function waitingDone():void
		{
			m_textField.visible = true;
			m_buttonOk.visible = true;
			m_waitAnim.visible = false;
		}
		
		private function onClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			switch (buttonName)
			{
				case k_BUTTON_OK:
				case k_BUTTON_YES:
				case k_BUTTON_NO:
					close();
					break;
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				if (m_buttonOk.visible)
				{
					m_buttonOk.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}
				else if (m_buttonYes.visible && m_allowYesByKey)
				{
					m_buttonYes.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}
			}
		}
	}
}