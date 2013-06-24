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
	
	public class HelpWindow extends Window
	{
		[Embed(source = "../../../embed/ui_popups.swf", symbol="UIHelp")]
		private var UIHelp:Class;
		
		private var m_pageTitles:Array;
		private var m_textPages:Array;
		private var m_textTitle:TextField;
		private var m_textField:TextField;
		private var m_textPage:TextField;
		private var m_buttonLeft:SimpleButton;
		private var m_buttonRight:SimpleButton;
		private var m_pageIndex:int;

		public function HelpWindow(pageTitles:Array, textPages:Array)
		{
			m_pageTitles = pageTitles;
			m_textPages = textPages;
			
			var ui:Sprite = new UIHelp() as Sprite;
			
			m_textTitle = DisplayUtils.setText(ui, "textTitle", "", GameDefs.k_TEXT_FORMAT_BOLD);
			m_textField = DisplayUtils.setText(ui, "text", "", GameDefs.k_TEXT_FORMAT);
			m_textPage = DisplayUtils.setText(ui, "textPage", "", GameDefs.k_TEXT_FORMAT_BOLD);
			
			m_buttonLeft = ui.getChildByName("buttonLeft") as SimpleButton;
			m_buttonRight = ui.getChildByName("buttonRight") as SimpleButton;
			
			m_pageIndex = 0;
			refreshCurrentPage();
			
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

		private function refreshCurrentPage():void
		{
			m_textTitle.text = m_pageTitles[m_pageIndex] as String;
			m_textField.text = m_textPages[m_pageIndex] as String;
			m_textPage.text = (m_pageIndex + 1) + " / " + m_textPages.length;
			m_buttonLeft.visible = (m_pageIndex > 0);
			m_buttonRight.visible = (m_pageIndex < m_textPages.length - 1);
		}
		
		private function onClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			switch (buttonName)
			{
				case "buttonLeft":
					m_pageIndex--;
					refreshCurrentPage();
					break;

				case "buttonRight":
					m_pageIndex++;
					refreshCurrentPage();
					break;
				
				case "buttonExit":
					close();
					break;

			}
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				close();
			}
			else if (e.keyCode == Keyboard.LEFT)
			{
				if (m_buttonLeft.visible)
				{
					m_pageIndex--;
					refreshCurrentPage();
				}
			}
			else if (e.keyCode == Keyboard.RIGHT)
			{
				if (m_buttonRight.visible)
				{
					m_pageIndex++;
					refreshCurrentPage();
				}
			}
		}

	}
}