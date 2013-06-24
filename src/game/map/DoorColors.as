package game.map
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;
	import game.constants.TilesDefs;
	
	import de.inutilis.inutilib.map.MapSprite;
	
	public class DoorColors extends GameSprite
	{
		[Embed(source = "../../../embed/ui_object.swf", symbol="DoorGui")]
		private var DoorGui:Class;

		public static const k_STATE_CLOSED:int = 0;
		public static const k_STATE_OPENING:int = 1;
		public static const k_STATE_OPEN:int = 2;
		public static const k_STATE_CLOSING:int = 3;
		
		private static const k_FRAME_OPEN:String = "open";
		
		private var m_isHorizontal:Boolean;
		private var m_state:int;
		private var m_color:int;
		private var m_doorGui:Sprite;
		private var m_showGui:Boolean
		
		public function DoorColors(gameMap:GameMap, isOpen:Boolean, color:int, showGui:Boolean)
		{
			super(gameMap);
			m_state = isOpen ? k_STATE_OPEN : k_STATE_CLOSED;
			m_color = color;
			m_showGui = showGui;

			if (m_showGui)
			{
				m_doorGui = new DoorGui as Sprite;
				m_doorGui.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
				mouseChildren = true;
				addChild(m_doorGui);
			}
			
			refreshMovieClip();
		}
		
		override public function createNew():GameSprite
		{
			var copy:DoorColors = new DoorColors(m_gameMap, false, m_color, true);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function onPutOnMap():void
		{
			refreshDirection();
			refreshMovieClip();
			
			zOrderOffset = m_isHorizontal ? 1 : -1;
		}
		
		private function refreshDirection():void
		{
			m_isHorizontal = (
				(m_gameMap.getRawTile(rawColumn, rawRow + 1) & RawTilesDefs.k_MASK_TILE) == RawTilesDefs.k_EARTH
				&& (m_gameMap.getRawTile(rawColumn, rawRow) & RawTilesDefs.k_MASK_TILE) == RawTilesDefs.k_FLOOR);
		}

		override public function get rawTile():int
		{
			return ((m_state == k_STATE_CLOSED || m_state == k_STATE_CLOSING) ? RawTilesDefs.k_DOOR_COLORS_1 : RawTilesDefs.k_DOOR_COLORS_OPEN_1) + (m_color << RawTilesDefs.k_SHIFT_OBJECT);
		}
		
		override public function isPositionValid():Boolean
		{
			var tile1:int;
			var tile2:int;
			
			refreshDirection();
			if (m_isHorizontal)
			{
				tile1 = m_gameMap.getRawTile(m_rawColumn, m_rawRow - 1) & RawTilesDefs.k_MASK_TILE;
				if (tile1 != RawTilesDefs.k_EARTH)
				{
					return false;
				}
			}
			else
			{
				tile1 = m_gameMap.getRawTile(m_rawColumn - 1, m_rawRow) & RawTilesDefs.k_MASK_TILE;
				tile2 = m_gameMap.getRawTile(m_rawColumn + 1, m_rawRow) & RawTilesDefs.k_MASK_TILE;
				if (tile1 != RawTilesDefs.k_EARTH || tile2 != RawTilesDefs.k_EARTH)
				{
					return false;
				}
			}
			
			return super.isPositionValid();
		}

		public function get currentState():int
		{
			return m_state;
		}
		
		public function set color(value:int):void
		{
			m_color = value;
			refreshMovieClip();
		}
		
		public function get color():int
		{
			return m_color;
		}

		public function toggle():void
		{
			if (m_state == k_STATE_CLOSED || m_state == k_STATE_CLOSING)
			{
				movieClip.gotoAndPlay(1);
				m_state = k_STATE_OPENING;
				m_gameMap.setRawTileObject(m_rawColumn, m_rawRow, rawTile);
			}
			else
			{
				movieClip.gotoAndPlay(k_FRAME_OPEN);
				m_state = k_STATE_CLOSING;
				m_gameMap.setRawTileObject(m_rawColumn, m_rawRow, rawTile);
			}
		}
		
		private function refreshMovieClip():void
		{
			var spriteClass:Class;
			if (m_isHorizontal)
			{
				spriteClass = m_gameMap.spriteClasses[ObjectsDefs.k_DOOR_COLORS_HORIZONTAL];
			}
			else
			{
				spriteClass = m_gameMap.spriteClasses[ObjectsDefs.k_DOOR_COLORS_VERTICAL];
			}
			movieClip = new spriteClass as MovieClip;
			if (m_state == k_STATE_CLOSED)
			{
				movieClip.gotoAndStop(1);
			}
			else
			{
				movieClip.gotoAndStop(k_FRAME_OPEN);
			}
				
			
			var doorMovieClip:MovieClip = movieClip.getChildAt(1) as MovieClip;
			doorMovieClip.gotoAndStop(m_color + 1);
			
			if (m_showGui)
			{
				movieClip.mouseEnabled = false;
				movieClip.mouseChildren = false;
				setChildIndex(m_doorGui, numChildren - 1);
			}
		}
		
		override public function update():void
		{
			if (m_state == k_STATE_OPENING && movieClip.currentFrameLabel == k_FRAME_OPEN)
			{
				movieClip.stop();
				m_state = k_STATE_OPEN;
			}
			else if (m_state == k_STATE_CLOSING && movieClip.currentFrame == movieClip.totalFrames)
			{
				movieClip.gotoAndStop(1);
				m_state = k_STATE_CLOSED;
			}
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			if (e.target.name == "buttonToggle")
			{
				if (m_state == k_STATE_CLOSED)
				{
					m_state = k_STATE_OPEN;
					movieClip.gotoAndStop(k_FRAME_OPEN);
				}
				else
				{
					m_state = k_STATE_CLOSED;
					movieClip.gotoAndStop(1);
				}
				m_gameMap.setRawTileObject(m_rawColumn, m_rawRow, rawTile);
			}
		}
		
		override public function getUnlockLevel():int
		{
			return 2;
		}
		
		override public function getProblem():String
		{
			var sprites:Array = m_gameMap.mainScrollMap.mapSprites;
			for each (var gameSprite:GameSprite in sprites)
			{
				if (gameSprite is DoorButton)
				{
					var button:DoorButton = gameSprite as DoorButton;
					if (button.color == m_color)
					{
						return null;
					}
				}
			}
			return "There is an automatic door without any matching button. Please put a button with the same color or remove the door!";
		}
	}
}