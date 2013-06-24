package game.map
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import flashx.textLayout.elements.BreakElement;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;
	
	import inutilib.DisplayUtils;
	import inutilib.GameTime;
	import inutilib.media.ImageManager;

	public class MainCharacter extends GameSprite
	{
		public static const k_STATE_IDLE:int = 0;
		public static const k_STATE_WALK:int = 1;
		public static const k_STATE_ATTACK:int = 2;
		public static const k_STATE_HURT:int = 3;
		public static const k_STATE_BLOCK:int = 4;
		public static const k_STATE_DIE:int = 5;
		public static const k_STATE_FALL:int = 6;
		
		private static const k_HIT_LABEL:String = "hit";
		
		private static const k_ARMOR_NAME:String = "armor";
		private static const k_BODY_PARTS:Array = [
			"bodyFront",
			"bodySide",
			"bodyBack",
			"armFront",
			"armFront.",
			"armSide",
			"armBack",
			"armBack.",
			];
		
		private var m_state:int;
		private var m_direction:int;
		private var m_onReachHandler:Function;
		private var m_movedPixels:Number = 0;
		private var m_onAttackHandler:Function;
		private var m_symbolArmor:String;
		private var m_symbolShieldFront:String;
		private var m_symbolShieldBack:String;
		private var m_symbolWeapon:String;
		private var m_attackComeFactor:Number = 0;

		
		public function MainCharacter(gameMap:GameMap)
		{
			super(gameMap);
			var spriteClass:Class = m_gameMap.spriteClasses[ObjectsDefs.k_MAIN_CHARACTER];
			movieClip = new spriteClass as MovieClip;
			
			m_state = k_STATE_IDLE;
			m_direction = k_DIR_DOWN;
			refreshAnimation();
		}
		
		override public function createNew():GameSprite
		{
			var copy:MainCharacter = new MainCharacter(m_gameMap);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function get rawTile():int
		{
			return RawTilesDefs.k_MAIN_CHARACTER;
		}
		
		public function set symbolArmor(symbol:String):void
		{
			m_symbolArmor = symbol;
		}
		
		public function set symbolShieldFront(symbol:String):void
		{
			m_symbolShieldFront = symbol;
		}

		public function set symbolShieldBack(symbol:String):void
		{
			m_symbolShieldBack = symbol;
		}

		public function set symbolWeapon(symbol:String):void
		{
			m_symbolWeapon = symbol;
		}
		
		public function set attackComeFactor(factor:Number):void
		{
			m_attackComeFactor = factor;
		}
		
		public function set onReachHandler(func:Function):void
		{
			m_onReachHandler = func;
		}
		
		public function set onAttackHandler(func:Function):void
		{
			m_onAttackHandler = func; 
		}

		public function isIdle():Boolean
		{
			return (m_state == k_STATE_IDLE);
		}

		public function look(direction:int):void
		{
			setRawPosition(m_rawColumn, m_rawRow);
			m_state = k_STATE_IDLE;
			m_direction = direction;
			refreshAnimation();
		}
		
		public function startWalking(direction:int):void
		{
			if (direction != m_direction)
			{
				setRawPosition(m_rawColumn, m_rawRow);
			}
			m_state = k_STATE_WALK;
			m_direction = direction;
			refreshAnimation();
		}
		
		public function stopWalking():void
		{
			idle();
		}
		
		public function idle():void
		{
			m_state = k_STATE_IDLE;
			setRawPosition(m_rawColumn, m_rawRow);
			refreshAnimation();
		}
		
		public function attack():void
		{
			m_state = k_STATE_ATTACK;
			refreshAnimation();
		}
		
		public function hurt():void
		{
			m_state = k_STATE_HURT;
			refreshAnimation();
		}
		
		public function block():void
		{
			m_state = k_STATE_BLOCK;
			refreshAnimation();
		}
		
		public function die():void
		{
			m_state = k_STATE_DIE;
			refreshAnimation();
		}

		public function fall():void
		{
			m_state = k_STATE_FALL;
			refreshAnimation();
		}
		
		override public function update():void
		{
			var animMovieClip:MovieClip = movieClip.getChildAt(0) as MovieClip;

			switch (m_state)
			{
				case k_STATE_IDLE:
					break;
				
				case k_STATE_WALK:
					var move:Number = GameDefs.k_TILE_WIDTH * 4 * GameTime.frameMillis / 1000;
					switch (m_direction)
					{
						case k_DIR_UP:
							mapY -= move;
							break;
						
						case k_DIR_DOWN:
							mapY += move;
							break;
						
						case k_DIR_LEFT:
							mapX -= move;
							break;
						
						case k_DIR_RIGHT:
							mapX += move;
							break;
					}
					m_movedPixels += move;
					if (m_movedPixels >= GameDefs.k_TILE_WIDTH * 2)
					{
						switch (m_direction)
						{
							case k_DIR_UP:
								m_rawRow--;
								break;
							
							case k_DIR_DOWN:
								m_rawRow++;
								break;
							
							case k_DIR_LEFT:
								m_rawColumn--;
								break;
							
							case k_DIR_RIGHT:
								m_rawColumn++;
								break;
						}
						refreshZOrder(m_rawColumn, m_rawRow);
						m_movedPixels -= GameDefs.k_TILE_WIDTH * 2;
						m_onReachHandler();
					}
					break;
				
				case k_STATE_ATTACK:
					if (animMovieClip.currentFrameLabel == k_HIT_LABEL && m_onAttackHandler != null)
					{
						m_onAttackHandler();
					}
					if (m_attackComeFactor != 0)
					{
						// move nearer to attack
						var factor:Number = animMovieClip.currentFrame / animMovieClip.totalFrames;
						var moveFactor:Number = (1 - Math.cos(factor * 2 * Math.PI)) / 2;
						var maxDist:Number = GameDefs.k_TILE_WIDTH * 2 * m_attackComeFactor;
						switch (m_direction)
						{
							case k_DIR_UP:
								movieClip.y = -moveFactor * maxDist;
								break;
							
							case k_DIR_DOWN:
								movieClip.y = moveFactor * maxDist;
								break;
							
							case k_DIR_LEFT:
								movieClip.x = -moveFactor * maxDist;
								break;
							
							case k_DIR_RIGHT:
								movieClip.x = moveFactor * maxDist;
								break;
						}
					}
					if (animMovieClip.currentFrame == animMovieClip.totalFrames)
					{
						idle();
					}
					break;
				
				case k_STATE_HURT:
				case k_STATE_BLOCK:
					if (animMovieClip.currentFrame == animMovieClip.totalFrames)
					{
						idle();
					}
					break;
				
				case k_STATE_DIE:
				case k_STATE_FALL:
					if (animMovieClip.currentFrame == animMovieClip.totalFrames)
					{
						animMovieClip.stop();
					}
					break;

			}
		}
		
		public function refreshAnimation():void
		{
			// animation
			
			var frame:String;
			switch (m_state)
			{
				case k_STATE_IDLE:
					frame = "idle";
					break;
				
				case k_STATE_WALK:
					frame = "walk";
					break;

				case k_STATE_ATTACK:
					frame = "attack";
					break;
				
				case k_STATE_HURT:
					frame = "hurt";
					break;
				
				case k_STATE_BLOCK:
					frame = "block";
					break;
				
				case k_STATE_DIE:
					frame = "die";
					break;

				case k_STATE_FALL:
					frame = "fall";
					break;
			}

			switch (m_direction)
			{
				case k_DIR_UP:
					frame += "Up";
					break;

				case k_DIR_DOWN:
					frame += "Down";
					break;

				case k_DIR_LEFT:
					frame += "Left";
					break;

				case k_DIR_RIGHT:
					frame += "Right";
					break;
			}
			movieClip.gotoAndStop(frame);
			
			addEquipment();
		}
		
		private function addEquipment():void
		{
			var animSprite:Sprite = movieClip.getChildAt(0) as Sprite;
			var map:Object = new Object();
			var placeholderSprite:Sprite;
			var spriteClass:Class;
			var sprite:Sprite;

			DisplayUtils.collectAllSprites(animSprite, map);

			// armor
			
			if (m_symbolArmor != null)
			{
				for each (var bodyPart:String in k_BODY_PARTS)
				{
					addArmorSprites(animSprite, map, bodyPart);
				}
			}
			
			// shield
			
			var shieldName:String = (m_direction == k_DIR_DOWN) ? "shieldFront" : "shieldBack";
			var shieldSymbol:String = (m_direction == k_DIR_DOWN) ? m_symbolShieldFront : m_symbolShieldBack;
			placeholderSprite = map[shieldName] as Sprite;
			if (shieldSymbol != null)
			{
				replacePlaceholderSprite(placeholderSprite, shieldSymbol);
				placeholderSprite.visible = true;
			}
			else
			{
				placeholderSprite.visible = false;
			}
			
			// sword
			
			placeholderSprite = map["sword"] as Sprite;
			if (m_symbolWeapon != null)
			{
				replacePlaceholderSprite(placeholderSprite, m_symbolWeapon);
				placeholderSprite.visible = true;
			}
			else
			{
				placeholderSprite.visible = false;
			}
		}
		
		private function replacePlaceholderSprite(placeholderSprite:Sprite, symbol:String):void
		{
			// remove dummy
			if (placeholderSprite.numChildren > 0)
			{
				placeholderSprite.removeChildAt(0);
			}
			// add sprite
			var spriteClass:Class = ImageManager.instance.getSpriteClass(Config.resPath + FileDefs.k_URL_EQUIPMENT, symbol);
			var sprite:Sprite = new spriteClass as Sprite;
			placeholderSprite.addChild(sprite);
		}

		private function addArmorSprites(animSprite:Sprite, map:Object, bodyPart:String):void
		{
			if (map.hasOwnProperty(bodyPart))
			{
				var bodyPartSprite:Sprite = map[bodyPart];
				
				// remove old armor
				var oldSprite:Sprite = bodyPartSprite.getChildByName(k_ARMOR_NAME) as Sprite;
				if (oldSprite != null)
				{
					bodyPartSprite.removeChild(oldSprite);
				}
				
				// add new armor
				if (bodyPart.lastIndexOf(".") > 0)
				{
					bodyPart = bodyPart.substr(0, bodyPart.length - 1);
				}
				var url:String = Config.resPath + FileDefs.k_URL_EQUIPMENT;
				var symbol:String = m_symbolArmor + "_" + bodyPart;
				if (ImageManager.instance.existsSpriteClass(url, symbol))
				{
					var spriteClass:Class = ImageManager.instance.getSpriteClass(url, symbol);
					var sprite:Sprite = new spriteClass as Sprite;
					sprite.name = k_ARMOR_NAME;
					bodyPartSprite.addChild(sprite);
				}
			}
		}
	}
}