package game.map
{
	import game.constants.RawTilesDefs;
	import game.ui.PopupWindow;
	
	import mx.resources.ResourceManager;

	public class EditMapUtils
	{
		private var m_gameMap:GameMap;
		
		public function EditMapUtils(gameMap:GameMap)
		{
			m_gameMap = gameMap;
		}
		
		public function checkMapValidity(excludeObject:GameSprite):Boolean
		{
			var positionsValid:Boolean = true;
			var hasMainCharacter:Boolean = false;
			var hasMagicStone:Boolean = false;
			var firstProblem:String = null;
			
			for each (var gameSprite:GameSprite in m_gameMap.mainScrollMap.mapSprites)
			{
				if (gameSprite != excludeObject)
				{
					if (!gameSprite.isPositionValid())
					{
						positionsValid = false;
					}
					if (gameSprite.rawTile == RawTilesDefs.k_MAIN_CHARACTER)
					{
						hasMainCharacter = true;
					}
					if (gameSprite.rawTile == RawTilesDefs.k_MAGIC_STONE)
					{
						hasMagicStone = true;
					}
					if (firstProblem == null)
					{
						firstProblem = gameSprite.getProblem();
					}
				}
			}
			
			var errorText:String = null;
			if (!hasMainCharacter)
			{
				errorText = ResourceManager.getInstance().getString("default", "textNoMainCharacter");
			}
			else if (!hasMagicStone)
			{
				errorText = ResourceManager.getInstance().getString("default", "textNoMagicStone");
			}
			else if (!positionsValid)
			{
				errorText = ResourceManager.getInstance().getString("default", "textInvalidPositions");
			}
			else if (firstProblem != null)
			{
				errorText = firstProblem;
			}
			
			if (errorText != null)
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, errorText);
				popup.open();
				return false;
			}
			return true;
		}
		
		public function countNeighbors(rawColumn:int, rawRow:int, rawTile:int, mask:int):int
		{
			var checked:Object = new Object();
			return countNeighborsAround(rawColumn, rawRow, rawTile, mask, checked, true);
		}
		
		private function countNeighborsAround(rawColumn:int, rawRow:int, rawTile:int, mask:int, checked:Object, isFirst:Boolean = false):int
		{
			var count:int = 0;
			var key:String = rawColumn + "," + rawRow;
			if (   rawColumn >= 0 && rawRow >= 0 && rawColumn < m_gameMap.numRawColumns && rawRow < m_gameMap.numRawRows
				&& !checked[key]
				&& (isFirst || (m_gameMap.getRawTile(rawColumn, rawRow) & mask) == rawTile) )
			{
				checked[key] = true;
				count = 1;
				count += countNeighborsAround(rawColumn - 1, rawRow, rawTile, mask, checked);
				count += countNeighborsAround(rawColumn + 1, rawRow, rawTile, mask, checked);
				count += countNeighborsAround(rawColumn, rawRow - 1, rawTile, mask, checked);
				count += countNeighborsAround(rawColumn, rawRow + 1, rawTile, mask, checked);
				count += countNeighborsAround(rawColumn - 1, rawRow - 1, rawTile, mask, checked);
				count += countNeighborsAround(rawColumn + 1, rawRow + 1, rawTile, mask, checked);
				count += countNeighborsAround(rawColumn + 1, rawRow - 1, rawTile, mask, checked);
				count += countNeighborsAround(rawColumn - 1, rawRow + 1, rawTile, mask, checked);
			}
			return count;
		}
		
	}
}