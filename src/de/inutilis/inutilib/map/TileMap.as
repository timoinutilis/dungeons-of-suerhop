package de.inutilis.inutilib.map
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class TileMap extends Bitmap
	{
		private var m_tileWidth:int;
		private var m_tileHeight:int;
		private var m_numViewColumns:int;
		private var m_numViewRows:int;
		private var m_tileBitmaps:Array;
		private var m_viewColumn:int;
		private var m_viewRow:int;
		private var m_mapData:MapData;
		private var m_outsideColor:uint;
		private var m_transparent:Boolean;
		private var m_divisor:int;

		
		public function TileMap(tileWidth:int, tileHeight:int, numViewColumns:int, numViewRows:int, numColumns:int, numRows:int, tileBitmaps:Array, transparent:Boolean = false)
		{
			m_tileWidth = tileWidth;
			m_tileHeight = tileHeight;
			m_numViewColumns = numViewColumns;
			m_numViewRows = numViewRows;
			m_tileBitmaps = tileBitmaps;
			m_transparent = transparent;
			
			m_divisor = 1;
			m_mapData = new MapData(numColumns, numRows);

			var bitmapData:BitmapData = new BitmapData(tileWidth * numViewColumns, tileHeight * numViewRows, transparent);
			super(bitmapData);
		}
		
		public function get mapData():MapData
		{
			return m_mapData;
		}
		
		public function set outsideColor(color:uint):void
		{
			m_outsideColor = color;
		}
		
		public function set divisor(divisor:int):void
		{
			m_divisor = divisor;
			draw();
		}
		
		public function get divisor():int
		{
			return m_divisor;
		}

		public function setViewPosition(column:int, row:int):void
		{
			m_viewColumn = column;
			m_viewRow = row;
		}
		
		public function get mapWidth():int
		{
			return m_mapData.numColumns * m_tileWidth;
		}
		
		public function get mapHeight():int
		{
			return m_mapData.numRows * m_tileHeight;
		}

		public function draw():void
		{
			drawArea(m_viewColumn, m_viewRow, m_numViewColumns * m_divisor, m_numViewRows * m_divisor);
		}
		
		public function drawArea(column:int, row:int, numColumns:int, numRows:int):void
		{
			var matrix:Matrix = new Matrix();
			var rect:Rectangle = new Rectangle(0, 0, m_tileWidth / m_divisor, m_tileHeight / m_divisor);
			matrix.scale(1 / m_divisor, 1 / m_divisor);
			
			var numViewColumns:int = m_numViewColumns * m_divisor;
			var numViewRows:int = m_numViewRows * m_divisor;
			
			for (var currRow:int = row; currRow < row + numRows; currRow++)
			{
				for (var currColumn:int = column; currColumn < column + numColumns; currColumn++)
				{
					var viewColumn:int = currColumn - m_viewColumn;
					var viewRow:int = currRow - m_viewRow;
					var tile:int = m_mapData.getTile(currColumn, currRow);
					rect.x = viewColumn * m_tileWidth / m_divisor;
					rect.y = viewRow * m_tileHeight / m_divisor;
					if (tile > 0)
					{
						if (viewColumn >= 0 && viewRow >= 0 && viewColumn < numViewColumns && viewRow < numViewRows)
						{
							matrix.tx = rect.x;
							matrix.ty = rect.y;
							if (m_transparent)
							{
								// clear
								bitmapData.fillRect(rect, 0x00000000);
							}
							// draw
							var tileBitmap:BitmapData = m_tileBitmaps[tile] as BitmapData;
							bitmapData.draw(tileBitmap, matrix);
						}
					}
					else if (tile == 0)
					{
						// empty
						bitmapData.fillRect(rect, 0x00000000);
					}
					else
					{
						// outside
						bitmapData.fillRect(rect, m_outsideColor);
					}
				}
			}
		}
				
	}
}