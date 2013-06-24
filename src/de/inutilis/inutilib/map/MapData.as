package de.inutilis.inutilib.map
{
	import flash.utils.ByteArray;

	public class MapData
	{
		protected var m_numColumns:int;
		protected var m_numRows:int;
		protected var m_tiles:Vector.<int>;

		public function MapData(numColumns:int, numRows:int)
		{
			m_numColumns = numColumns;
			m_numRows = numRows;
			
			m_tiles = new Vector.<int>(numColumns * numRows, true);
		}
		
		public function get numColumns():int
		{
			return m_numColumns;
		}
		
		public function get numRows():int
		{
			return m_numRows;
		}

		public function setTile(column:int, row:int, tile:int):void
		{
			var index:int = getTileIndex(column, row);
			if (index >= 0)
			{
				m_tiles[index] = tile;
			}
		}
		
		public function getTile(column:int, row:int):int
		{
			var index:int = getTileIndex(column, row);
			if (index >= 0)
			{
				return m_tiles[index];
			}
			return -1;
		}
		
		public function fillTiles(tile:int):void
		{
			for (var i:int = 0; i < m_tiles.length; i++)
			{
				m_tiles[i] = tile;
			}
		}
		
		public function resize(numColumns:int, numRows:int, borderTile:int = 0, moveColumns:int = 0, moveRows:int = 0):void
		{
			var newTiles:Vector.<int> = new Vector.<int>(numColumns * numRows, true);
			
			for (var row:int = 0; row < numRows; row++)
			{
				for (var column:int = 0; column < numColumns; column++)
				{
					var newIndex:int = (row * numColumns) + column;
					var oldTile:int = getTile(column - moveColumns, row - moveRows);
					newTiles[newIndex] = (oldTile >= 0) ? oldTile : borderTile;
				}
			}
			
			m_tiles = newTiles;
			m_numColumns = numColumns;
			m_numRows = numRows;
		}
		
		protected function getTileIndex(column:int, row:int):int
		{
			if (column < 0 || row < 0 || column >= m_numColumns || row >= m_numRows)
			{
				return -1;
			}
			return (row * m_numColumns) + column;
		}

		//================================================================================
		// Serialization
		//================================================================================
		
		public function serialize(byteArray:ByteArray):void
		{
			byteArray.writeInt(m_numColumns);
			byteArray.writeInt(m_numRows);
			for (var i:int = 0; i < m_tiles.length; i++)
			{
				byteArray.writeInt(m_tiles[i]);
			}
		}
		
		public static function deserialize(byteArray:ByteArray):MapData
		{
			var numColumns:int = byteArray.readInt();
			var numRows:int = byteArray.readInt();
			
			var mapData:MapData = new MapData(numColumns, numRows);
			for (var i:int = 0; i < mapData.m_tiles.length; i++)
			{
				mapData.m_tiles[i] = byteArray.readInt();
			}
			return mapData;
		}

	}
}