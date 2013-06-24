package de.inutilis.inutilib.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	
	import flashx.textLayout.elements.BreakElement;
	
	import de.inutilis.inutilib.media.ImageManager;

	public class SplashScreen
	{
		private static var s_instance:SplashScreen;

		private var m_symbol:String;
		private var m_onLoadedFunction:Function;
		private var m_movieClip:MovieClip;
		private var m_container:DisplayObjectContainer;
		private var m_currentCommand:Command;
		private var m_queue:Array;
		
		public static function get instance():SplashScreen
		{
			if (s_instance == null)
			{
				s_instance = new SplashScreen();
			}
			return s_instance;
		}

		public function SplashScreen()
		{
			m_queue = new Array();
		}
		
		public function set container(container:DisplayObjectContainer):void
		{
			if (container != m_container)
			{
				if (m_movieClip != null && m_container != null)
				{
					m_container.removeChild(m_movieClip);
				}
				m_container = container;
				if (m_movieClip != null && m_container != null)
				{
					m_container.addChild(m_movieClip);
				}
			}
		}
		
		public function load(url:String, symbol:String, onLoadedFunction:Function = null):void
		{
			m_symbol = symbol;
			m_onLoadedFunction = onLoadedFunction;
			ImageManager.instance.request(url, onLoaded);
		}
		
		public function queuePlay(fromFrame:String, toFrame:String, newFrame:String = null):void
		{
			var command:Command;
			
			if (newFrame == null)
			{
				newFrame = toFrame;
			}
			
			// don't keep animations with same end frame in the queue
			if (m_currentCommand != null && m_currentCommand.newFrame == newFrame)
			{
				removePlaysFrom(0);
				return;
			}
			else if (m_queue.length > 0)
			{
				for (var i:int = 0; i < m_queue.length; i++)
				{
					command = m_queue[i] as Command;
					if (command.newFrame == newFrame)
					{
						removePlaysFrom(i + 1);
						return;
					}
				}
			}
			else if (m_movieClip != null && m_movieClip.currentFrameLabel == newFrame)
			{
				return;
			}
			
			command = new Command();
			command.type = Command.k_PLAY;
			command.fromFrame = fromFrame;
			command.toFrame = toFrame;
			command.newFrame = newFrame
			addCommand(command);
		}
		
		public function queueCallback(callback:Function):void
		{
			var command:Command = new Command();
			command.type = Command.k_CALLBACK;
			command.callback = callback;
			addCommand(command);
		}
		
		public function removeCallback(callback:Function):void
		{
			for (var i:int = 0; i < m_queue.length; i++)
			{
				var command:Command = m_queue[i] as Command;
				if (command.type == Command.k_CALLBACK && command.callback == callback)
				{
					m_queue.splice(i, 1);
					break;
				}
			}
		}
		
		public function queueRemove():void
		{
			if (m_container != null)
			{
				var command:Command = new Command();
				command.type = Command.k_REMOVE;
				addCommand(command);
			}
		}
		
		public function update():void
		{
			if (m_movieClip != null)
			{
				if (m_currentCommand == null && m_queue.length > 0)
				{
					startCommand(m_queue.shift());
				}
				
				if (m_currentCommand != null)
				{
					switch (m_currentCommand.type)
					{
						case Command.k_PLAY:
							if (m_movieClip.currentFrameLabel == m_currentCommand.toFrame)
							{
								m_movieClip.gotoAndStop(m_currentCommand.newFrame);
								finishCommand();
							}
							break;
						
						case Command.k_CALLBACK:
							m_currentCommand.callback();
							finishCommand();
							break;
					}
				}
			}
		}
		
		private function removePlaysFrom(index:int):void
		{
			var i:int = index;
			while (i < m_queue.length)
			{
				var command:Command = m_queue[i] as Command;
				if (command.type == Command.k_PLAY)
				{
					m_queue.splice(i, 1);
				}
				else
				{
					i++
				}
			}
		}
		
		private function startCommand(command:Command):void
		{
			m_currentCommand = command;
			switch (m_currentCommand.type)
			{
				case Command.k_PLAY:
					m_movieClip.gotoAndPlay(m_currentCommand.fromFrame);
					break;
				
				case Command.k_REMOVE:
					if (m_container != null)
					{
						m_container.removeChild(m_movieClip);
						m_container = null;
						m_currentCommand = null;
					}
					break;
			}
		}
		
		private function finishCommand():void
		{
			if (m_queue.length > 0)
			{
				startCommand(m_queue.shift());
			}
			else
			{
				m_currentCommand = null;
			}
		}
		
		private function addCommand(command:Command):void
		{
			if (m_currentCommand == null && m_movieClip != null)
			{
				startCommand(command);
			}
			else
			{
				m_queue.push(command);
			}
		}
		
		private function onLoaded(url:String, spare:Object):void
		{
			if (m_onLoadedFunction != null)
			{
				m_onLoadedFunction();
			}
			
			var SpriteClass:Class = ImageManager.instance.getSpriteClass(url, m_symbol);
			m_movieClip = new SpriteClass as MovieClip;
			m_movieClip.mouseEnabled = false;
			m_movieClip.mouseChildren = false;
			if (m_container != null)
			{
				m_container.addChild(m_movieClip);
			}
			
			update();
		}
	}
}

internal class Command
{
	public static const k_PLAY:int = 0;
	public static const k_CALLBACK:int = 1;
	public static const k_REMOVE:int = 2;
	
	public var type:int;
	public var fromFrame:String;
	public var toFrame:String;
	public var newFrame:String;
	public var callback:Function;
}
