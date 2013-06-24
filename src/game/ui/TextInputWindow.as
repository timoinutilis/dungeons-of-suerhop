package game.ui
{
	import com.adobe.utils.StringUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	
	import de.inutilis.inutilib.DisplayUtils;
	import de.inutilis.inutilib.StringUtils;
	import de.inutilis.inutilib.media.SoundManager;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.Window;
	
	import mx.resources.ResourceManager;
	
	public class TextInputWindow extends Window
	{
		[Embed(source = "../../../embed/ui_popups.swf", symbol="UITextInput")]
		private var UITextInput:Class;
		
		public static const k_BUTTON_ACCEPT:String = "buttonAccept";
		public static const k_BUTTON_CANCEL:String = "buttonCancel";
		
		private var m_allowEmpty:Boolean;
		private var m_textInput:TextField;
		private var m_buttonAccept:SimpleButton;

		public function TextInputWindow(text:String, input:String, allowEmpty:Boolean = true)
		{
			m_allowEmpty = allowEmpty;
			
			var ui:Sprite = new UITextInput() as Sprite;
			
			var textField:TextField = DisplayUtils.setText(ui, "text", text, GameDefs.k_TEXT_FORMAT);
			m_textInput = DisplayUtils.setText(ui, "textInput", input, GameDefs.k_TEXT_FORMAT);
			m_buttonAccept = DisplayUtils.setButtonText(ui, k_BUTTON_ACCEPT, ResourceManager.getInstance().getString("default", "buttonAccept"), GameDefs.k_TEXT_FORMAT_BOLD);
			DisplayUtils.setButtonText(ui, k_BUTTON_CANCEL, ResourceManager.getInstance().getString("default", "buttonCancel"), GameDefs.k_TEXT_FORMAT_BOLD);
			
			validateInput();
			
			ui.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			m_textInput.addEventListener(Event.CHANGE, onTextInput, false, 0, true);
			
			super(MagicStone.uiContainer, ui, 200, PositionRectangle.k_CENTER, true);
		}
		
		override public function open():void
		{
			super.open();
			MagicStone.s_consoleHotKeyEnabled = false;
			
			ui.stage.focus = m_textInput;
			var len:int = m_textInput.text.length;
			m_textInput.setSelection(len, len);
			
			SoundManager.instance.play(FileDefs.k_URL_SFX_PAPER);
			ui.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		override public function close():void
		{
			super.close();
			MagicStone.s_consoleHotKeyEnabled = true;
			SoundManager.instance.play(FileDefs.k_URL_SFX_PAPER_CLOSE);
			ui.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		public function get inputText():String
		{
			return StringUtils.toTitle(m_textInput.text);
		}
		
		private function validateInput():void
		{
			if (!m_allowEmpty)
			{
				var text:String = StringUtil.trim(m_textInput.text);
				m_buttonAccept.visible = (text.length > 0);
			}
		}
		
		private function onClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			switch (buttonName)
			{
				case k_BUTTON_ACCEPT:
				case k_BUTTON_CANCEL:
					close();
					break;
			}
		}
		
		private function onTextInput(e:Event):void
		{
			validateInput();
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				if (m_buttonAccept.visible)
				{
					var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.CLICK);
					m_buttonAccept.dispatchEvent(mouseEvent);
				}
			}
		}

	}
}