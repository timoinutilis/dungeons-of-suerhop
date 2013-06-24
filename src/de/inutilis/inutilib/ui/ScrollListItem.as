package de.inutilis.inutilib.ui
{
	import flash.display.Sprite;

	public class ScrollListItem
	{
		protected var m_sprite:Sprite;
		
		public function ScrollListItem(sprite:Sprite)
		{
			m_sprite = sprite;
		}
		
		public function get sprite():Sprite
		{
			return m_sprite;
		}
		
		public function onShow():void
		{
			// override
		}

		public function onHide():void
		{
			// override
		}
	}
}