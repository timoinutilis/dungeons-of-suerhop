package game.map
{
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	
	import game.GameDefs;
	import game.MagicStone;
	import game.constants.DiscoverTilesDefs;
	import game.constants.RawTilesDefs;
	import game.constants.TilesDefs;
	
	import de.inutilis.inutilib.GameTime;
	import de.inutilis.inutilib.map.MapData;
	import de.inutilis.inutilib.map.MapSprite;
	import de.inutilis.inutilib.map.ScrollTileMap;
	import de.inutilis.inutilib.map.TileMap;
	
	public class GameMap extends Sprite
	{
		public static const k_WALLS_1A:Array = [
			2, 2, 2, TilesDefs.k_FLOOR_1A,
			1, 1, 1, TilesDefs.k_WALL_CORNER_INNER_1A,
			1, 2, 1, TilesDefs.k_WALL_CORNER_INNER_1A,
			2, 1, 2, TilesDefs.k_WALL_CORNER_OUTER_1A,
			1, 1, 2, TilesDefs.k_WALL_V_1A,
			1, 2, 2, TilesDefs.k_WALL_V_TOP_1A,
			2, 1, 1, TilesDefs.k_WALL_H_1A,
			2, 2, 1, TilesDefs.k_WALL_H_1A];

		public static const k_WALLS_1B:Array = [
			2, 2, 2, TilesDefs.k_FLOOR_1B,
			1, 1, 1, TilesDefs.k_WALL_CORNER_INNER_1B,
			1, 2, 1, TilesDefs.k_WALL_CORNER_INNER_1B,
			2, 1, 2, TilesDefs.k_WALL_CORNER_OUTER_1B,
			1, 1, 2, TilesDefs.k_WALL_V_1B,
			1, 2, 2, TilesDefs.k_WALL_V_TOP_1B,
			2, 1, 1, TilesDefs.k_WALL_H_1B,
			2, 2, 1, TilesDefs.k_WALL_H_1B];
		
		public static const k_WALLS_2A:Array = [
			2, 2, 2, TilesDefs.k_FLOOR_2A,
			1, 1, 1, TilesDefs.k_WALL_CORNER_INNER_2A,
			1, 2, 1, TilesDefs.k_WALL_CORNER_INNER_2A,
			2, 1, 2, TilesDefs.k_WALL_CORNER_OUTER_2A,
			1, 1, 2, TilesDefs.k_WALL_V_2A,
			1, 2, 2, TilesDefs.k_WALL_V_2A,
			2, 1, 1, TilesDefs.k_WALL_H_2A,
			2, 2, 1, TilesDefs.k_WALL_H_2A];

		public static const k_WALLS_2B:Array = [
			2, 2, 2, TilesDefs.k_FLOOR_2B,
			1, 1, 1, TilesDefs.k_WALL_CORNER_INNER_2B,
			1, 2, 1, TilesDefs.k_WALL_CORNER_INNER_2B,
			2, 1, 2, TilesDefs.k_WALL_CORNER_OUTER_2B,
			1, 1, 2, TilesDefs.k_WALL_V_2B,
			1, 2, 2, TilesDefs.k_WALL_V_2B,
			2, 1, 1, TilesDefs.k_WALL_H_2B,
			2, 2, 1, TilesDefs.k_WALL_H_2B];
		
		public static const k_DISCOVER:Array = [
			1, 2, 0, 2, 1, 2, 0, 2, DiscoverTilesDefs.k_INNER_5,
			0, 2, 1, 2, 0, 2, 1, 2, DiscoverTilesDefs.k_INNER_6,
			0, 2, 0, 2, 1, 2, 0, 2, DiscoverTilesDefs.k_INNER_1,
			0, 2, 0, 2, 0, 2, 1, 2, DiscoverTilesDefs.k_INNER_2,
			0, 2, 1, 2, 0, 2, 0, 2, DiscoverTilesDefs.k_INNER_3,
			1, 2, 0, 2, 0, 2, 0, 2, DiscoverTilesDefs.k_INNER_4,
			0, 2, 0, 2, 0, 2, 0, 2, DiscoverTilesDefs.k_DISCOVERED,
			0, 1, 0, 2, 0, 2, 1, 2, DiscoverTilesDefs.k_OUTER_1,
			0, 1, 0, 2, 1, 2, 0, 2, DiscoverTilesDefs.k_OUTER_2,
			1, 2, 0, 2, 0, 1, 0, 2, DiscoverTilesDefs.k_OUTER_3,
			0, 2, 0, 1, 0, 2, 1, 2, DiscoverTilesDefs.k_OUTER_4,
			0, 2, 1, 2, 0, 2, 0, 1, DiscoverTilesDefs.k_OUTER_1,
			1, 2, 0, 1, 0, 2, 0, 2, DiscoverTilesDefs.k_OUTER_2,
			0, 2, 0, 2, 1, 2, 0, 1, DiscoverTilesDefs.k_OUTER_3,
			0, 2, 1, 2, 0, 1, 0, 2, DiscoverTilesDefs.k_OUTER_4,
			0, 1, 0, 2, 0, 2, 0, 2, DiscoverTilesDefs.k_SIDE_1,
			0, 2, 0, 2, 0, 1, 0, 2, DiscoverTilesDefs.k_SIDE_2,
			0, 2, 0, 1, 0, 2, 0, 2, DiscoverTilesDefs.k_SIDE_3,
			0, 2, 0, 2, 0, 2, 0, 1, DiscoverTilesDefs.k_SIDE_4,
			0, 1, 0, 2, 0, 2, 0, 1, DiscoverTilesDefs.k_OUTER_1,
			0, 1, 0, 1, 0, 2, 0, 2, DiscoverTilesDefs.k_OUTER_2,
			0, 2, 0, 2, 0, 1, 0, 1, DiscoverTilesDefs.k_OUTER_3,
			0, 2, 0, 1, 0, 1, 0, 2, DiscoverTilesDefs.k_OUTER_4,
		];
		
		public static const k_SIDE_TOP:int = 0;
		public static const k_SIDE_BOTTOM:int = 1;
		public static const k_SIDE_LEFT:int = 2;
		public static const k_SIDE_RIGHT:int = 3;
		
		private var m_mainScrollMap:ScrollTileMap;
		private var m_discoverScrollMap:ScrollTileMap;
		private var m_rawMapData:MapData;
		private var m_tileBitmaps:Array;
		private var m_discoverTileBitmaps:Array;
		private var m_spriteClasses:Array;
		private var m_spritesMap:Object;
		private var m_mainCharacter:MainCharacter;
		private var m_editMode:Boolean;
		private var m_onChangeFunction:Function;
		private var m_scrollTargetX:Number = 0;
		private var m_scrollTargetY:Number = 0;
		private var m_scrollingCFT:int;
		private var m_messages:Object;
		private var m_changed:Boolean;

		
		public function GameMap(tileBitmaps:Array, discoverTileBitmaps:Array, spriteClasses:Array, editMode:Boolean)
		{
			m_tileBitmaps = tileBitmaps;
			m_discoverTileBitmaps = discoverTileBitmaps;
			m_spriteClasses = spriteClasses;
			m_editMode = editMode;
			
			m_spritesMap = new Object();
			m_messages = new Object();
		}
		
		public function get changed():Boolean
		{
			return m_changed;
		}
		
		public function setChanged():void
		{
			m_changed = true;
		}
		
		public function unsetChanged():void
		{
			m_changed = false;
		}
		
		public function addSize(side:int, value:int):void
		{
			var newRawColumns:int = numRawColumns;
			var newRawRows:int = numRawRows;
			var moveColumns:int = 0;
			var moveRows:int = 0;
			var deltaX:Number = 0;
			var deltaY:Number = 0;
			
			switch (side)
			{
				case k_SIDE_TOP:
					newRawRows += value;
					moveRows = value;
					deltaY = value * 2 * GameDefs.k_TILE_HEIGHT;
					break;
				
				case k_SIDE_BOTTOM:
					newRawRows += value;
					break;
				
				case k_SIDE_LEFT:
					newRawColumns += value;
					moveColumns = value;
					deltaX = value * 2 * GameDefs.k_TILE_WIDTH;
					break;

				case k_SIDE_RIGHT:
					newRawColumns += value;
					break;
			}
			
			m_rawMapData.resize(newRawColumns, newRawRows, RawTilesDefs.k_EARTH, moveColumns, moveRows);
			m_mainScrollMap.tileMap.mapData.resize(newRawColumns * 2, newRawRows * 2, 0, moveColumns * 2, moveRows * 2);
			calculateTileMap(0, 0, newRawColumns * 2, newRawRows * 2);
			m_mainScrollMap.tileMap.draw();
			
			refreshMessagesFromSprites();
			clearSprites();
			makeSprites();
			
			setScrollPosition(m_mainScrollMap.scrollX + deltaX, m_mainScrollMap.scrollY + deltaY);
			
			setChanged();
		}
		
		public function set divisor(divisor:int):void
		{
			m_mainScrollMap.divisor = divisor;
			if (m_discoverScrollMap != null)
			{
				m_discoverScrollMap.divisor = divisor;
			}
		}
		
		public function get divisor():int
		{
			return m_mainScrollMap.divisor;
		}
		
		private function makeMessageTexts(messages:String):void
		{
			m_messages = new Object();
			if (messages != null)
			{
				var parts:Array = messages.split("|");
				for each (var part:String in parts)
				{
					var divPos:int = part.indexOf(":");
					var pos:String = part.substring(0, divPos);
					var text:String = part.substr(divPos + 1);
					m_messages[pos] = text;
				}
			}
		}
		
		private function refreshMessagesFromSprites():void
		{
			m_messages = new Object();
			for each (var sprite:GameSprite in m_mainScrollMap.mapSprites)
			{
				if (sprite is Message)
				{
					var messageSprite:Message = sprite as Message;
					var pos:String = messageSprite.rawColumn + "," + messageSprite.rawRow;
					m_messages[pos] = messageSprite.text;
				}
			}
		}
		
		public function getMessages():String
		{
			refreshMessagesFromSprites();
			
			var messages:String = "";
			for (var pos:Object in m_messages) 
			{
				if (messages.length > 0)
				{
					messages += "|";
				}
				messages += pos + ":" + m_messages[pos];
			}
			return messages;
		}
		
		private function makeMap():Boolean
		{
			m_mainScrollMap = new ScrollTileMap(m_tileBitmaps,
				GameDefs.k_TILE_WIDTH, GameDefs.k_TILE_HEIGHT,
				MagicStone.bgContainer.stage.stageWidth,
				MagicStone.bgContainer.stage.stageHeight,
				m_rawMapData.numColumns * 2, m_rawMapData.numRows * 2, 2);
			
			addChild(m_mainScrollMap);

			var mapOk:Boolean = calculateTileMap(0, 0, m_mainScrollMap.tileMap.mapData.numColumns, m_mainScrollMap.tileMap.mapData.numRows);
			m_mainScrollMap.tileMap.draw();
			
			var spritesOk:Boolean = makeSprites();
			
			if (m_discoverTileBitmaps != null)
			{
				m_discoverScrollMap = new ScrollTileMap(m_discoverTileBitmaps,
					GameDefs.k_DISCOVER_TILE_WIDTH, GameDefs.k_DISCOVER_TILE_HEIGHT,
					MagicStone.bgContainer.stage.stageWidth,
					MagicStone.bgContainer.stage.stageHeight,
					m_rawMapData.numColumns, m_rawMapData.numRows, 1,
					true);
				
				addChild(m_discoverScrollMap);
				
				calculateDiscoverTileMap(0, 0, m_rawMapData.numColumns, m_rawMapData.numRows);
				m_discoverScrollMap.tileMap.draw();
			}
			
			return mapOk && spritesOk;
		}
		
		private function makeSprites():Boolean
		{
			for (var row:int = 0; row < m_rawMapData.numRows; row++)
			{
				for (var column:int = 0; column < m_rawMapData.numColumns; column++)
				{
					var tileObject:int = m_rawMapData.getTile(column, row) & RawTilesDefs.k_MASK_OBJECT;
					if (tileObject != 0)
					{
						var sprite:GameSprite = null;

						switch (tileObject)
						{
							case RawTilesDefs.k_DOOR:
								sprite = new Door(this, false);
								break;
							
							case RawTilesDefs.k_DOOR_OPEN:
								sprite = new Door(this, true);
								break;

							case RawTilesDefs.k_KEY:
								sprite = new Key(this);
								break;
							
							case RawTilesDefs.k_MAGIC_STONE:
								sprite = new MapMagicStone(this);
								break;
							
							case RawTilesDefs.k_MAIN_CHARACTER:
								sprite = new MainCharacter(this);
								break;
							
							case RawTilesDefs.k_SHOP_ARMOR:
								sprite = new Shop(this, Shop.k_ARMOR);
								break;
							
							case RawTilesDefs.k_SHOP_SHIELD:
								sprite = new Shop(this, Shop.k_SHIELD);
								break;
							
							case RawTilesDefs.k_SHOP_WEAPON:
								sprite = new Shop(this, Shop.k_WEAPON);
								break;
							
							case RawTilesDefs.k_TREASURE:
								sprite = new Treasure(this);
								break;
							
							case RawTilesDefs.k_POTION:
								sprite = new Potion(this);
								break;

							case RawTilesDefs.k_ENEMY_1:
								sprite = new Enemy(this, 0, m_editMode);
								break;
							
							case RawTilesDefs.k_ENEMY_2:
								sprite = new Enemy(this, 1, m_editMode);
								break;
							
							case RawTilesDefs.k_ENEMY_3:
								sprite = new Enemy(this, 2, m_editMode);
								break;
							
							case RawTilesDefs.k_ENEMY_4:
								sprite = new Enemy(this, 3, m_editMode);
								break;
							
							case RawTilesDefs.k_ENEMY_5:
								sprite = new Enemy(this, 4, m_editMode);
								break;
							
							case RawTilesDefs.k_ENEMY_6:
								sprite = new Enemy(this, 5, m_editMode);
								break;
							
							case RawTilesDefs.k_ENEMY_7:
								sprite = new Enemy(this, 6, m_editMode);
								break;
							
							case RawTilesDefs.k_ENEMY_8:
								sprite = new Enemy(this, 7, m_editMode);
								break;
							
							case RawTilesDefs.k_ENEMY_9:
								sprite = new Enemy(this, 8, m_editMode);
								break;
							
							case RawTilesDefs.k_ENEMY_10:
								sprite = new Enemy(this, 9, m_editMode);
								break;
							
							case RawTilesDefs.k_GEMSTONES:
								sprite = new Gemstones(this);
								break;
							
							case RawTilesDefs.k_DOOR_COLORS_1:
								sprite = new DoorColors(this, false, 0, m_editMode);
								break;

							case RawTilesDefs.k_DOOR_COLORS_OPEN_1:
								sprite = new DoorColors(this, true, 0, m_editMode);
								break;
							
							case RawTilesDefs.k_DOOR_COLORS_2:
								sprite = new DoorColors(this, false, 1, m_editMode);
								break;
							
							case RawTilesDefs.k_DOOR_COLORS_OPEN_2:
								sprite = new DoorColors(this, true, 1, m_editMode);
								break;
							
							case RawTilesDefs.k_DOOR_COLORS_3:
								sprite = new DoorColors(this, false, 2, m_editMode);
								break;
							
							case RawTilesDefs.k_DOOR_COLORS_OPEN_3:
								sprite = new DoorColors(this, true, 2, m_editMode);
								break;
							
							case RawTilesDefs.k_DOOR_COLORS_4:
								sprite = new DoorColors(this, false, 3, m_editMode);
								break;
							
							case RawTilesDefs.k_DOOR_COLORS_OPEN_4:
								sprite = new DoorColors(this, true, 3, m_editMode);
								break;
							
							case RawTilesDefs.k_DOOR_BUTTON_1:
								sprite = new DoorButton(this, 0);
								break;
							
							case RawTilesDefs.k_DOOR_BUTTON_2:
								sprite = new DoorButton(this, 1);
								break;
							
							case RawTilesDefs.k_DOOR_BUTTON_3:
								sprite = new DoorButton(this, 2);
								break;
							
							case RawTilesDefs.k_DOOR_BUTTON_4:
								sprite = new DoorButton(this, 3);
								break;
							
							case RawTilesDefs.k_MESSAGE:
								sprite = new Message(this, m_messages[column + "," + row], m_editMode);
								break;
							
							case RawTilesDefs.k_CROSS:
								sprite = new Cross(this);
								break;

							case RawTilesDefs.k_BROKEN_FLOOR:
								sprite = new BrokenFloor(this, BrokenFloor.k_STATE_ONE_TIME_SAFE, m_editMode);
								break;
							
							case RawTilesDefs.k_BROKEN_FLOOR_2_GOOD:
								sprite = new BrokenFloor(this, BrokenFloor.k_STATE_GOOD, m_editMode);
								break;
							
							case RawTilesDefs.k_BROKEN_FLOOR_2_BAD:
								sprite = new BrokenFloor(this, BrokenFloor.k_STATE_BAD, m_editMode);
								break;
							
							case RawTilesDefs.k_HOLE:
								sprite = new BrokenFloor(this, BrokenFloor.k_STATE_HOLE, m_editMode);
								break;
							
							default:
								// unknown object
								return false;
						}
						sprite.setRawPosition(column, row);
						putSpriteOnMap(sprite, false);
					}
				}
			}
			return true;
		}
		
		private function clearSprites():void
		{
			m_mainScrollMap.removeAllSprites();
			m_spritesMap = new Object();
		}
		
		public function get mainScrollMap():ScrollTileMap
		{
			return m_mainScrollMap;
		}
		
		public function calculateUnlockLevel():int
		{
			var unlockLevel:int = 0;
			for each (var sprite:GameSprite in m_mainScrollMap.mapSprites)
			{
				if (sprite.getUnlockLevel() > unlockLevel)
				{
					unlockLevel = sprite.getUnlockLevel();
				}
			}
			return unlockLevel;
		}
		
		//================================================================================
		// Scrolling
		//================================================================================

		public function get scrollTargetX():Number
		{
			return m_scrollTargetX;
		}
		
		public function get scrollTargetY():Number
		{
			return m_scrollTargetY;
		}
		
		public function setScrollTarget(posX:Number, posY:Number):void
		{
			m_scrollTargetX = posX;
			m_scrollTargetY = posY;
		}
		
		public function setScrollPosition(posX:Number, posY:Number):void
		{
			setScrollTarget(posX, posY);
			m_mainScrollMap.setScrollPosition(posX, posY);
			if (m_discoverScrollMap != null)
			{
				m_discoverScrollMap.setScrollPosition(posX, posY);
			}
		}

		public function updateScrolling():void
		{
			var posX:Number = m_mainScrollMap.scrollX;
			var posY:Number = m_mainScrollMap.scrollY;
			
			m_scrollingCFT += GameTime.frameMillis;
			var updateTime:int = 500 / stage.frameRate; // twice per frame
			while (m_scrollingCFT > updateTime)
			{
				if (posX != m_scrollTargetX)
				{
					posX = m_mainScrollMap.scrollX * 0.9 + m_scrollTargetX * 0.1;
				}
				
				if (posY != m_scrollTargetY)
				{
					posY = m_mainScrollMap.scrollY * 0.9 + m_scrollTargetY * 0.1;
				}
				
				m_scrollingCFT -= updateTime;
			}
			
			m_mainScrollMap.setScrollPosition(posX, posY);
			if (m_discoverScrollMap != null)
			{
				m_discoverScrollMap.setScrollPosition(posX, posY);
			}
		}
		
		public function refreshSpritePositions():void
		{
			m_mainScrollMap.setScrollPosition(m_mainScrollMap.scrollX, m_mainScrollMap.scrollY);			
		}

		//================================================================================
		// Raw Map
		//================================================================================
		
		public function get numRawColumns():int
		{
			return m_rawMapData.numColumns;
		}

		public function get numRawRows():int
		{
			return m_rawMapData.numRows;
		}

		public function getRawColumn(posX:Number):int
		{
			return m_mainScrollMap.getColumn(posX) / 2;
		}

		public function getRawRow(posY:Number):int
		{
			return m_mainScrollMap.getRow(posY) / 2;
		}
		
		public function getRawTile(rawColumn:int, rawRow:int):int
		{
			return m_rawMapData.getTile(rawColumn, rawRow);
		}
		
		public function setRawTile(rawColumn:int, rawRow:int, rawTile:int, keepObject:Boolean):void
		{
			var newRawTile:int = rawTile;
			if (keepObject)
			{
				var oldRawTile:int = m_rawMapData.getTile(rawColumn, rawRow);
				newRawTile = (oldRawTile & RawTilesDefs.k_MASK_OBJECT) | rawTile;
			}
			m_rawMapData.setTile(rawColumn, rawRow, newRawTile);
			
			var column:int = rawColumn * 2 - 1;
			var row:int = rawRow * 2 - 1;
			
			calculateTileMap(column, row, 4, 4);
			m_mainScrollMap.tileMap.drawArea(column, row, 4, 4);
			
			setChanged();
		}
		
		public function calculateTileMap(column:int, row:int, numColumns:int, numRows:int):Boolean
		{
			for (var currRow:int = row; currRow < row + numRows; currRow++)
			{
				var rawRow:int = currRow / 2;
				var tilePartRow:int = currRow % 2;

				for (var currColumn:int = column; currColumn < column + numColumns; currColumn++)
				{
					var rawColumn:int = currColumn / 2;
					var tilePartColumn:int = currColumn % 2;
					
					var rawTile:int = m_rawMapData.getTile(rawColumn, rawRow) & RawTilesDefs.k_MASK_TILE;
					var tile:int = TilesDefs.k_EARTH_1A;
					switch (rawTile)
					{
						case RawTilesDefs.k_EARTH:
						case RawTilesDefs.k_SECRET:
							if (m_editMode && rawTile == RawTilesDefs.k_SECRET)
							{
								tile = TilesDefs.k_SECRET_1A + tilePartColumn + (tilePartRow * 2);
							}
							else
							{
								tile = TilesDefs.k_EARTH_1A + tilePartColumn + (tilePartRow * 2);
							}	
							break;
						
						case RawTilesDefs.k_FLOOR:
							if (tilePartColumn == 0)
							{
								if (tilePartRow == 0)
								{
									tile = getFloorTile(m_rawMapData.getTile(rawColumn - 1, rawRow), m_rawMapData.getTile(rawColumn - 1, rawRow - 1), m_rawMapData.getTile(rawColumn, rawRow - 1), k_WALLS_1A);
								}
								else
								{
									tile = getFloorTile(m_rawMapData.getTile(rawColumn - 1, rawRow), m_rawMapData.getTile(rawColumn - 1, rawRow + 1), m_rawMapData.getTile(rawColumn, rawRow + 1), k_WALLS_2A);
								}
							}
							else
							{
								if (tilePartRow == 0)
								{
									tile = getFloorTile(m_rawMapData.getTile(rawColumn + 1, rawRow), m_rawMapData.getTile(rawColumn + 1, rawRow - 1), m_rawMapData.getTile(rawColumn, rawRow - 1), k_WALLS_1B);
								}
								else
								{
									tile = getFloorTile(m_rawMapData.getTile(rawColumn + 1, rawRow), m_rawMapData.getTile(rawColumn + 1, rawRow + 1), m_rawMapData.getTile(rawColumn, rawRow + 1), k_WALLS_2B);
								}
							}
							break;
						
						default:
							return false;
					}

					m_mainScrollMap.tileMap.mapData.setTile(currColumn, currRow, tile);
				}
			}
			return true;
		}
		
		private function getFloorTile(rawTile1:int, rawTile2:int, rawTile3:int, walls:Array):int
		{
			rawTile1 &= RawTilesDefs.k_MASK_TILE;
			rawTile2 &= RawTilesDefs.k_MASK_TILE;
			rawTile3 &= RawTilesDefs.k_MASK_TILE;
			
			// secret to normal earth
			if (rawTile1 == 3) rawTile1 = 1;
			if (rawTile2 == 3) rawTile2 = 1;
			if (rawTile3 == 3) rawTile3 = 1;
			
			// check tiles
			for (var i:int = 0; i < walls.length; i += 4)
			{
				if (   walls[i] == rawTile1
					&& walls[i + 1] == rawTile2
					&& walls[i + 2] == rawTile3 )
				{
					return walls[i + 3];
				}
			}
			return 0;
		}

		//================================================================================
		// Discover Map
		//================================================================================

		public function calculateDiscoverTileMap(rawColumn:int, rawRow:int, numColumns:int, numRows:int):void
		{
			for (var currRow:int = rawRow; currRow < rawRow + numRows; currRow++)
			{
				for (var currColumn:int = rawColumn; currColumn < rawColumn + numColumns; currColumn++)
				{
					var discovered:Boolean = (m_rawMapData.getTile(currColumn, currRow) & RawTilesDefs.k_DISCOVERED) != 0;
					
					var tile:int = DiscoverTilesDefs.k_FULL;
					if (discovered)
					{
						tile = getDiscoverTile(
							m_rawMapData.getTile(currColumn - 1, currRow - 1),
							m_rawMapData.getTile(currColumn, currRow - 1),
							m_rawMapData.getTile(currColumn + 1, currRow - 1),
							m_rawMapData.getTile(currColumn + 1, currRow),
							m_rawMapData.getTile(currColumn + 1, currRow + 1),
							m_rawMapData.getTile(currColumn, currRow + 1),
							m_rawMapData.getTile(currColumn - 1, currRow + 1),
							m_rawMapData.getTile(currColumn - 1, currRow));
					}
					
					m_discoverScrollMap.tileMap.mapData.setTile(currColumn, currRow, tile);
				}
			}
		}
		
		private function getDiscoverTile(rawTile1:int, rawTile2:int, rawTile3:int, rawTile4:int, rawTile5:int, rawTile6:int, rawTile7:int, rawTile8:int):int
		{
			rawTile1 = ((rawTile1 & RawTilesDefs.k_DISCOVERED) == 0 || rawTile1 == -1) ? 1 : 2;
			rawTile2 = ((rawTile2 & RawTilesDefs.k_DISCOVERED) == 0 || rawTile2 == -1) ? 1 : 2;
			rawTile3 = ((rawTile3 & RawTilesDefs.k_DISCOVERED) == 0 || rawTile3 == -1) ? 1 : 2;
			rawTile4 = ((rawTile4 & RawTilesDefs.k_DISCOVERED) == 0 || rawTile4 == -1) ? 1 : 2;
			rawTile5 = ((rawTile5 & RawTilesDefs.k_DISCOVERED) == 0 || rawTile5 == -1) ? 1 : 2;
			rawTile6 = ((rawTile6 & RawTilesDefs.k_DISCOVERED) == 0 || rawTile6 == -1) ? 1 : 2;
			rawTile7 = ((rawTile7 & RawTilesDefs.k_DISCOVERED) == 0 || rawTile7 == -1) ? 1 : 2;
			rawTile8 = ((rawTile8 & RawTilesDefs.k_DISCOVERED) == 0 || rawTile8 == -1) ? 1 : 2;
			
			// check tiles
			for (var i:int = 0; i < k_DISCOVER.length; i += 9)
			{
				if (   (k_DISCOVER[i + 1] == 0 || k_DISCOVER[i + 1] == rawTile2)
					&& (k_DISCOVER[i + 3] == 0 || k_DISCOVER[i + 3] == rawTile4)
					&& (k_DISCOVER[i + 5] == 0 || k_DISCOVER[i + 5] == rawTile6)
					&& (k_DISCOVER[i + 7] == 0 || k_DISCOVER[i + 7] == rawTile8)
					&& (k_DISCOVER[i] == 0 || k_DISCOVER[i] == rawTile1)
					&& (k_DISCOVER[i + 2] == 0 || k_DISCOVER[i + 2] == rawTile3)
					&& (k_DISCOVER[i + 4] == 0 || k_DISCOVER[i + 4] == rawTile5)
					&& (k_DISCOVER[i + 6] == 0 || k_DISCOVER[i + 6] == rawTile7) )
				{
					return k_DISCOVER[i + 8];
				}
			}
			return 0;
		}
		
		public function discover(rawColumn:int, rawRow:int):void
		{
			for (var currRow:int = rawRow - 1; currRow <= rawRow + 1; currRow++)
			{
				for (var currColumn:int = rawColumn - 1; currColumn <= rawColumn + 1; currColumn++)
				{
					var tile:int = m_rawMapData.getTile(currColumn, currRow);
					m_rawMapData.setTile(currColumn, currRow, tile | RawTilesDefs.k_DISCOVERED);
				}
			}
			calculateDiscoverTileMap(rawColumn - 2, rawRow - 2, 5, 5);
			m_discoverScrollMap.tileMap.drawArea(rawColumn - 2, rawRow - 2, 5, 5);
		}
		
		//================================================================================
		// GameSprites
		//================================================================================
		
		public function get spriteClasses():Array
		{
			return m_spriteClasses;
		}

		public function setRawTileObject(rawColumn:int, rawRow:int, rawTile:int):void
		{
			var oldRawTile:int = m_rawMapData.getTile(rawColumn, rawRow);
			var newRawTile:int = (oldRawTile & ~RawTilesDefs.k_MASK_OBJECT) | rawTile;
			m_rawMapData.setTile(rawColumn, rawRow, newRawTile);
			setChanged();
		}
		
		public function putSpriteOnMap(gameSprite:GameSprite, modifyRawMap:Boolean):void
		{
			if (modifyRawMap)
			{
				setRawTileObject(gameSprite.rawColumn, gameSprite.rawRow, gameSprite.rawTile);
			}
			m_mainScrollMap.addSprite(gameSprite);
			gameSprite.onPutOnMap();
			m_spritesMap[gameSprite.rawColumn + "," + gameSprite.rawRow] = gameSprite;
			
			if (gameSprite is MainCharacter)
			{
				m_mainCharacter = gameSprite as MainCharacter;
			}
		}
		
		public function removeSpriteFromMap(gameSprite:GameSprite, modifyRawMap:Boolean):void
		{
			if (modifyRawMap)
			{
				setRawTileObject(gameSprite.rawColumn, gameSprite.rawRow, 0);
			}
			m_mainScrollMap.removeSprite(gameSprite);
			delete m_spritesMap[gameSprite.rawColumn + "," + gameSprite.rawRow];
		}
		
		public function getSpriteFromMap(rawColumn:int, rawRow:int):GameSprite
		{
			var key:String = rawColumn + "," + rawRow;
			if (m_spritesMap.hasOwnProperty(key))
			{
				return m_spritesMap[key] as GameSprite;
			}
			return null;
		}
		
		public function get mainCharacter():MainCharacter
		{
			return m_mainCharacter;
		}
		
		public function updateGameSprites():void
		{
			for each (var sprite:GameSprite in m_mainScrollMap.mapSprites)
			{
				sprite.update();
			}
			m_mainScrollMap.sortSpritesBy("m_zOrder");
		}
		
		//================================================================================
		// Serialization
		//================================================================================

		public function serialize(byteArray:ByteArray):void
		{
			m_rawMapData.serialize(byteArray);
		}

		public static function deserialize(byteArray:ByteArray, messages:String, tileBitmaps:Array, discoverTileBitmaps:Array, spriteClasses:Array, editMode:Boolean):GameMap
		{
			var gameMap:GameMap = new GameMap(tileBitmaps, discoverTileBitmaps, spriteClasses, editMode);
			gameMap.m_rawMapData = MapData.deserialize(byteArray);
			gameMap.makeMessageTexts(messages);
			if (gameMap.makeMap())
			{
				return gameMap;
			}
			return null;
		}
		
		//================================================================================
		// More Creators
		//================================================================================

		public static function createEmptyMap(numRawColumns:int, numRawRows:int, fillTile:int, tileBitmaps:Array, spriteClasses:Array, editMode:Boolean):GameMap
		{
			var gameMap:GameMap = new GameMap(tileBitmaps, null, spriteClasses, editMode);
			gameMap.m_rawMapData = new MapData(numRawColumns, numRawRows);
			gameMap.m_rawMapData.fillTiles(fillTile);
			gameMap.makeMap();
			return gameMap;
		}

	}
}