package inutilib.debug
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.system.System;
	import flash.text.TextField;

	public class StageConsole
	{
		private var m_sprite:Sprite;
		private var m_textField:TextField;
		private var m_stage:Stage;
		private var m_isVisible:Boolean;
		private var m_log:String;

		public function StageConsole(stage:Stage)
		{
			m_stage = stage;
			
			m_log = "";
			
			m_sprite = new Sprite();
			m_sprite.graphics.beginFill(0x0000FF, 0.5);
			m_sprite.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			m_textField = new TextField();
			m_textField.x = 5;
			m_textField.y = 5;
			m_textField.width = stage.stageWidth - 10;
			m_textField.height = stage.stageHeight - 10;
			m_textField.textColor = 0xFFFFFF;
			m_textField.wordWrap = true;
			
			m_sprite.addChild(m_textField);
		}
		
		public function get isVisible():Boolean
		{
			return m_isVisible;
		}
		
		public function show():void
		{
			m_stage.addChild(m_sprite);
			m_textField.text = m_log;
			m_isVisible = true;
		}
		
		public function hide():void
		{
			if (m_isVisible)
			{
				m_stage.removeChild(m_sprite);
				m_isVisible = false;
			}
		}
		
		public function log(text:String):void
		{
			trace("LOG: " + text);
			m_log += text + "\r\r";
			if (m_isVisible)
			{
				m_textField.text = m_log;
			}
		}
		
		public function copyToClipboard():void
		{
			System.setClipboard(m_log);
		}
	}
}