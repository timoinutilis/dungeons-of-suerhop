package de.inutilis.inutilib.map
{
	import flash.display.Sprite;
	
	import de.inutilis.inutilib.GameTime;
	
	public class ScrollTileMap extends Sprite
	{
		private var m_tileMap:TileMap;
		private var m_mapSprites:Array;
		private var m_tileBitmaps:Array;
		private var m_scrollContainer:Sprite;
		private var m_scrollX:Number = 0;
		private var m_scrollY:Number = 0;
		private var m_scrollColumn:int;
		private var m_scrollRow:int;
		private var m_viewWidth:int;
		private var m_viewHeight:int;
		private var m_tileWidth:int;
		private var m_tileHeight:int;
		private var m_factor:int;
		private var m_divisor:int;


		public function ScrollTileMap(tileBitmaps:Array, tileWidth:int, tileHeight:int, viewWidth:int, viewHeight:int, numColumns:int, numRows:int, factor:int = 1, transparent:Boolean = false)
		{
			super();
			m_tileBitmaps = tileBitmaps;
			m_tileWidth = tileWidth;
			m_tileHeight = tileHeight;
			m_viewWidth = viewWidth;
			m_viewHeight = viewHeight;
			m_factor = factor;

			m_divisor = 1;
			m_scrollContainer = new Sprite;
			addChild(m_scrollContainer);
			
			m_mapSprites = new Array();

			m_tileMap = new TileMap(
				m_tileWidth,
				m_tileHeight,
				Math.ceil(m_viewWidth / (m_tileWidth * m_factor) + 1) * m_factor,
				Math.ceil(m_viewHeight / (m_tileHeight * m_factor) + 1) * m_factor,
				numColumns,
				numRows,
				m_tileBitmaps,
				transparent);
			
			m_scrollContainer.addChild(m_tileMap);
		}
		
		public function set divisor(divisor:int):void
		{
			m_divisor = divisor;
			var scale:Number = 1 / divisor;
			m_scrollContainer.scaleX = scale;
			m_scrollContainer.scaleY = scale;
			m_tileMap.divisor = divisor;
			m_tileMap.scaleX = divisor;
			m_tileMap.scaleY = divisor;
		}
		
		public function get divisor():int
		{
			return m_divisor;
		}

		public function get tileMap():TileMap
		{
			return m_tileMap;
		}
		
		public function get mapSprites():Array
		{
			return m_mapSprites;
		}

		public function addSprite(mapSprite:MapSprite):void
		{
			m_scrollContainer.addChild(mapSprite);
			m_mapSprites.push(mapSprite);
		}
		
		public function removeSprite(mapSprite:MapSprite):void
		{
			m_scrollContainer.removeChild(mapSprite);
			m_mapSprites.splice(m_mapSprites.indexOf(mapSprite), 1);
		}
		
		public function removeAllSprites():void
		{
			for each (var mapSprite:MapSprite in m_mapSprites)
			{
				m_scrollContainer.removeChild(mapSprite);
			}
			m_mapSprites.length = 0;
		}
		
		public function moveAllSprites(deltaX:Number, deltaY:Number):void
		{
			for each (var mapSprite:MapSprite in m_mapSprites)
			{
				mapSprite.mapX += deltaX;
				mapSprite.mapY += deltaY;
				mapSprite.x += deltaX;
				mapSprite.y += deltaY;
			}
		}
		
		public function sortSpritesBy(sortRules:String):void
		{
			m_mapSprites.sortOn(sortRules, Array.NUMERIC);
			for (var i:int = 0; i < m_mapSprites.length; i++)
			{
				var sprite:Sprite = m_mapSprites[i] as Sprite;
				if (m_scrollContainer.getChildIndex(sprite) != i + 1)
				{
					m_scrollContainer.setChildIndex(sprite, i + 1);
				}
			}
		}
		
		public function get scrollContainer():Sprite
		{
			return m_scrollContainer;
		}
		
		public function setScrollPosition(posX:Number, posY:Number):void
		{
			var containerX:Number = -posX % (m_tileWidth * m_factor);
			var containerY:Number = -posY % (m_tileHeight * m_factor);
			var column:int = Math.floor(posX / (m_tileWidth * m_factor)) * m_factor;
			var row:int = Math.floor(posY / (m_tileHeight * m_factor)) * m_factor;
			if (posX < 0)
			{
				containerX -= (m_tileWidth * m_factor);
			}
			if (posY < 0)
			{
				containerY -= (m_tileHeight * m_factor);
			}
			
			m_scrollContainer.x = Math.round(containerX / m_divisor);
			m_scrollContainer.y = Math.round(containerY / m_divisor);
			
			if (column != m_scrollColumn || row != m_scrollRow)
			{
				m_tileMap.setViewPosition(column, row);
				m_tileMap.draw();
				m_scrollColumn = column;
				m_scrollRow = row;
			}
			
			// map sprites
			for each (var mapSprite:MapSprite in m_mapSprites)
			{
				mapSprite.x = mapSprite.mapX - column * m_tileWidth;
				mapSprite.y = mapSprite.mapY - row * m_tileHeight;
			}
			
			m_scrollX = posX;
			m_scrollY = posY;
		}
		
		public function get scrollX():Number
		{
			return m_scrollX;
		}
		
		public function get scrollY():Number
		{
			return m_scrollY;
		}
		
		public function getColumn(posX:Number):int
		{
			return (posX + m_scrollX / m_divisor) / (m_tileWidth / m_divisor);
		}
		
		public function getRow(posY:Number):int
		{
			return (posY + m_scrollY / m_divisor) / (m_tileHeight / m_divisor);
		}
	}
}