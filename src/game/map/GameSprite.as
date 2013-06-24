package game.map
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import game.GameDefs;
	import game.constants.RawTilesDefs;
	
	import inutilib.map.MapSprite;
	
	public class GameSprite extends MapSprite
	{
		public static const k_DIR_UP:int = 0;
		public static const k_DIR_DOWN:int = 1;
		public static const k_DIR_LEFT:int = 2;
		public static const k_DIR_RIGHT:int = 3;
		
		public var m_zOrder:int;

		protected var m_gameMap:GameMap;
		protected var m_rawColumn:int;
		protected var m_rawRow:int;
		private var m_zOrderOffset:int;
		private var m_movieClip:MovieClip;
		private var m_wallMask:Shape;

		public function GameSprite(gameMap:GameMap)
		{
			super();
			m_gameMap = gameMap;
			mouseChildren = false;
		}
		
		public function createNew():GameSprite
		{
			// override
			return null;
		}
		
		public function onPutOnMap():void
		{
			//override
		}
		
		public function get rawTile():int
		{
			// override
			return 0;
		}
		
		protected function refreshZOrder(rawColumn:int, rawRow:int):void
		{
			m_zOrder = m_zOrderOffset * 10000 + rawRow * 1000 + rawColumn;
		}
		
		public function setRawPosition(rawColumn:int, rawRow:int):void
		{
			m_rawColumn = rawColumn;
			m_rawRow = rawRow;
			refreshMapPosition();
			refreshValidation();
			refreshZOrder(m_rawColumn, m_rawRow);
		}
		
		protected function refreshMapPosition():void
		{
			mapX = m_rawColumn * GameDefs.k_TILE_WIDTH * 2 + GameDefs.k_TILE_WIDTH;
			mapY = m_rawRow * GameDefs.k_TILE_HEIGHT * 2 + GameDefs.k_TILE_HEIGHT;
		}
		
		public function get rawColumn():int
		{
			return m_rawColumn;
		}
		
		public function get rawRow():int
		{
			return m_rawRow;
		}
		
		public function set zOrderOffset(value:int):void
		{
			m_zOrderOffset = value;
			refreshZOrder(m_rawColumn, m_rawRow);
		}
		
		public function refreshValidation():void
		{
			var originalAlpha:Number = alpha;
			if (isPositionValid())
			{
				if (transform.colorTransform.redOffset > 0)
				{
					transform.colorTransform = new ColorTransform();
					alpha = originalAlpha;
				}
			}
			else if (transform.colorTransform.redOffset == 0)
			{
				transform.colorTransform = new ColorTransform(1, 0.5, 0.5, 1, 64, 0, 0);
				alpha = originalAlpha;
			}
		}

		public function set movieClip(movieClip:MovieClip):void
		{
			if (m_movieClip != null)
			{
				removeChild(m_movieClip);
				m_movieClip = null;
			}
			addChild(movieClip);
			m_movieClip = movieClip;
		}
		
		public function get movieClip():MovieClip
		{
			return m_movieClip;
		}
		
		public function set highlight(enable:Boolean):void
		{
			if (enable)
			{
				filters = [new GlowFilter(0xffe6db, 1, 12, 12, 2)];
			}
			else
			{
				filters = null;
			}
		}
		
		public function isPositionValid():Boolean
		{
			var tile:int = m_gameMap.getRawTile(m_rawColumn, m_rawRow) & RawTilesDefs.k_MASK_TILE;
			return (tile == RawTilesDefs.k_FLOOR);
		}
		
		public function getProblem():String
		{
			// override
			return null;
		}
		
		public function update():void
		{
			// override
		}

		public function getFxPoint():Point
		{
			return localToGlobal(new Point(0, 0));
		}
		
		public function getUnlockLevel():int
		{
			return 1;
		}
		
		protected function createWallMask():void
		{
			if (m_wallMask != null)
			{
				m_movieClip.mask = null;
				removeChild(m_wallMask);
				m_wallMask = null;
			}
			
			// create maks if position is valid. if it's invalid, show whole sprite (no mask).
			if (isPositionValid())
			{
				var wallUp:Boolean = (m_gameMap.getRawTile(m_rawColumn, m_rawRow - 1) & RawTilesDefs.k_MASK_TILE) != RawTilesDefs.k_FLOOR;
				var wallDown:Boolean = (m_gameMap.getRawTile(m_rawColumn, m_rawRow + 1) & RawTilesDefs.k_MASK_TILE) != RawTilesDefs.k_FLOOR;
				var wallLeft:Boolean = (m_gameMap.getRawTile(m_rawColumn - 1, m_rawRow) & RawTilesDefs.k_MASK_TILE) != RawTilesDefs.k_FLOOR;
				var wallRight:Boolean = (m_gameMap.getRawTile(m_rawColumn + 1, m_rawRow) & RawTilesDefs.k_MASK_TILE) != RawTilesDefs.k_FLOOR;
				
				if (wallUp || wallDown || wallLeft || wallRight)
				{
					var rect:Rectangle = new Rectangle(-GameDefs.k_TILE_WIDTH, -GameDefs.k_TILE_HEIGHT, GameDefs.k_TILE_WIDTH * 2, GameDefs.k_TILE_HEIGHT * 2);
					if (wallUp)
					{
						rect.top += 45;
					}
					if (wallDown)
					{
						rect.bottom -= 10;
					}
					if (wallLeft)
					{
						rect.left += 28;
					}
					if (wallRight)
					{
						rect.right -= 28;
					}
					m_wallMask = new Shape();
					m_wallMask.graphics.beginFill(0xFFFFFF);
					m_wallMask.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
					addChild(m_wallMask);
					m_movieClip.mask = m_wallMask;
				}
			}
		}
	}
}