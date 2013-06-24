package inutilib
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class GameKeys
	{
		public static const k_UNDEFINED:int = -1;
		public static const k_UP:int = 0;
		public static const k_DOWN:int = 1;
		public static const k_LEFT:int = 2;
		public static const k_RIGHT:int = 3;
		public static const k_FIRE:int = 4;
		private static const k_NUM_KEYS:int = 5;
		
		public static const k_STATE_UP:int = 0;
		public static const k_STATE_PRESSED:int = 1;
		public static const k_STATE_DOWN:int = 2;
		public static const k_STATE_RELEASED:int = 3;
		
		private static var s_instance:GameKeys;

		private var m_keyStates:Array;
		private var m_dirty:Array;
		private var m_stage:Stage;
		
		
		public static function get instance():GameKeys
		{
			if (s_instance == null)
			{
				s_instance = new GameKeys();
			}
			return s_instance;
		}
		
		public function GameKeys()
		{
			m_keyStates = new Array(k_NUM_KEYS);
			m_dirty = new Array(k_NUM_KEYS);
		}

		public function set stage(stage:Stage):void
		{
			if (m_stage != null)
			{
				m_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				m_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
			m_stage = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		public function update():void
		{
			for (var i:int = 0; i < k_NUM_KEYS; i++)
			{
				if (!m_dirty[i])
				{
					var state:int = m_keyStates[i];
					if (state == k_STATE_PRESSED)
					{
						m_keyStates[i] = k_STATE_DOWN;
					}
					else if (state == k_STATE_RELEASED)
					{
						m_keyStates[i] = k_STATE_UP;
					}
				}
				else
				{
					m_dirty[i] = false;
				}
			}
		}
		
		public function getKeyState(gameKey:int):int
		{
			return m_keyStates[gameKey];
		}
		
		public function isKeyDown(gameKey:int):Boolean
		{
			var state:int = m_keyStates[gameKey];
			return (state == k_STATE_PRESSED || state == k_STATE_DOWN);
		}
		
		public function getGameKey(keyCode:uint):int
		{
			switch (keyCode)
			{
				case Keyboard.UP: return k_UP;
				case Keyboard.DOWN: return k_DOWN;
				case Keyboard.LEFT: return k_LEFT;
				case Keyboard.RIGHT: return k_RIGHT;
				case Keyboard.SPACE: return k_FIRE;
			}
			return k_UNDEFINED;
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			var gameKey:int = getGameKey(e.keyCode);
			if (gameKey != k_UNDEFINED)
			{
				if (m_keyStates[gameKey] != k_STATE_DOWN)
				{
					m_keyStates[gameKey] = k_STATE_PRESSED;
					m_dirty[gameKey] = true;
				}
			}
		}

		private function onKeyUp(e:KeyboardEvent):void
		{
			var gameKey:int = getGameKey(e.keyCode);
			if (gameKey != k_UNDEFINED)
			{
				m_keyStates[gameKey] = k_STATE_RELEASED;
				m_dirty[gameKey] = true;
			}
		}

	}
}