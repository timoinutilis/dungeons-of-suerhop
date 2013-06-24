package game.states
{
	import com.adobe.utils.StringUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import flashx.textLayout.elements.BreakElement;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	import game.constants.RawTilesDefs;
	import game.map.BrokenFloor;
	import game.map.Cross;
	import game.map.Door;
	import game.map.DoorButton;
	import game.map.DoorColors;
	import game.map.EditMapUtils;
	import game.map.Enemy;
	import game.map.GameMap;
	import game.map.GameSprite;
	import game.map.Gemstones;
	import game.map.Key;
	import game.map.MainCharacter;
	import game.map.MapMagicStone;
	import game.map.Message;
	import game.map.Potion;
	import game.map.Shop;
	import game.map.TilePreview;
	import game.map.Treasure;
	import game.server.GameServer;
	import game.server.answers.Answer;
	import game.ui.EditorToolsWindow;
	import game.ui.ExpandButtonsWindow;
	import game.ui.HelpWindow;
	import game.ui.PopupWindow;
	import game.ui.TextInputWindow;
	import game.ui.TutorialOverlayWindow;
	import game.value.MapInfo;
	
	import de.inutilis.inutilib.MathUtils;
	import de.inutilis.inutilib.map.IDImagesLoader;
	import de.inutilis.inutilib.map.MapSprite;
	import de.inutilis.inutilib.map.ScrollTileMap;
	import de.inutilis.inutilib.media.ImageManager;
	import de.inutilis.inutilib.media.MusicPlayer;
	import de.inutilis.inutilib.media.SoundManager;
	import de.inutilis.inutilib.social.SocialUserManager;
	import de.inutilis.inutilib.statemachine.State;
	import de.inutilis.inutilib.statemachine.StateMachine;
	import de.inutilis.inutilib.ui.Fader;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.RadioButtons;
	import de.inutilis.inutilib.ui.SplashScreen;
	import de.inutilis.inutilib.ui.ToolTips;
	import de.inutilis.inutilib.ui.Window;
	import de.inutilis.inutilib.ui.WindowEvent;
	import de.inutilis.inutilib.ui.WindowManager;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	public class MapEditorState extends State
	{
		[Embed(source = "../../../embed/ui_editor_tools.swf", symbol="UIEditorControl")]
		private var UIEditorControl:Class;
		
		[Embed(source = "../../../embed/ui_object.swf", symbol="DeleteGui")]
		private var DeleteGui:Class;

		private static const k_AFTER_SAVE_NOTHING:int = 0;
		private static const k_AFTER_SAVE_RETURN:int = 1;
		private static const k_AFTER_SAVE_PLAY:int = 2;
				
		private var m_tilesLoader:IDImagesLoader;
		private var m_spritesLoader:IDImagesLoader;
		private var m_levelData:ByteArray;
		private var m_levelMessages:String;
		
		private var m_gameMap:GameMap;
		private var m_controlWindow:Window;
		private var m_toolsWindow:EditorToolsWindow;
		private var m_expandButtonsWindow:ExpandButtonsWindow;
		private var m_fader:Fader;
		private var m_savePopup:PopupWindow;
		private var m_nameInputWindow:TextInputWindow;
		private var m_toolTipsControl:ToolTips;
		private var m_helpGlow:MovieClip;

		private var m_currentRawTile:int;
		private var m_isMouseDown:Boolean;
		private var m_lastRawColumn:int;
		private var m_lastRawRow:int;
		
		private var m_currentObject:GameSprite;
		private var m_draggingObject:GameSprite;
		private var m_isDragging:Boolean;
		private var m_deleteGui:Sprite;
		private var m_tutorialWindow:TutorialOverlayWindow;
		private var m_utils:EditMapUtils;
		
		private var m_mapInfo:MapInfo;
		private var m_doAfterSave:int;
		
		private var m_onMouseUpMessage:String;
		
		public function MapEditorState(stateMachine:StateMachine, tilesLoader:IDImagesLoader, spritesLoader:IDImagesLoader, levelData:ByteArray, levelMessages:String, mapInfo:MapInfo)
		{
			super(stateMachine);
			m_tilesLoader = tilesLoader;
			m_spritesLoader = spritesLoader;
			m_levelData = levelData;
			m_levelMessages = levelMessages;
			if (mapInfo != null)
			{
				m_mapInfo = mapInfo;
			}
			else
			{
				m_mapInfo = new MapInfo();
				m_mapInfo.userId = SocialUserManager.instance.playerUserId;
				m_mapInfo.name = "";
			}
		}
		
		override public function start():void
		{
			var centerX:Number;
			var centerY:Number;
			if (m_levelData != null)
			{
				m_gameMap = GameMap.deserialize(m_levelData, m_levelMessages, m_tilesLoader.bitmaps, null, m_spritesLoader.spriteClasses, true);
				if (m_gameMap == null)
				{
					//TODO error
					MagicStone.log("ERROR: Map has unknown tiles or objects!");
				}
				m_mapInfo.unlockLevel = m_gameMap.calculateUnlockLevel();
				centerX = m_gameMap.mainCharacter.mapX;
				centerY = m_gameMap.mainCharacter.mapY;
			}
			else
			{
				m_gameMap = GameMap.createEmptyMap(GameDefs.k_MAP_DEFAULT_NUM_COLUMNS, GameDefs.k_MAP_DEFAULT_NUM_ROWS, RawTilesDefs.k_EARTH, m_tilesLoader.bitmaps, m_spritesLoader.spriteClasses, true);
				m_mapInfo.unlockLevel = 1;
				centerX = GameDefs.k_MAP_DEFAULT_NUM_COLUMNS * GameDefs.k_TILE_WIDTH;
				centerY = GameDefs.k_MAP_DEFAULT_NUM_ROWS * GameDefs.k_TILE_HEIGHT;
			}
			m_gameMap.setScrollPosition(centerX - MagicStone.bgContainer.stage.stageWidth / 2, centerY - MagicStone.bgContainer.stage.stageHeight / 2);
			MagicStone.bgContainer.addChild(m_gameMap);
			
			m_fader = new Fader(GameDefs.k_BG_COLOR, MagicStone.bgContainer.stage.stageWidth, MagicStone.bgContainer.stage.stageHeight, GameDefs.k_EDITOR_FADE_TIME);
			MagicStone.bgContainer.addChild(m_fader);
			
			m_controlWindow = new Window(MagicStone.uiContainer, new UIEditorControl as Sprite, 300, PositionRectangle.k_TOP_CENTER);
			m_helpGlow = m_controlWindow.ui.getChildByName("animHelpGlow") as MovieClip;
			m_helpGlow.mouseEnabled = false;
			m_helpGlow.mouseChildren = false;
			m_helpGlow.visible = false;
			m_controlWindow.ui.addEventListener(MouseEvent.CLICK, onToolsClick, false, 0, true);			
			createToolTipsControl();
			
			m_toolsWindow = new EditorToolsWindow(MagicStone.uiContainer);
			m_toolsWindow.unlockLevel = m_mapInfo.unlockLevel;
			m_toolsWindow.ui.addEventListener(MouseEvent.CLICK, onToolsClick, false, 0, true);
						
			m_expandButtonsWindow = new ExpandButtonsWindow(MagicStone.bgContainer);
			m_expandButtonsWindow.ui.addEventListener(MouseEvent.CLICK, onExpandClick, false, 0, true);
			m_expandButtonsWindow.open();
			
			if (!MenuOwnMapsState.hasMaps() && m_levelData == null)
			{
				m_tutorialWindow = new TutorialOverlayWindow(ResourceManager.getInstance().getString("default", "textUseArrowKeysToMove"), -46);
				m_helpGlow.visible = true;
			}
			
			m_deleteGui = new DeleteGui as Sprite;
			m_deleteGui.visible = false;
			m_deleteGui.addEventListener(MouseEvent.CLICK, onDeleteGuiClick, false, 0, true);
			MagicStone.bgContainer.addChild(m_deleteGui);
			
			m_gameMap.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			m_gameMap.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			m_gameMap.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			m_gameMap.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			m_gameMap.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			MagicStone.gameStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			MagicStone.gameStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			SplashScreen.instance.container = MagicStone.uiContainer;
			SplashScreen.instance.queueCallback(onSplashFinished);
			SplashScreen.instance.queueRemove();
			
			m_utils = new EditMapUtils(m_gameMap);

			m_currentRawTile = RawTilesDefs.k_FLOOR;
			m_currentObject = new TilePreview(m_gameMap, m_tilesLoader.bitmaps, m_currentRawTile);
			m_currentObject.mouseEnabled = false;
		}
		
		private function createToolTipsControl():void
		{
			m_toolTipsControl = new ToolTips(m_controlWindow.ui, MagicStone.gameStage, GameDefs.k_TOOLTIP_TEXT_FORMAT, GameDefs.k_TOOLTIP_OUTLINE_COLOR, PositionRectangle.k_BOTTOM_CENTER);
			
			var res:IResourceManager = ResourceManager.getInstance();
			m_toolTipsControl.addToolTip("buttonSave", res.getString("default", "toolTipSaveMap"));
			m_toolTipsControl.addToolTip("buttonReturn", res.getString("default", "toolTipReturnEditor"));
			m_toolTipsControl.addToolTip("buttonPlay", res.getString("default", "toolTipPlay"));
			m_toolTipsControl.addToolTip("buttonName", res.getString("default", "toolTipName"));
			
			m_toolTipsControl.addToolTip("buttonZoomIn", res.getString("default", "toolTipZoomIn"));
			m_toolTipsControl.addToolTip("buttonZoomOut", res.getString("default", "toolTipZoomOut"));
			
			m_toolTipsControl.addToolTip("buttonHelp", res.getString("default", "toolTipHelp"));
		}
		
		private function onSplashFinished():void
		{
			MusicPlayer.instance.stop(GameDefs.k_MUSIC_FADE_TIME);
			m_controlWindow.open();
			m_toolsWindow.open();

			if (m_tutorialWindow != null)
			{
				m_tutorialWindow.open();
			}
		}

		override public function end():void
		{
			SplashScreen.instance.removeCallback(onSplashFinished);
			
			m_toolTipsControl.release();
			
			m_controlWindow.close();
			m_toolsWindow.close();
			m_expandButtonsWindow.close();
			if (m_tutorialWindow != null)
			{
				m_tutorialWindow.close();
			}
			MagicStone.bgContainer.removeChild(m_gameMap);

			m_tilesLoader.release();
			m_spritesLoader.release();
			releaseEditorSounds();
			
			MagicStone.gameStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			MagicStone.gameStage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		override public function update():void
		{
			m_gameMap.updateScrolling();
			
			var scrollMap:ScrollTileMap = m_gameMap.mainScrollMap;
			var divisor:int = scrollMap.divisor;
			m_expandButtonsWindow.refreshPositions(-scrollMap.scrollX / divisor, -scrollMap.scrollY / divisor, scrollMap.tileMap.mapWidth / divisor, scrollMap.tileMap.mapHeight / divisor);
			
			if (m_draggingObject != null)
			{
				refreshDeleteGuiPosition(m_draggingObject);
			}
			
			if (m_fader != null)
			{
				m_fader.update();
				if (m_fader.finished)
				{
					m_fader.parent.removeChild(m_fader);
					m_fader = null;
				}
			}
			
			if (m_currentObject != null)
			{
				// flash object
				m_currentObject.alpha = 0.60 + Math.sin(getTimer() / GameDefs.k_EDITOR_FLASH_TIME * 360 / 180 * Math.PI) * 0.25;
			}
			
			if (m_isDragging)
			{
				// flash object
				m_draggingObject.alpha = 0.60 + Math.sin(getTimer() / GameDefs.k_EDITOR_FLASH_TIME * 360 / 180 * Math.PI) * 0.25;
			}
		}
		
		private function refreshDeleteGuiPosition(sprite:MapSprite):void
		{
			var scrollMap:ScrollTileMap = m_gameMap.mainScrollMap;
			m_deleteGui.x = (-scrollMap.scrollX + sprite.mapX) / scrollMap.divisor;
			m_deleteGui.y = (-scrollMap.scrollY + sprite.mapY) / scrollMap.divisor;
		}
		
		private function setRawTile(column:int, row:int):void
		{
			if (column > 0 && row > 0 && column < m_gameMap.numRawColumns - 1 && row < m_gameMap.numRawRows - 1)
			{
				if ((m_currentRawTile & RawTilesDefs.k_MASK_OBJECT) != 0)
				{
					m_gameMap.setRawTileObject(column, row, m_currentRawTile);
				}
				else
				{
					m_gameMap.setRawTile(column, row, m_currentRawTile, true);
				}
			}
		}
		
		private function refreshDraggingObject(overSprite:GameSprite):void
		{
			if (overSprite != m_draggingObject)
			{
				if (m_draggingObject != null)
				{
					m_draggingObject.highlight = false;
					if (m_currentObject != null)
					{
						m_gameMap.refreshSpritePositions();
						m_currentObject.visible = true;
					}
					m_deleteGui.visible = false;
				}
				
				if (overSprite != null)
				{
					overSprite.highlight = true;
					if (m_currentObject != null)
					{
						m_currentObject.visible = false;
					}
					
					refreshDeleteGuiPosition(overSprite);
					m_deleteGui.visible = true;
				}
				
				m_draggingObject = overSprite;
			}
		}
		
		private function checkObjectUniqueness(typeRawTile:int, text:String):void
		{
			var removeGameSprite:GameSprite = null;
			
			if (m_currentObject.rawTile == typeRawTile)
			{
				for each (var gameSprite:GameSprite in m_gameMap.mainScrollMap.mapSprites)
				{
					if (gameSprite != m_currentObject && gameSprite.rawTile == typeRawTile)
					{
						removeGameSprite = gameSprite;
						break;
					}
				}
			}
			
			if (removeGameSprite != null)
			{
				m_gameMap.removeSpriteFromMap(removeGameSprite, true);
				m_onMouseUpMessage = text;
			}
		}
		
		private function checkUnlockLevel(gameSprite:GameSprite, wasAdded:Boolean):void
		{
			if (wasAdded && gameSprite.getUnlockLevel() > m_mapInfo.unlockLevel)
			{
				m_mapInfo.unlockLevel = gameSprite.getUnlockLevel();
				m_toolsWindow.unlockLevel = m_mapInfo.unlockLevel;
			}
			else if (!wasAdded && m_mapInfo.unlockLevel > 1 && gameSprite.getUnlockLevel() == m_mapInfo.unlockLevel)
			{
				m_mapInfo.unlockLevel = m_gameMap.calculateUnlockLevel();
				m_toolsWindow.unlockLevel = m_mapInfo.unlockLevel;
			}
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			var objectName:String = e.target.name as String;
			if (StringUtil.beginsWith(objectName, "button"))
			{
				// clicked on button, don't handle object
				return;
			}
			
			if (m_draggingObject != null)
			{
				m_gameMap.removeSpriteFromMap(m_draggingObject, true);
				m_gameMap.mainScrollMap.addSprite(m_draggingObject);
				m_draggingObject.highlight = false;
				m_isDragging = true;
				m_deleteGui.visible = false;
			}
			else
			{
				m_lastRawColumn = MathUtils.clamp(m_gameMap.getRawColumn(e.stageX), 0, m_gameMap.numRawColumns - 1);
				m_lastRawRow = MathUtils.clamp(m_gameMap.getRawRow(e.stageY), 0, m_gameMap.numRawRows - 1);
				if (m_currentRawTile != RawTilesDefs.k_UNDEFINED)
				{
					// set tile
					if (canSetTile(m_currentRawTile, m_lastRawColumn, m_lastRawRow))
					{
						setRawTile(m_lastRawColumn, m_lastRawRow);
						refreshSpritesAround(m_lastRawColumn, m_lastRawRow);
						m_currentObject.visible = false; // hide preview
					}
					else
					{
						// stop drawing
						return;
					}
				}
				else if (m_currentObject != null)
				{
					// put object
					if (canPutObject(m_currentObject.rawTile, m_lastRawColumn, m_lastRawRow))
					{
						checkObjectUniqueness(RawTilesDefs.k_MAIN_CHARACTER, ResourceManager.getInstance().getString("default", "textMovedMainCharacter"));
						checkObjectUniqueness(RawTilesDefs.k_MAGIC_STONE, ResourceManager.getInstance().getString("default", "textMovedMagicStone"));
						var putObject:GameSprite = m_currentObject.createNew();
						m_gameMap.putSpriteOnMap(putObject, true);
						playObjectSound(m_currentObject.rawTile);
						checkUnlockLevel(m_currentObject, true);
						
						if (putObject is Message)
						{
							(putObject as Message).edit();
						}
					}
				}
			}
			m_isMouseDown = true;
		}
		
		private function canSetTile(rawTile:int, rawColumn:int, rawRow:int):Boolean
		{
			if (rawTile == RawTilesDefs.k_SECRET)
			{
				var count:int = m_utils.countNeighbors(rawColumn, rawRow, RawTilesDefs.k_SECRET, RawTilesDefs.k_MASK_TILE);
				if (count > GameDefs.k_MAX_SECRETS_TOGETHER)
				{
					m_onMouseUpMessage = "You cannot have more than %1 secret fields together. Keep secret ways short!\r(For long ways you can still dig normally and just make the ends secret.)".replace("%1", GameDefs.k_MAX_SECRETS_TOGETHER.toString());
					return false;
				}
			}
			return true;
		}
		
		private function canPutObject(rawTile:int, rawColumn:int, rawRow:int):Boolean
		{
			if (rawTile == RawTilesDefs.k_TREASURE || rawTile == RawTilesDefs.k_GEMSTONES)
			{
				var count:int = m_utils.countNeighbors(rawColumn, rawRow, rawTile, RawTilesDefs.k_MASK_OBJECT);
				if (count > GameDefs.k_MAX_REWARDS_TOGETHER)
				{
					m_onMouseUpMessage = "Don't put so many rewards together! Spread them over different rooms to make it more interesting to find them!";
					return false;
				}
			}
			return true;
		}
		
		private function playObjectSound(rawTile:int):void
		{
			switch (rawTile)
			{
				case RawTilesDefs.k_DOOR:
					SoundManager.instance.play(FileDefs.k_URL_SFX_DOOR_LOCKED);
					break;
				
				case RawTilesDefs.k_KEY:
					SoundManager.instance.play(FileDefs.k_URL_SFX_KEY);
					break;
				
				case RawTilesDefs.k_POTION:
					SoundManager.instance.play(FileDefs.k_URL_SFX_POTION);
					break;
				
				case RawTilesDefs.k_TREASURE:
				case RawTilesDefs.k_GEMSTONES:
					SoundManager.instance.play(FileDefs.k_URL_SFX_COINS_1);
					break;
				
				case RawTilesDefs.k_DOOR_BUTTON_1:
				case RawTilesDefs.k_DOOR_BUTTON_2:
				case RawTilesDefs.k_DOOR_BUTTON_3:
				case RawTilesDefs.k_DOOR_BUTTON_4:
					SoundManager.instance.play(FileDefs.k_URL_SFX_BUTTON);
					break;
				
				case RawTilesDefs.k_BROKEN_FLOOR:
				case RawTilesDefs.k_BROKEN_FLOOR_2_GOOD:
				case RawTilesDefs.k_BROKEN_FLOOR_2_BAD:
				case RawTilesDefs.k_HOLE:
					SoundManager.instance.play(FileDefs.k_URL_SFX_SECRET_WAY);
					break;

				default:
					SoundManager.instance.play(FileDefs.k_URL_SFX_PUT);
					break;
			}
		}

		private function onMouseUp(e:MouseEvent):void
		{
			if (m_isDragging)
			{
				m_gameMap.mainScrollMap.removeSprite(m_draggingObject);
				m_gameMap.putSpriteOnMap(m_draggingObject, true);
				m_draggingObject.alpha = 1;
				m_draggingObject.highlight = true;
				m_isDragging = false;
				m_deleteGui.visible = true;
				playObjectSound(m_draggingObject.rawTile);
				// don't avoid putting, but at least give alert popups.
				canPutObject(m_draggingObject.rawTile, m_draggingObject.rawColumn, m_draggingObject.rawRow);
			}
			else
			{
				refreshDraggingObject(m_gameMap.getSpriteFromMap(m_lastRawColumn, m_lastRawRow));
			}
			if (m_onMouseUpMessage != null)
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, m_onMouseUpMessage);
				popup.open();
				
				m_onMouseUpMessage = null;
			}
			if (m_currentObject != null && m_draggingObject == null)
			{
				m_gameMap.refreshSpritePositions();
				m_currentObject.visible = true; // unhide preview
			}
			m_isMouseDown = false;
		}

		private function onMouseMove(e:MouseEvent):void
		{
			var rawColumn:int = MathUtils.clamp(m_gameMap.getRawColumn(e.stageX), 0, m_gameMap.numRawColumns - 1);
			var rawRow:int = MathUtils.clamp(m_gameMap.getRawRow(e.stageY), 0, m_gameMap.numRawRows - 1);
			if (rawColumn != m_lastRawColumn || rawRow != m_lastRawRow)
			{
				m_lastRawColumn = rawColumn;
				m_lastRawRow = rawRow;

				if (m_isMouseDown)
				{
					if (m_isDragging)
					{
						// drag if position is free
						if ((m_gameMap.getRawTile(rawColumn, rawRow) & RawTilesDefs.k_MASK_OBJECT) == 0)
						{
							m_draggingObject.setRawPosition(rawColumn, rawRow);
							m_draggingObject.onPutOnMap(); // just to show correct preview
							m_gameMap.refreshSpritePositions();
						}
					}
					else if (m_currentRawTile != RawTilesDefs.k_UNDEFINED)
					{
						// set tile
						if (canSetTile(m_currentRawTile, m_lastRawColumn, m_lastRawRow))
						{
							setRawTile(rawColumn, rawRow);
							refreshSpritesAround(rawColumn, rawRow);
						}
						else
						{
							// stop drawing
							m_isMouseDown = false;
						}
					}
				}

				if (m_currentObject != null)
				{
					m_currentObject.setRawPosition(rawColumn, rawRow);
					m_currentObject.onPutOnMap(); // just to show correct preview
					m_gameMap.refreshSpritePositions();
				}
				
				if (!m_isDragging && !m_isMouseDown)
				{
					refreshDraggingObject(m_gameMap.getSpriteFromMap(rawColumn, rawRow));
				}
			}
		}
		
		private function refreshSpritesAround(rawColumn:int, rawRow:int):void
		{
			for (var ox:int = -1; ox <= 1; ox++)
			{
				for (var oy:int = -1; oy <=1; oy++)
				{
					var overSprite:GameSprite = m_gameMap.getSpriteFromMap(rawColumn + ox, rawRow + oy);
					if (overSprite != null)
					{
						overSprite.refreshValidation();
					}
				}
			}
		}

		private function onRollOver(e:MouseEvent):void
		{
			if (m_currentObject != null)
			{
				var rawColumn:int = MathUtils.clamp(m_gameMap.getRawColumn(e.stageX), 0, m_gameMap.numRawColumns - 1);
				var rawRow:int = MathUtils.clamp(m_gameMap.getRawRow(e.stageY), 0, m_gameMap.numRawRows - 1);

				m_currentObject.setRawPosition(rawColumn, rawRow);
				m_gameMap.mainScrollMap.addSprite(m_currentObject);
				m_gameMap.refreshSpritePositions();
			}
		}

		private function onRollOut(e:MouseEvent):void
		{
			m_isMouseDown = false;

			if (m_currentObject != null && m_gameMap.mainScrollMap.contains(m_currentObject))
			{
				m_gameMap.mainScrollMap.removeSprite(m_currentObject);
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (!WindowManager.instance.hasExclusiveWindow())
			{
				var stageWidth:Number = MagicStone.gameStage.stageWidth * m_gameMap.divisor;
				var stageHeight:Number = MagicStone.gameStage.stageHeight * m_gameMap.divisor;
				switch (e.keyCode)
				{
					case Keyboard.UP:
						m_gameMap.setScrollTarget(m_gameMap.scrollTargetX, Math.max(m_gameMap.scrollTargetY - GameDefs.k_EDITOR_SCROLL, -stageHeight / 2));
						break;
	
					case Keyboard.DOWN:
						m_gameMap.setScrollTarget(m_gameMap.scrollTargetX, Math.min(m_gameMap.scrollTargetY + GameDefs.k_EDITOR_SCROLL, m_gameMap.mainScrollMap.tileMap.mapHeight - stageHeight / 2));
						break;
					
					case Keyboard.LEFT:
						m_gameMap.setScrollTarget(Math.max(m_gameMap.scrollTargetX - GameDefs.k_EDITOR_SCROLL, -stageWidth / 2), m_gameMap.scrollTargetY);
						break;
	
					case Keyboard.RIGHT:
						m_gameMap.setScrollTarget(Math.min(m_gameMap.scrollTargetX + GameDefs.k_EDITOR_SCROLL, m_gameMap.mainScrollMap.tileMap.mapWidth - stageWidth / 2), m_gameMap.scrollTargetY);
						break;
				}
				if (m_tutorialWindow != null)
				{
					m_tutorialWindow.close();
				}
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
			}
		}

		private function onToolsClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			var window:Window = null;
			var utils:EditMapUtils;
			
			trace("buttonName: " + buttonName);
			
			switch (buttonName)
			{
				case "buttonReturn":
					if (m_gameMap.changed)
					{
						window = new PopupWindow(PopupWindow.k_TYPE_YES_NO, ResourceManager.getInstance().getString("default", "textAskSaveEditor"));
						window.ui.addEventListener(MouseEvent.CLICK, onReturnClick, false, 0, true);
						window.open();
					}
					else
					{
						returnToMenu();
					}
					break;
				
				case "buttonSave":
					utils = new EditMapUtils(m_gameMap);
					if (utils.checkMapValidity(m_currentObject))
					{
						save(k_AFTER_SAVE_NOTHING);
					}
					break;
				
				case "buttonPlay":
					utils = new EditMapUtils(m_gameMap);
					if (utils.checkMapValidity(m_currentObject))
					{
						if (m_gameMap.changed)
						{
							window = new PopupWindow(PopupWindow.k_TYPE_YES_NO, ResourceManager.getInstance().getString("default", "textAskPlayAndSave"));
							window.ui.addEventListener(MouseEvent.CLICK, onPlayClick, false, 0, true);
							window.open();
						}
						else
						{
							play();
						}
					}
					break;
				
				case "buttonName":
					m_nameInputWindow = new TextInputWindow(ResourceManager.getInstance().getString("default", "textEnterMapName"), m_mapInfo.name);
					m_nameInputWindow.ui.addEventListener(MouseEvent.CLICK, onNameInputClick, false, 0, true);
					m_nameInputWindow.open();
					break;
				
				case "buttonZoomIn":
					if (m_gameMap.divisor > 1)
					{
						setDivisor(m_gameMap.divisor - 1);
					}
					break;

				case "buttonZoomOut":
					if (m_gameMap.divisor < 3)
					{
						setDivisor(m_gameMap.divisor + 1);
					}
					break;
				
				case "buttonHelp":
					m_helpGlow.visible = false;
					showHelp();
					break;
				
				case "buttonUnlockLevel":
					window = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textUnlockLevelInfo"));
					window.open();
					break;
				
				// basic tools

				case "buttonToolTile1":
					m_currentRawTile = RawTilesDefs.k_EARTH;
					m_currentObject = null;
					break;

				case "buttonToolTile2":
					m_currentRawTile = RawTilesDefs.k_FLOOR;
					m_currentObject = null;
					break;

				case "buttonToolTile3":
					m_currentRawTile = RawTilesDefs.k_SECRET;
					m_currentObject = null;
					break;
				
				// level 1

				case "buttonToolObject1":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new MainCharacter(m_gameMap);
					break;

				case "buttonToolObject2":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new MapMagicStone(m_gameMap);
					break;
				
				case "buttonToolObject3":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new Door(m_gameMap, false);
					break;

				case "buttonToolObject4":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new Key(m_gameMap);
					break;

				case "buttonToolObject5":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new Shop(m_gameMap, Shop.k_WEAPON);
					break;

				case "buttonToolObject6":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new Shop(m_gameMap, Shop.k_SHIELD);
					break;

				case "buttonToolObject7":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new Shop(m_gameMap, Shop.k_ARMOR);
					break;

				case "buttonToolObject8":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new Treasure(m_gameMap);
					break;

				case "buttonToolObject9":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new Potion(m_gameMap);
					break;

				case "buttonToolObject10":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new Enemy(m_gameMap, 0, true, true);
					break;

				case "buttonToolObject11":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new Gemstones(m_gameMap);
					break;
				
				// level 2
				
				case "buttonToolObject12":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new DoorButton(m_gameMap, 0);
					break;

				case "buttonToolObject13":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new DoorButton(m_gameMap, 1);
					break;
				
				case "buttonToolObject14":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new DoorButton(m_gameMap, 2);
					break;
				
				case "buttonToolObject15":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new DoorButton(m_gameMap, 3);
					break;
				
				case "buttonToolObject16":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new DoorColors(m_gameMap, false, 0, false);
					break;
				
				case "buttonToolObject17":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new DoorColors(m_gameMap, false, 1, false);
					break;
				
				case "buttonToolObject18":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new DoorColors(m_gameMap, false, 2, false);
					break;
				
				case "buttonToolObject19":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new DoorColors(m_gameMap, false, 3, false);
					break;
				
				case "buttonToolObject20":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new Message(m_gameMap, "", false);
					break;

				case "buttonToolObject21":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new Cross(m_gameMap);
					break;

				case "buttonToolObject22":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new BrokenFloor(m_gameMap, BrokenFloor.k_STATE_ONE_TIME_SAFE, false);
					break;
				
				case "buttonToolObject23":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new BrokenFloor(m_gameMap, BrokenFloor.k_STATE_GOOD, false);
					break;
				
				case "buttonToolObject24":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new BrokenFloor(m_gameMap, BrokenFloor.k_STATE_BAD, false);
					break;
				
				case "buttonToolObject25":
					m_currentRawTile = RawTilesDefs.k_UNDEFINED;
					m_currentObject = new BrokenFloor(m_gameMap, BrokenFloor.k_STATE_HOLE, false);
					break;
				
			}
			
			if (m_currentRawTile != RawTilesDefs.k_UNDEFINED)
			{
				m_currentObject = new TilePreview(m_gameMap, m_tilesLoader.bitmaps, m_currentRawTile);
			}
			
			if (m_currentObject != null)
			{
				m_currentObject.mouseEnabled = false;
				m_currentObject.mouseChildren = false;
			}
		}
		
		public function setDivisor(divisor:int):void
		{
			var mapCenterX:Number = m_gameMap.mainScrollMap.scrollX + MagicStone.bgContainer.stage.stageWidth * m_gameMap.divisor / 2;
			var mapCenterY:Number = m_gameMap.mainScrollMap.scrollY + MagicStone.bgContainer.stage.stageHeight * m_gameMap.divisor / 2;
			m_gameMap.divisor = divisor;
			m_gameMap.setScrollPosition(mapCenterX - MagicStone.bgContainer.stage.stageWidth * m_gameMap.divisor / 2, mapCenterY - MagicStone.bgContainer.stage.stageHeight * m_gameMap.divisor / 2);
			
			m_deleteGui.scaleX = 1 / divisor;
			m_deleteGui.scaleY = 1 / divisor;
		}
		
		private function onExpandClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			trace("buttonName: " + buttonName);
			
			switch (buttonName)
			{
				case "buttonUp":
					m_gameMap.addSize(GameMap.k_SIDE_TOP, GameDefs.k_EDITOR_MAP_INCREASE_TILES);
					break;
				
				case "buttonDown":
					m_gameMap.addSize(GameMap.k_SIDE_BOTTOM, GameDefs.k_EDITOR_MAP_INCREASE_TILES);
					break;
				
				case "buttonLeft":
					m_gameMap.addSize(GameMap.k_SIDE_LEFT, GameDefs.k_EDITOR_MAP_INCREASE_TILES);
					break;

				case "buttonRight":
					m_gameMap.addSize(GameMap.k_SIDE_RIGHT, GameDefs.k_EDITOR_MAP_INCREASE_TILES);
					break;
			}

		}
		
		private function onDeleteGuiClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			
			switch (buttonName)
			{
				case "buttonDelete":
					m_gameMap.removeSpriteFromMap(m_draggingObject, true);
					checkUnlockLevel(m_draggingObject, false);
					refreshDraggingObject(null);
					m_deleteGui.visible = false;
					break;
			}	
		}
		
		private function onReturnClick(e:MouseEvent):void
		{
			if (e.target.name == PopupWindow.k_BUTTON_YES)
			{
				var utils:EditMapUtils = new EditMapUtils(m_gameMap);
				if (utils.checkMapValidity(m_currentObject))
				{
					save(k_AFTER_SAVE_RETURN);
				}
			}
			else
			{
				returnToMenu();
			}
		}
		
		private function returnToMenu():void
		{
			var state:State = new MenuState(m_stateMachine);
			m_stateMachine.setState(state);
		}
		
		private function onPlayClick(e:MouseEvent):void
		{
			if (e.target.name == PopupWindow.k_BUTTON_YES)
			{
				save(k_AFTER_SAVE_PLAY);
			}
		}

		private function play():void
		{
			var state:State = new MapLoaderState(m_stateMachine, MapLoaderState.k_GO_TO_INGAME, InGameState.k_CAME_FROM_EDITOR, m_mapInfo);
			m_stateMachine.setState(state);
		}

		private function save(afterSave:int):void
		{
			m_doAfterSave = afterSave;
			m_savePopup = new PopupWindow(PopupWindow.k_TYPE_WAIT, ResourceManager.getInstance().getString("default", "textMapSaved"));
			m_savePopup.open();
			
			var data:ByteArray = new ByteArray();
			m_gameMap.serialize(data);
			data.position = 0;
			
			var messages:String = m_gameMap.getMessages();
			
			GameServer.instance.sendMap(m_mapInfo.mapId, SocialUserManager.instance.playerUserId, m_mapInfo.name, m_mapInfo.unlockLevel, data, messages, onSaveComplete);
			MenuOwnMapsState.reinitMaps();
			m_gameMap.unsetChanged();
		}
		
		private function onSaveComplete(answer:Answer):void
		{
			if (answer.isOk)
			{
				m_savePopup.ui.addEventListener(MouseEvent.CLICK, onSavePopupClicked, false, 0, true);
				m_savePopup.waitingDone();
				if (answer.insertId != 0)
				{
					m_mapInfo.mapId = answer.insertId;
				}
			}
			else
			{
				m_savePopup.close();
				var window:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorMapSaving"));
				window.open();
			}
			m_savePopup = null;
		}
		
		private function onSavePopupClicked(e:MouseEvent):void
		{
			if (e.target.name == PopupWindow.k_BUTTON_OK)
			{
				switch (m_doAfterSave)
				{
					case k_AFTER_SAVE_RETURN:
						returnToMenu();
						break;
					
					case k_AFTER_SAVE_PLAY:
						play();
						break;
				}
			}
		}
		
		private function onNameInputClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			if (buttonName == TextInputWindow.k_BUTTON_ACCEPT)
			{
				m_mapInfo.name = m_nameInputWindow.inputText;
				m_gameMap.setChanged();
				m_nameInputWindow = null;
			}
			else if (buttonName == TextInputWindow.k_BUTTON_CANCEL)
			{
				m_nameInputWindow = null;
			}
		}
		
		private function showHelp():void
		{
			var window:HelpWindow = new HelpWindow(InGameState.getTextArray("textHelpEditorTitle", 6), InGameState.getTextArray("textHelpEditor", 6));
			window.open();
		}
		
		public static function requestEditorSounds():void
		{
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_DOOR_LOCKED, FileDefs.k_URL_SFX_DOOR_LOCKED);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_KEY, FileDefs.k_URL_SFX_KEY);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_COINS_1, FileDefs.k_URL_SFX_COINS_1);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_POTION, FileDefs.k_URL_SFX_POTION);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_BUTTON, FileDefs.k_URL_SFX_BUTTON);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_PUT, FileDefs.k_URL_SFX_PUT);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_SECRET_WAY, FileDefs.k_URL_SFX_SECRET_WAY);
		}
		
		private function releaseEditorSounds():void
		{
			SoundManager.instance.release(FileDefs.k_URL_SFX_DOOR_LOCKED);
			SoundManager.instance.release(FileDefs.k_URL_SFX_KEY);
			SoundManager.instance.release(FileDefs.k_URL_SFX_COINS_1);
			SoundManager.instance.release(FileDefs.k_URL_SFX_POTION);
			SoundManager.instance.release(FileDefs.k_URL_SFX_BUTTON);
			SoundManager.instance.release(FileDefs.k_URL_SFX_PUT);
			SoundManager.instance.release(FileDefs.k_URL_SFX_SECRET_WAY);
		}

	}
}