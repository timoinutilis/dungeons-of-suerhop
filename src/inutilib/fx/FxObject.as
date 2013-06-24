package inutilib.fx
{
	import flash.display.Sprite;

	public class FxObject
	{
		private var m_sprite:Sprite;
		
		public function FxObject(sprite:Sprite)
		{
			m_sprite = sprite;
		}
		
		public function get sprite():Sprite
		{
			return m_sprite;
		}
		
		public function update():void
		{
			
		}
		
		public function hasFinished():Boolean
		{
			return true;
		}
	}
}