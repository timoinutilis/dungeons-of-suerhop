package game.ui
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	
	import de.inutilis.inutilib.DisplayUtils;
	import de.inutilis.inutilib.media.SoundManager;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.Window;
	
	import mx.resources.ResourceManager;
	
	public class MessageWriteWindow extends Window
	{
		[Embed(source = "../../../embed/ui_popups.swf", symbol="UIMessageWrite")]
		private var UIMessageWrite:Class;
		
		public static const k_BUTTON_ACCEPT:String = "buttonAccept";
		public static const k_BUTTON_CANCEL:String = "buttonCancel";
		
		private var m_textInput:TextField;
		private var m_buttonAccept:SimpleButton;
		private var m_previousText:String;


		public function MessageWriteWindow(title:String, input:String)
		{
			var ui:Sprite = new UIMessageWrite() as Sprite;
			
			DisplayUtils.setText(ui, "textTitle", title, GameDefs.k_TEXT_FORMAT);
			m_textInput = DisplayUtils.setText(ui, "text", input, GameDefs.k_TEXT_FORMAT);
			m_buttonAccept = DisplayUtils.setButtonText(ui, k_BUTTON_ACCEPT, ResourceManager.getInstance().getString("default", "buttonAccept"), GameDefs.k_TEXT_FORMAT_BOLD);
			DisplayUtils.setButtonText(ui, k_BUTTON_CANCEL, ResourceManager.getInstance().getString("default", "buttonCancel"), GameDefs.k_TEXT_FORMAT_BOLD);
			
			m_textInput.mouseWheelEnabled = false;
			m_textInput.addEventListener(Event.CHANGE, onChange, false, 0, true);
			
			ui.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			
			m_previousText = input;
			
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
		}
		
		override public function close():void
		{
			super.close();
			MagicStone.s_consoleHotKeyEnabled = true;
			SoundManager.instance.play(FileDefs.k_URL_SFX_PAPER_CLOSE);
		}

		public function get inputText():String
		{
			return m_textInput.text;
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
		
		private function onChange(e:Event):void
		{
			if (m_textInput.textHeight >= m_textInput.height)
			{
				m_textInput.text = m_previousText;
			}
			else
			{
				m_previousText = m_textInput.text;
			}
		}
	}
}