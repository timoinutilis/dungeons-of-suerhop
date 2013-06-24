package de.inutilis.inutilib.fx
{
	import flash.display.DisplayObjectContainer;
	

	public class FxManager
	{
		private static var s_instance:FxManager;
		
		private var m_fx:Array;
		private var m_container:DisplayObjectContainer;
		private var m_lastX:Number;
		private var m_lastY:Number;
		
		public static function get instance():FxManager
		{
			if (s_instance == null)
			{
				s_instance = new FxManager();
			}
			return s_instance;
		}

		public function FxManager()
		{
			m_fx = new Array();
		}
		
		public function set container(container:DisplayObjectContainer):void
		{
			m_container = container;
		}
		
		public function clear():void
		{
			for each (var fx:FxObject in m_fx)
			{
				m_container.removeChild(fx.sprite);
			}
			m_fx.length = 0;
		}
		
		public function addFx(fx:FxObject, x:Number, y:Number):void
		{
			fx.sprite.x = x;
			fx.sprite.y = y;
			m_fx.push(fx);
			m_container.addChild(fx.sprite);
		}
		
		public function setPosition(x:Number, y:Number):void
		{
			for each (var fx:FxObject in m_fx)
			{
				fx.sprite.x += Math.round(m_lastX - x);
				fx.sprite.y += Math.round(m_lastY - y);
			}
			m_lastX = Math.round(x);
			m_lastY = Math.round(y);
		}
		
		public function update():void
		{
			for each (var fx:FxObject in m_fx)
			{
				fx.update();
				if (fx.hasFinished())
				{
					m_container.removeChild(fx.sprite);
					m_fx.splice(m_fx.indexOf(fx), 1);
				}
			}
		}

	}
}