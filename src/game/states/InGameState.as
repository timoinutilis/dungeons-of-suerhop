package game.states
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.SoundChannel;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;
	import game.map.BrokenFloor;
	import game.map.Door;
	import game.map.DoorButton;
	import game.map.DoorColors;
	import game.map.Enemy;
	import game.map.GameMap;
	import game.map.GameSprite;
	import game.map.Gemstones;
	import game.map.Key;
	import game.map.MainCharacter;
	import game.map.Message;
	import game.map.Potion;
	import game.map.Treasure;
	import game.server.GameServer;
	import game.server.answers.Answer;
	import game.ui.HelpWindow;
	import game.ui.InGameWindow;
	import game.ui.PopupWindow;
	import game.ui.TutorialOverlayWindow;
	import game.value.MapInfo;
	import game.value.Savegame;
	
	import de.inutilis.inutilib.ArrayUtils;
	import de.inutilis.inutilib.GameKeys;
	import de.inutilis.inutilib.MathUtils;
	import de.inutilis.inutilib.UserOptions;
	import de.inutilis.inutilib.fx.AnimFx;
	import de.inutilis.inutilib.fx.FxManager;
	import de.inutilis.inutilib.fx.ScoreFx;
	import de.inutilis.inutilib.map.IDImagesLoader;
	import de.inutilis.inutilib.map.ScrollTileMap;
	import de.inutilis.inutilib.media.MusicPlayer;
	import de.inutilis.inutilib.media.SoundLoopPlayer;
	import de.inutilis.inutilib.media.SoundManager;
	import de.inutilis.inutilib.social.SocialUserManager;
	import de.inutilis.inutilib.statemachine.State;
	import de.inutilis.inutilib.statemachine.StateMachine;
	import de.inutilis.inutilib.ui.Fader;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.SplashScreen;
	import de.inutilis.inutilib.ui.ToolTips;
	import de.inutilis.inutilib.ui.Window;
	import de.inutilis.inutilib.ui.WindowManager;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	public class InGameState extends State
	{
		public static const k_CAME_FROM_MENU:int = 1;
		public static const k_CAME_FROM_EDITOR:int = 2;
		
		public static const k_EQUIPMENT_ARMOR:int = 0;
		public static const k_EQUIPMENT_SHIELD:int = 1;
		public static const k_EQUIPMENT_WEAPON:int = 2;
		
		private static const k_CONTINUE:int = 0;
		private static const k_STOP:int = 1;
		private static const k_STOP_AND_IDLE:int = 2;
		
		private static const k_STEPS_FADE_OUT_TIME:int = 150;
		
		private var m_tilesLoader:IDImagesLoader;
		private var m_discoverTilesLoader:IDImagesLoader;
		private var m_spritesLoader:IDImagesLoader;
		private var m_originalLevelData:ByteArray;
		private var m_levelData:ByteArray;
		private var m_levelMessages:String;
		private var m_mapInfo:MapInfo;
		private var m_cameFrom:int;
		
		private var m_startMcColumn:int;
		private var m_startMcRow:int;
		
		private var m_subStateMachine:StateMachine;
		private var m_gameMap:GameMap;
		private var m_fader:Fader;
		private var m_hud:InGameWindow;
		private var m_savePopup:PopupWindow;
		private var m_tutorialWindow:TutorialOverlayWindow;
		private var m_toolTips:ToolTips;
		
		private var m_health:int;
		private var m_keys:int;
		private var m_coins:int;
		private var m_equipment:Array;
		private var m_seconds:Number;
		private var m_score:int;
		
		private var m_stopped:Boolean;
		private var m_scrollTargetSprite:GameSprite;
		private var m_overlayGameSprite:GameSprite;
		private var m_stepsPlayer:SoundLoopPlayer;
		
		private var m_changed:Boolean;
		private var m_exitAfterSave:Boolean;

		public function InGameState(stateMachine:StateMachine, tilesLoader:IDImagesLoader, discoverTilesLoader:IDImagesLoader, spritesLoader:IDImagesLoader, levelData:ByteArray, levelMessages:String, mapInfo:MapInfo, savegame:Savegame, cameFrom:int)
		{
			super(stateMachine);
			m_tilesLoader = tilesLoader;
			m_discoverTilesLoader = discoverTilesLoader;
			m_spritesLoader = spritesLoader;
			m_originalLevelData = levelData;
			m_levelMessages = levelMessages;
			m_mapInfo = mapInfo;
			m_cameFrom = cameFrom;
			
			m_equipment = new Array(3);
			m_health = GameDefs.k_MAX_HEALTH;
			m_seconds = 0;
			m_score = 0;
			m_changed = false;
			
			if (savegame != null)
			{
				m_startMcColumn = savegame.mcColumn;
				m_startMcRow = savegame.mcRow;
				m_health = savegame.health;
				m_coins = savegame.numCoins;
				m_keys = savegame.numKeys;
				m_equipment[k_EQUIPMENT_ARMOR] = savegame.armor;
				m_equipment[k_EQUIPMENT_SHIELD] = savegame.shield;
				m_equipment[k_EQUIPMENT_WEAPON] = savegame.weapon;
				m_seconds = savegame.time;
				m_score = savegame.score;
				m_levelData = ArrayUtils.decodeDifference(m_originalLevelData, savegame.dataDiff);
			}
			else
			{
				m_levelData = m_originalLevelData;
			}
		}
		
		override public function start():void
		{
			m_subStateMachine = new StateMachine();
			
			m_levelData.position = 0;
			m_gameMap = GameMap.deserialize(m_levelData, m_levelMessages, m_tilesLoader.bitmaps, m_discoverTilesLoader.bitmaps, m_spritesLoader.spriteClasses, false);
			if (m_gameMap == null)
			{
				//TODO error
				MagicStone.log("ERROR: Map has unknown tiles or objects!");
			}
			MagicStone.bgContainer.addChild(m_gameMap);
			
			m_fader = new Fader(GameDefs.k_BG_COLOR, MagicStone.bgContainer.stage.stageWidth, MagicStone.bgContainer.stage.stageHeight, GameDefs.k_EDITOR_FADE_TIME);
			MagicStone.bgContainer.addChild(m_fader);
			
			setEquipment(k_EQUIPMENT_ARMOR, m_equipment[k_EQUIPMENT_ARMOR]);
			setEquipment(k_EQUIPMENT_SHIELD, m_equipment[k_EQUIPMENT_SHIELD]);
			setEquipment(k_EQUIPMENT_WEAPON, m_equipment[k_EQUIPMENT_WEAPON]);
			
			if (m_startMcColumn != 0 && m_startMcRow != 0)
			{
				// main character position from savegame
				m_gameMap.mainCharacter.setRawPosition(m_startMcColumn, m_startMcRow);
			}
			m_gameMap.mainCharacter.onReachHandler = onReached;
			m_gameMap.setScrollPosition(m_gameMap.mainCharacter.mapX - m_gameMap.stage.stageWidth / 2, m_gameMap.mainCharacter.mapY - m_gameMap.stage.stageHeight / 2);
			m_gameMap.discover(m_gameMap.mainCharacter.rawColumn, m_gameMap.mainCharacter.rawRow);

			
			m_scrollTargetSprite = m_gameMap.mainCharacter;

			FxManager.instance.container = MagicStone.bgContainer;
			
			m_hud = new InGameWindow(MagicStone.uiContainer, coins, keys, score, health);
			m_hud.ui.addEventListener(MouseEvent.CLICK, onHudClick, false, 0, true);
			
			m_toolTips = new ToolTips(m_hud.ui, MagicStone.gameStage, GameDefs.k_TOOLTIP_TEXT_FORMAT, GameDefs.k_TOOLTIP_OUTLINE_COLOR, PositionRectangle.k_BOTTOM_CENTER);
			if (m_cameFrom == k_CAME_FROM_MENU)
			{
				m_toolTips.addToolTip("buttonExit", ResourceManager.getInstance().getString("default", "toolTipExitGame"));
			}
			else
			{
				m_toolTips.addToolTip("buttonExit", ResourceManager.getInstance().getString("default", "toolTipExitGameToEditor"));
			}
			m_toolTips.addToolTip("buttonSave", ResourceManager.getInstance().getString("default", "toolTipSaveGame"));
			m_toolTips.addToolTip("buttonHelp", ResourceManager.getInstance().getString("default", "toolTipHelp"));
			
			if (MagicStone.s_userInfo.numSuccesses == 0)
			{
				m_tutorialWindow = new TutorialOverlayWindow(ResourceManager.getInstance().getString("default", "textUseArrowKeys"));
				m_hud.setHelpGlowVisible(true);
			}
			
			m_stepsPlayer = new SoundLoopPlayer(SoundManager.instance.getSound(FileDefs.k_URL_SFX_STEPS), 1000 / MagicStone.gameStage.frameRate);
			UserOptions.instance.addEventListener(UserOptions.k_SFX, onSfxOption, false, 0, true);
			
			SplashScreen.instance.container = MagicStone.uiContainer;
			SplashScreen.instance.queueCallback(onSplashFinished);
			SplashScreen.instance.queueRemove();
		}
		
		private function onSplashFinished():void
		{
			MusicPlayer.instance.play(Config.resPath + FileDefs.k_URL_MUSIC_GAME, GameDefs.k_MUSIC_FADE_TIME);

			m_hud.open();

			if (m_tutorialWindow != null)
			{
				m_tutorialWindow.open();
			}
		}
		
		override public function end():void
		{
			m_stepsPlayer.release();
			m_stepsPlayer = null;
			
			SplashScreen.instance.removeCallback(onSplashFinished);
			
			FxManager.instance.clear();
			FxManager.instance.container = null;
			
			m_subStateMachine.quit();
			
			if (m_overlayGameSprite != null)
			{
				MagicStone.bgContainer.removeChild(m_overlayGameSprite);
			}
			
			m_toolTips.release();

			m_hud.close();
			if (m_tutorialWindow != null)
			{
				m_tutorialWindow.close();
			}
			MagicStone.bgContainer.removeChild(m_gameMap);
			
			m_tilesLoader.release();
			m_discoverTilesLoader.release();
			m_spritesLoader.release();
			releaseGameSounds();
		}
		
		override public function update():void
		{
			m_subStateMachine.update();

			var mainCharacter:MainCharacter = m_gameMap.mainCharacter;

			if (m_subStateMachine.currentState == null && !WindowManager.instance.hasExclusiveWindow())
			{
				if (mainCharacter.isIdle())
				{
					checkControl();
				}
			}
			else
			{
				m_stopped = false;
			}
			
			m_gameMap.updateGameSprites();
			
			var scrollMap:ScrollTileMap = m_gameMap.mainScrollMap;
			
			m_gameMap.setScrollTarget(m_scrollTargetSprite.mapX - m_gameMap.stage.stageWidth / 2, m_scrollTargetSprite.mapY - m_gameMap.stage.stageHeight / 2);
			m_gameMap.updateScrolling();			
			FxManager.instance.setPosition(scrollMap.scrollX, scrollMap.scrollY);
			
			if (m_overlayGameSprite != null)
			{
				m_overlayGameSprite.x = -scrollMap.scrollX + m_overlayGameSprite.mapX;
				m_overlayGameSprite.y = -scrollMap.scrollY + m_overlayGameSprite.mapY;
				if (MagicStone.bgContainer.getChildIndex(m_overlayGameSprite) < MagicStone.bgContainer.numChildren)
				{
					MagicStone.bgContainer.setChildIndex(m_overlayGameSprite, MagicStone.bgContainer.numChildren - 1);
				}
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
		}
		
		public function closeHud():void
		{
			m_hud.close();
		}
		
		public function openHud():void
		{
			m_hud.open();
		}
				
		private function onReached():void
		{
			if (WindowManager.instance.hasExclusiveWindow())
			{
				if (!m_gameMap.mainCharacter.isIdle())
				{
					m_gameMap.mainCharacter.idle();
					m_stepsPlayer.stop(k_STEPS_FADE_OUT_TIME);
				}
			}
			else
			{
				var mainCharacter:MainCharacter = m_gameMap.mainCharacter;
				var result:int = checkReachedTile(mainCharacter.rawColumn, mainCharacter.rawRow);
				if (result == k_CONTINUE)
				{
					checkControl();
				}
				else
				{
					if (result == k_STOP_AND_IDLE)
					{
						mainCharacter.idle();
					}
					m_stepsPlayer.stop(k_STEPS_FADE_OUT_TIME);
					m_stopped = true;
				}
			}
		}
		
		private function checkControl():void
		{
			if (m_stopped)
			{
				if (   !GameKeys.instance.isKeyDown(GameKeys.k_LEFT)
					&& !GameKeys.instance.isKeyDown(GameKeys.k_RIGHT)
					&& !GameKeys.instance.isKeyDown(GameKeys.k_UP)
					&& !GameKeys.instance.isKeyDown(GameKeys.k_DOWN) )
				{
					m_stopped = false;
				}
			}
			else
			{
				var mainCharacter:MainCharacter = m_gameMap.mainCharacter;
				if (GameKeys.instance.isKeyDown(GameKeys.k_LEFT))
				{
					checkWalk(-1, 0, GameSprite.k_DIR_LEFT);
				}
				else if (GameKeys.instance.isKeyDown(GameKeys.k_RIGHT))
				{
					checkWalk(+1, 0, GameSprite.k_DIR_RIGHT);
				}
				else if (GameKeys.instance.isKeyDown(GameKeys.k_UP))
				{
					checkWalk(0, -1, GameSprite.k_DIR_UP);
				}
				else if (GameKeys.instance.isKeyDown(GameKeys.k_DOWN))
				{
					checkWalk(0, +1, GameSprite.k_DIR_DOWN);
				}
				else if (!mainCharacter.isIdle())
				{
					mainCharacter.idle();
					m_stepsPlayer.stop(k_STEPS_FADE_OUT_TIME);
				}
			}
		}
		
		private function checkWalk(rawColumnDiff:int, rawRowDiff:int, direction:int):void
		{
			var mainCharacter:MainCharacter = m_gameMap.mainCharacter;
			var result:int = checkTile(mainCharacter.rawColumn + rawColumnDiff, mainCharacter.rawRow + rawRowDiff, direction);
			if (result == k_CONTINUE)
			{
				checkLeftTile(mainCharacter.rawColumn, mainCharacter.rawRow);
				mainCharacter.startWalking(direction);
				m_gameMap.discover(mainCharacter.rawColumn + rawColumnDiff, mainCharacter.rawRow + rawRowDiff);
				addSeconds(GameDefs.k_SECONDS_WALK);
				if (m_tutorialWindow != null)
				{
					m_tutorialWindow.close();
				}
				if (UserOptions.instance.getBoolean(UserOptions.k_SFX))
				{
					m_stepsPlayer.play(0);
				}
			}
			else
			{
				m_stopped = true;
				mainCharacter.look(direction);
				m_stepsPlayer.stop(k_STEPS_FADE_OUT_TIME);
			}
		}
		
		private function checkTile(rawColumn:int, rawRow:int, moveDir:int):int
		{
			var state:State;
			var point:Point;
			var tile:int = m_gameMap.getRawTile(rawColumn, rawRow);
			var objectTile:int = tile & RawTilesDefs.k_MASK_OBJECT;
			var mapTile:int = tile & RawTilesDefs.k_MASK_TILE;

			if (objectTile != 0)
			{
				m_changed = true;
				var sprite:GameSprite = m_gameMap.getSpriteFromMap(rawColumn, rawRow);
				switch (objectTile)
				{
					case RawTilesDefs.k_DOOR:
					case RawTilesDefs.k_DOOR_OPEN:
						var door:Door = sprite as Door;
						if (door.currentState == Door.k_STATE_CLOSED)
						{
							if (m_keys > 0)
							{
								door.open();
								addKeys(-1);
								addSeconds(GameDefs.k_SECONDS_OPEN_DOOR);
								addScore(GameDefs.k_SCORE_DOOR);
								SoundManager.instance.play(FileDefs.k_URL_SFX_DOOR);
							}
							else
							{
								point = sprite.getFxPoint();
								FxManager.instance.addFx(new ScoreFx(ResourceManager.getInstance().getString("default", "textNoKeys"), 0xFFFFFF, GameDefs.k_FX_OUTLINE_COLOR, GameDefs.k_FX_TEXT_FORMAT, 1500, 0), point.x, point.y);
								SoundManager.instance.play(FileDefs.k_URL_SFX_DOOR_LOCKED);
							}
						}
						return (door.currentState == Door.k_STATE_OPEN) ? k_CONTINUE : k_STOP_AND_IDLE;
						
					case RawTilesDefs.k_KEY:
						var key:Key = sprite as Key;
						key.pickUp();
						addKeys(1);
						addScore(GameDefs.k_SCORE_KEY);
						point = sprite.getFxPoint();
						FxManager.instance.addFx(new ScoreFx(ResourceManager.getInstance().getString("default", "textKey"), 0xFFFF88, GameDefs.k_FX_OUTLINE_COLOR, GameDefs.k_FX_TEXT_FORMAT, 1000, 0), point.x, point.y);
						SoundManager.instance.play(FileDefs.k_URL_SFX_KEY);
						break;
					
					case RawTilesDefs.k_MAGIC_STONE:
						addScore(GameDefs.k_SCORE_WIN);
						state = new WinState(m_subStateMachine, m_stateMachine, m_mapInfo, m_seconds, m_score, m_cameFrom);
						m_subStateMachine.setState(state);
						m_gameMap.discover(rawColumn, rawRow);
						m_scrollTargetSprite = sprite;
						setOverlaySprite(sprite);
						closeHud();
						return k_STOP_AND_IDLE;
					
					case RawTilesDefs.k_SHOP_ARMOR:
						state = new ShopState(m_subStateMachine, this, k_EQUIPMENT_ARMOR);
						m_subStateMachine.setState(state);
						m_gameMap.discover(rawColumn, rawRow);
						return k_STOP_AND_IDLE;
						
					case RawTilesDefs.k_SHOP_SHIELD:
						state = new ShopState(m_subStateMachine, this, k_EQUIPMENT_SHIELD);
						m_subStateMachine.setState(state);
						m_gameMap.discover(rawColumn, rawRow);
						return k_STOP_AND_IDLE;
						
					case RawTilesDefs.k_SHOP_WEAPON:
						state = new ShopState(m_subStateMachine, this, k_EQUIPMENT_WEAPON);
						m_subStateMachine.setState(state);
						m_gameMap.discover(rawColumn, rawRow);
						return k_STOP_AND_IDLE;
						
					case RawTilesDefs.k_TREASURE:
						var treasure:Treasure = sprite as Treasure;
						treasure.pickUp();
						var collectedCoins:int = MathUtils.randomInt(GameDefs.k_GAME_TREASURE_COINS_MIN, GameDefs.k_GAME_TREASURE_COINS_MAX);
						addCoins(collectedCoins);
						addScore(GameDefs.k_SCORE_TREASURE);
						point = sprite.getFxPoint();
						FxManager.instance.addFx(new ScoreFx(collectedCoins + " " + ResourceManager.getInstance().getString("default", "textCoins"), 0xFFFF00, GameDefs.k_FX_OUTLINE_COLOR, GameDefs.k_FX_TEXT_FORMAT, 1000, 0), point.x, point.y);
						if (collectedCoins >= (GameDefs.k_GAME_TREASURE_COINS_MIN + GameDefs.k_GAME_TREASURE_COINS_MAX) / 2)
						{
							SoundManager.instance.play(FileDefs.k_URL_SFX_COINS_1);
						}
						else
						{
							SoundManager.instance.play(FileDefs.k_URL_SFX_COINS_2);
						}
						break;
					
					case RawTilesDefs.k_POTION:
						var potion:Potion = sprite as Potion;
						potion.pickUp();
						addHealth(GameDefs.k_MAX_HEALTH);
						addScore(GameDefs.k_SCORE_POTION);
						point = sprite.getFxPoint();
						FxManager.instance.addFx(new ScoreFx(ResourceManager.getInstance().getString("default", "textHealth"), 0x00FF00, GameDefs.k_FX_OUTLINE_COLOR, GameDefs.k_FX_TEXT_FORMAT, 1000, 0), point.x, point.y);
						SoundManager.instance.play(FileDefs.k_URL_SFX_POTION);
						break;
					
					case RawTilesDefs.k_GEMSTONES:
						var gemstones:Gemstones = sprite as Gemstones;
						gemstones.pickUp();
						addScore(GameDefs.k_SCORE_GEMSTONES);
						point = sprite.getFxPoint();
						FxManager.instance.addFx(new ScoreFx(GameDefs.k_SCORE_GEMSTONES + " " + ResourceManager.getInstance().getString("default", "textPoints"), 0xFFCC00, GameDefs.k_FX_OUTLINE_COLOR, GameDefs.k_FX_TEXT_FORMAT, 1000, 0), point.x, point.y);
						if (Math.random() < 0.5)
						{
							SoundManager.instance.play(FileDefs.k_URL_SFX_COINS_1);
						}
						else
						{
							SoundManager.instance.play(FileDefs.k_URL_SFX_COINS_2);
						}
						break;
					
					case RawTilesDefs.k_ENEMY_1:
					case RawTilesDefs.k_ENEMY_2:
					case RawTilesDefs.k_ENEMY_3:
					case RawTilesDefs.k_ENEMY_4:
					case RawTilesDefs.k_ENEMY_5:
					case RawTilesDefs.k_ENEMY_6:
					case RawTilesDefs.k_ENEMY_7:
					case RawTilesDefs.k_ENEMY_8:
					case RawTilesDefs.k_ENEMY_9:
					case RawTilesDefs.k_ENEMY_10:
						var enemy:Enemy = sprite as Enemy;
						if (enemy.isAlive())
						{
							state = new FightState(m_subStateMachine, this, enemy, moveDir);
							m_subStateMachine.setState(state);
						}
						return k_STOP_AND_IDLE;
						
					case RawTilesDefs.k_DOOR_BUTTON_1:
					case RawTilesDefs.k_DOOR_BUTTON_2:
					case RawTilesDefs.k_DOOR_BUTTON_3:
					case RawTilesDefs.k_DOOR_BUTTON_4:
						var doorButton:DoorButton = sprite as DoorButton;
						doorButton.operate();
						SoundManager.instance.play(FileDefs.k_URL_SFX_BUTTON);
						break;
					
					case RawTilesDefs.k_DOOR_COLORS_1:
					case RawTilesDefs.k_DOOR_COLORS_2:
					case RawTilesDefs.k_DOOR_COLORS_3:
					case RawTilesDefs.k_DOOR_COLORS_4:
					case RawTilesDefs.k_DOOR_COLORS_OPEN_1:
					case RawTilesDefs.k_DOOR_COLORS_OPEN_2:
					case RawTilesDefs.k_DOOR_COLORS_OPEN_3:
					case RawTilesDefs.k_DOOR_COLORS_OPEN_4:
						var doorColors:DoorColors = sprite as DoorColors;
						if (doorColors.currentState == Door.k_STATE_CLOSED)
						{
							point = sprite.getFxPoint();
							FxManager.instance.addFx(new ScoreFx(ResourceManager.getInstance().getString("default", "textLocked"), 0xFFFFFF, GameDefs.k_FX_OUTLINE_COLOR, GameDefs.k_FX_TEXT_FORMAT, 1500, 0), point.x, point.y);
							SoundManager.instance.play(FileDefs.k_URL_SFX_DOOR_LOCKED);
						}
						return (doorColors.currentState == Door.k_STATE_OPEN) ? k_CONTINUE : k_STOP_AND_IDLE;

				}
			}
			
			switch (mapTile)
			{
				case RawTilesDefs.k_FLOOR:
					m_changed = true;
					return k_CONTINUE;

				case RawTilesDefs.k_SECRET:
					m_changed = true;
					m_gameMap.setRawTile(rawColumn, rawRow, RawTilesDefs.k_FLOOR, true);
					addScore(GameDefs.k_SCORE_SECRET_WAY);
					startAnimFx(ObjectsDefs.k_FX_DUST, rawColumn, rawRow);
					SoundManager.instance.play(FileDefs.k_URL_SFX_SECRET_WAY);
					return k_CONTINUE;
			}
			return k_STOP_AND_IDLE;
		}
		
		private function checkReachedTile(rawColumn:int, rawRow:int):int
		{
			var tile:int = m_gameMap.getRawTile(rawColumn, rawRow);
			var objectTile:int = tile & RawTilesDefs.k_MASK_OBJECT;
			
			if (objectTile != 0)
			{
				var sprite:GameSprite = m_gameMap.getSpriteFromMap(rawColumn, rawRow);
				switch (objectTile)
				{
					case RawTilesDefs.k_MESSAGE:
						var message:Message = sprite as Message;
						message.show();
						return k_STOP_AND_IDLE;
						
					case RawTilesDefs.k_BROKEN_FLOOR_2_BAD:
					case RawTilesDefs.k_HOLE:
						var brokenFloor:BrokenFloor = sprite as BrokenFloor;
						if (objectTile == RawTilesDefs.k_BROKEN_FLOOR_2_BAD)
						{
							SoundManager.instance.play(FileDefs.k_URL_SFX_SECRET_WAY);
							brokenFloor.brake();
						}
						m_gameMap.mainCharacter.fall();
						kill(1500);
						return k_STOP;
				}
			}
			return k_CONTINUE;
		}
		
		private function checkLeftTile(rawColumn:int, rawRow:int):void
		{
			var tile:int = m_gameMap.getRawTile(rawColumn, rawRow);
			var objectTile:int = tile & RawTilesDefs.k_MASK_OBJECT;
			
			if (objectTile != 0)
			{
				var sprite:GameSprite = m_gameMap.getSpriteFromMap(rawColumn, rawRow);
				switch (objectTile)
				{
					case RawTilesDefs.k_BROKEN_FLOOR:
						var brokenFloor:BrokenFloor = sprite as BrokenFloor;
						brokenFloor.brake();
						SoundManager.instance.play(FileDefs.k_URL_SFX_SECRET_WAY);
						break;
				}
			}
		}
		
		public function startAnimFx(objectId:int, rawColumn:int, rawRow:int):void
		{
			var x:Number = rawColumn * GameDefs.k_TILE_WIDTH * 2 + GameDefs.k_TILE_WIDTH - m_gameMap.mainScrollMap.scrollX;
			var y:Number = rawRow * GameDefs.k_TILE_HEIGHT * 2 + GameDefs.k_TILE_HEIGHT - m_gameMap.mainScrollMap.scrollY;
			FxManager.instance.addFx(new AnimFx(m_spritesLoader.spriteClasses[objectId]), x, y);
		}
		
		public function get gameMap():GameMap
		{
			return m_gameMap;
		}
		
		public function get health():int
		{
			return m_health;
		}
		
		public function addHealth(value:int):void
		{
			m_health += value;
			if (m_health <= 0)
			{
				kill(1000);
			}
			else
			{
				if (m_health > GameDefs.k_MAX_HEALTH)
				{
					m_health = GameDefs.k_MAX_HEALTH;
				}
				m_hud.health = m_health;
			}
		}
		
		public function kill(delayBeforeGameOver:int):void
		{
			m_health = 0;
			var state:State = new GameOverState(m_subStateMachine, m_stateMachine, m_mapInfo, m_seconds, m_cameFrom, delayBeforeGameOver);
			m_subStateMachine.setState(state);
			closeHud();
			m_hud.health = m_health;
		}

		public function get coins():int
		{
			return m_coins;
		}
		
		public function addCoins(value:int):void
		{
			m_coins += value;
			m_hud.coins = m_coins;
		}

		public function get keys():int
		{
			return m_keys;
		}
		
		public function addKeys(value:int):void
		{
			m_keys += value;
			m_hud.keys = m_keys;
		}
		
		public function get score():int
		{
			return m_score;
		}

		public function addScore(value:int):void
		{
			m_score += value;
			m_hud.score = m_score;
		}

		public function getEquipment(type:int):int
		{
			return m_equipment[type];
		}

		public function setEquipment(type:int, value:int):void
		{
			m_equipment[type] = value;
			switch (type)
			{
				case k_EQUIPMENT_ARMOR:
					m_gameMap.mainCharacter.symbolArmor = (value > 0) ? "Armor" + value : null;
					break;
				
				case k_EQUIPMENT_SHIELD:
					m_gameMap.mainCharacter.symbolShieldFront = (value > 0) ? "Shield" + value : null;
					m_gameMap.mainCharacter.symbolShieldBack = (value > 0) ? "ShieldBack" + value : null;
					break;

				case k_EQUIPMENT_WEAPON:
					m_gameMap.mainCharacter.symbolWeapon = (value > 0) ? "Sword" + value : null;
					m_gameMap.mainCharacter.attackComeFactor = 0.4 - (value / 10) * 0.4;
					break;
			}
			m_gameMap.mainCharacter.refreshAnimation();
		}
		
		public function addSeconds(seconds:Number):void
		{
			m_seconds += seconds;
		}
		
		private function onHudClick(e:MouseEvent):void
		{
			var state:State = null;
			var window:PopupWindow = null;
			var buttonName:String = e.target.name as String;
			
			switch (buttonName)
			{
				case "buttonExit":
					if (m_changed && m_mapInfo.published && m_subStateMachine.currentState == null && !SocialUserManager.instance.isGuest())
					{
						window = new PopupWindow(PopupWindow.k_TYPE_YES_NO, ResourceManager.getInstance().getString("default", "textAskSaveGame"), false);
						window.ui.addEventListener(MouseEvent.CLICK, onExitClick, false, 0, true);
						window.open();
					}
					else
					{
						returnFromGame(m_stateMachine, m_cameFrom, m_mapInfo);
					}
					break;
				
				case "buttonSave":
					if (SocialUserManager.instance.isGuest())
					{
						window = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textOnlySocial"));
						window.open();
					}
					else if (!m_mapInfo.published)
					{
						window = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textNotSavingUnpublished"));
						window.open();
					}
					else if (m_subStateMachine.currentState != null)
					{
						window = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textNotSavingFighting"));
						window.open();
					}
					else
					{
						save(false);
					}
					break;
				
				case "buttonHelp":
					m_hud.setHelpGlowVisible(false);
					showHelp();
					break;
			}
		}
		
		private function onSfxOption(e:Event):void
		{
			if (e.type == UserOptions.k_SFX)
			{
				if (!UserOptions.instance.getBoolean(UserOptions.k_SFX) && m_stepsPlayer != null)
				{
					m_stepsPlayer.stop(0);
				}
			}
		}

		private function onExitClick(e:MouseEvent):void
		{
			if (e.target.name == PopupWindow.k_BUTTON_YES)
			{
				save(true);
			}
			else if (e.target.name == PopupWindow.k_BUTTON_NO)
			{
				returnFromGame(m_stateMachine, m_cameFrom, m_mapInfo);
			}
		}

		private function setOverlaySprite(sprite:GameSprite):void
		{
			m_overlayGameSprite = sprite;
			m_gameMap.removeSpriteFromMap(sprite, false);
			MagicStone.bgContainer.addChild(sprite);
		}
		
		private function showHelp():void
		{
			var window:HelpWindow = new HelpWindow(getTextArray("textHelpInGameTitle", 7), getTextArray("textHelpInGame", 7));
			window.open();
		}
		
		public static function getTextArray(name:String, amount:int):Array
		{
			var array:Array = new Array();
			var res:IResourceManager = ResourceManager.getInstance();
			for (var i:int = 1; i <= amount; i++)
			{
				array.push(res.getString("default", name + i));
			}
			return array;
		}
		
		private function save(exitAfterSave:Boolean = false):void
		{
			m_exitAfterSave = exitAfterSave;
			
			m_savePopup = new PopupWindow(PopupWindow.k_TYPE_WAIT, ResourceManager.getInstance().getString("default", "textGameSaved"));
			m_savePopup.open();
			
			var savegame:Savegame = new Savegame();
			savegame.mapId = m_mapInfo.mapId;
			savegame.mcColumn = m_gameMap.mainCharacter.rawColumn;
			savegame.mcRow = m_gameMap.mainCharacter.rawRow;
			savegame.health = m_health;
			savegame.numCoins = m_coins;
			savegame.numKeys = m_keys;
			savegame.armor = m_equipment[k_EQUIPMENT_ARMOR];
			savegame.shield = m_equipment[k_EQUIPMENT_SHIELD];
			savegame.weapon = m_equipment[k_EQUIPMENT_WEAPON];
			savegame.time = m_seconds;
			savegame.score = m_score;
			
			var data:ByteArray = new ByteArray();
			m_gameMap.serialize(data);
			savegame.dataDiff = ArrayUtils.encodeDifference(m_originalLevelData, data);
			
			GameServer.instance.sendSavegame(SocialUserManager.instance.playerUserId, savegame, onSaved);
		}
		
		private function onSaved(answer:Answer):void
		{
			if (answer.isOk)
			{
				m_changed = false;
				m_savePopup.ui.addEventListener(MouseEvent.CLICK, onSavePopupClicked, false, 0, true);
				m_savePopup.waitingDone();
			}
			else
			{
				m_savePopup.close();
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorGameSaving"));
				popup.open();
			}
			MenuMainState.resetSavegameInfo();
		}
		
		private function onSavePopupClicked(e:MouseEvent):void
		{
			if (e.target.name == PopupWindow.k_BUTTON_OK)
			{
				if (m_exitAfterSave)
				{
					returnFromGame(m_stateMachine, m_cameFrom, m_mapInfo);
				}
			}
		}
		
		public static function requestGameSounds():void
		{
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_DOOR, FileDefs.k_URL_SFX_DOOR);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_DOOR_LOCKED, FileDefs.k_URL_SFX_DOOR_LOCKED);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_STEPS, FileDefs.k_URL_SFX_STEPS);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_SECRET_WAY, FileDefs.k_URL_SFX_SECRET_WAY);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_KEY, FileDefs.k_URL_SFX_KEY);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_COINS_1, FileDefs.k_URL_SFX_COINS_1);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_COINS_2, FileDefs.k_URL_SFX_COINS_2);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_POTION, FileDefs.k_URL_SFX_POTION);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_BUTTON, FileDefs.k_URL_SFX_BUTTON);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_ATTACK_SWORD, FileDefs.k_URL_SFX_ATTACK_SWORD);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_ATTACK_SWORD_BLOCKED, FileDefs.k_URL_SFX_ATTACK_SWORD_BLOCKED);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_PAY, FileDefs.k_URL_SFX_PAY);
			SoundManager.instance.request(Config.resPath + FileDefs.k_URL_SFX_THINGS, FileDefs.k_URL_SFX_THINGS);
		}
		
		private function releaseGameSounds():void
		{
			SoundManager.instance.release(FileDefs.k_URL_SFX_DOOR);
			SoundManager.instance.release(FileDefs.k_URL_SFX_DOOR_LOCKED);
			SoundManager.instance.release(FileDefs.k_URL_SFX_STEPS);
			SoundManager.instance.release(FileDefs.k_URL_SFX_SECRET_WAY);
			SoundManager.instance.release(FileDefs.k_URL_SFX_KEY);
			SoundManager.instance.release(FileDefs.k_URL_SFX_COINS_1);
			SoundManager.instance.release(FileDefs.k_URL_SFX_COINS_2);
			SoundManager.instance.release(FileDefs.k_URL_SFX_POTION);
			SoundManager.instance.release(FileDefs.k_URL_SFX_BUTTON);
			SoundManager.instance.release(FileDefs.k_URL_SFX_ATTACK_SWORD);
			SoundManager.instance.release(FileDefs.k_URL_SFX_ATTACK_SWORD_BLOCKED);
			SoundManager.instance.release(FileDefs.k_URL_SFX_PAY);
			SoundManager.instance.release(FileDefs.k_URL_SFX_THINGS);
		}
		
		public static function returnFromGame(stateMachine:StateMachine, cameFrom:int, mapInfo:MapInfo = null):void
		{
			var state:State;
			if (cameFrom == k_CAME_FROM_MENU)
			{
				state = new MenuState(stateMachine);
			}
			else
			{
				state = new MapLoaderState(stateMachine, MapLoaderState.k_GO_TO_MAP_EDITOR, cameFrom, mapInfo);
			}
			stateMachine.setState(state);
		}
		
	}
}