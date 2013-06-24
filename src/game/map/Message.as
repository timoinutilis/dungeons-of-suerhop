package game.map
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;
	import game.ui.MessageReadWindow;
	import game.ui.MessageWriteWindow;
	
	import mx.resources.ResourceManager;

	public class Message extends GameSprite
	{
		[Embed(source = "../../../embed/ui_object.swf", symbol="MessageGui")]
		private var MessageGui:Class;

		private var m_text:String;
		private var m_inputWindow:MessageWriteWindow;
		
		public function Message(gameMap:GameMap, text:String, showGui:Boolean)
		{
			super(gameMap);
			m_text = (text != null) ? text : "";
			
			var spriteClass:Class = m_gameMap.spriteClasses[ObjectsDefs.k_MESSAGE];
			movieClip = new spriteClass as MovieClip;
			
			zOrderOffset = -1;
			
			if (showGui)
			{
				var messageGui:Sprite = new MessageGui as Sprite;
				messageGui.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
				mouseChildren = true;
				addChild(messageGui);
			}

		}
		
		override public function createNew():GameSprite
		{
			var copy:Message = new Message(m_gameMap, m_text, true);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function get rawTile():int
		{
			return RawTilesDefs.k_MESSAGE;
		}
		
		override public function getUnlockLevel():int
		{
			return 3;
		}
		
		override public function getProblem():String
		{
			if (m_text.length == 0)
			{
				return "There is a message in the dungeon without text. Please write one or remove the message!\r(Use messages to create some story or to give hints.)";
			}
			return null;
		}

		public function show():void
		{
			var popup:MessageReadWindow = new MessageReadWindow(m_text);
			popup.open();
		}
		
		public function edit():void
		{
			m_inputWindow = new MessageWriteWindow(ResourceManager.getInstance().getString("default", "textWriteMessage"), m_text);
			m_inputWindow.ui.addEventListener(MouseEvent.CLICK, onInputWindowClick, false, 0, true);
			m_inputWindow.open();
		}
		
		public function get text():String
		{
			return m_text;
		}

		public function set text(value:String):void
		{
			m_text = value;
		}

		private function onMouseClick(e:MouseEvent):void
		{
			if (e.target.name == "buttonToggle")
			{
				edit();
			}
		}
		
		private function onInputWindowClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			if (buttonName == MessageWriteWindow.k_BUTTON_ACCEPT)
			{
				text = m_inputWindow.inputText;
				m_inputWindow = null;
				m_gameMap.setChanged();
			}
			else if (buttonName == MessageWriteWindow.k_BUTTON_CANCEL)
			{
				m_inputWindow = null;
			}

		}

	}
}