package inutilib.ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;

	public class RadioButtons
	{
		private var m_buttons:Array;
		private var m_selectedButton:SimpleButton;
		private var m_selectedUpState:DisplayObject;
		private var m_selectedOverState:DisplayObject;
		
		public function RadioButtons()
		{
			m_buttons = new Array();
		}
		
		public function addButtons(container:DisplayObjectContainer, name:String):void
		{
			var num:int = 1;
			var button:SimpleButton;
			
			while ((button = container.getChildByName(name + num) as SimpleButton) != null)
			{
				m_buttons.push(button);
				button.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
				num++;
			}
		}
		
		public function setSelectedButtonIndex(index:int):void
		{
			selectedButton = m_buttons[index] as SimpleButton;
		}
		
		public function set selectedButton(button:SimpleButton):void
		{
			if (m_selectedButton != null)
			{
				m_selectedButton.upState = m_selectedUpState;
				m_selectedButton.overState = m_selectedOverState;
				m_selectedUpState = null;
				m_selectedButton = null;
			}
			
			m_selectedButton = button;

			if (button != null)
			{
				m_selectedUpState = button.upState;
				m_selectedOverState = button.overState;
				button.upState = button.downState;
				button.overState = button.downState;
			}
		}
		
		public function get selectedButton():SimpleButton
		{
			return m_selectedButton;
		}
		
		private function onClick(e:MouseEvent):void
		{
			selectedButton = e.currentTarget as SimpleButton;
		}
	}
}