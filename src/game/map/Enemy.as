package game.map
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import game.GameDefs;
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;
	
	import de.inutilis.inutilib.DisplayUtils;

	public class Enemy extends GameSprite
	{
		[Embed(source = "../../../embed/ui_object.swf", symbol="EnemyGui")]
		private var EnemyGui:Class;
		
		public static const k_MAX_LEVEL:int = 9;

		public static const k_STATE_HIDDEN:int = 0;
		public static const k_STATE_APPEAR:int = 1;
		public static const k_STATE_IDLE:int = 2;
		public static const k_STATE_ATTACK:int = 3;
		public static const k_STATE_HURT:int = 4;
		public static const k_STATE_BLOCK:int = 5;
		public static const k_STATE_DIE:int = 6;
		public static const k_STATE_HIDE:int = 7;
		
		private static const k_HIT_LABEL:String = "hit";
				
		private var m_state:int;
		private var m_direction:int;
		private var m_level:int;
		private var m_editMode:Boolean;
		private var m_levelGui:Sprite;
		private var m_onAttackHandler:Function;
		
		public function Enemy(gameMap:GameMap, level:int, editMode:Boolean, preview:Boolean = false)
		{
			super(gameMap);
			m_editMode = editMode;
			
			var spriteClass:Class = m_gameMap.spriteClasses[ObjectsDefs.k_ENEMY];
			movieClip = new spriteClass as MovieClip;

			setLevel(level);

			if (m_editMode)
			{
				if (!preview)
				{
					m_levelGui = new EnemyGui as Sprite;
					m_levelGui.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
					mouseChildren = true;
					movieClip.mouseEnabled = false;
					movieClip.mouseChildren = false;
					DisplayUtils.setText(m_levelGui, "textLevel", (m_level + 1).toString(), GameDefs.k_TEXT_FORMAT_BOLD);
					addChild(m_levelGui);
				}
				m_state = k_STATE_IDLE;
			}
			else
			{
				visible = false;
				m_state = k_STATE_HIDDEN;
			}
			
			m_direction = k_DIR_DOWN;
			refreshAnimation();
		}
		
		public function get level():int
		{
			return m_level;
		}
		
		private function setLevel(level:int):void
		{
			m_level = level;
			var scale:Number = 0.7 + m_level * 0.6 / k_MAX_LEVEL;
			movieClip.scaleX = scale;
			movieClip.scaleY = scale;
		}
		
		public function set onAttackHandler(func:Function):void
		{
			m_onAttackHandler = func; 
		}
		
		private function refreshGui():void
		{
			var textField:TextField = m_levelGui.getChildByName("textLevel") as TextField;
			textField.text = (m_level + 1).toString();
		}
		
		override public function createNew():GameSprite
		{
			var copy:Enemy = new Enemy(m_gameMap, m_level, true, false);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}
		
		override public function get rawTile():int
		{
			return RawTilesDefs.k_ENEMY_1 + (m_level << RawTilesDefs.k_SHIFT_OBJECT);
		}
		
		public function get currentState():int
		{
			return m_state;
		}
		
		public function set direction(direction:int):void
		{
			m_direction = direction;
			refreshAnimation();
			zOrderOffset = m_direction == k_DIR_UP ? 0 : -1;
		}
		
		public function isIdle():Boolean
		{
			return (m_state == k_STATE_IDLE || m_state == k_STATE_DIE);
		}
		
		public function isAlive():Boolean
		{
			return (m_state != k_STATE_DIE);
		}
		
		public function appear():void
		{
			m_state = k_STATE_APPEAR;
			visible = true;
			refreshAnimation();
		}
		
		public function idle():void
		{
			m_state = k_STATE_IDLE;
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
		
		public function hide():void
		{
			m_state = k_STATE_HIDE;
			refreshAnimation();
		}

		override public function update():void
		{
			var animMovieClip:MovieClip = movieClip.getChildAt(0) as MovieClip;
			switch (m_state)
			{
				case k_STATE_HIDDEN:
					break;
				
				case k_STATE_APPEAR:
					if (animMovieClip.currentFrame == animMovieClip.totalFrames)
					{
						idle();
					}
					break;
				
				case k_STATE_IDLE:
					break;
				
				case k_STATE_ATTACK:
					if (animMovieClip.currentFrameLabel == k_HIT_LABEL && m_onAttackHandler != null)
					{
						m_onAttackHandler();
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
					if (animMovieClip.currentFrame == animMovieClip.totalFrames)
					{
						m_gameMap.removeSpriteFromMap(this, true);
					}
					break;
				
				case k_STATE_HIDE:
					if (animMovieClip.currentFrame == animMovieClip.totalFrames)
					{
						visible = false;
						m_state = k_STATE_HIDDEN;
						refreshAnimation();
					}
					break;
				
			}
		}
		
		private function refreshAnimation():void
		{
			var frame:String;
			switch (m_state)
			{
				case k_STATE_APPEAR:
					frame = "appear";
					break;

				case k_STATE_IDLE:
				case k_STATE_HIDDEN:
					frame = "idle";
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

				case k_STATE_HIDE:
					frame = "hide";
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
			
			if (m_state == k_STATE_HIDDEN)
			{
				(movieClip.getChildAt(0) as MovieClip).stop();
			}
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			switch (buttonName)
			{
				case "buttonUp":
					if (m_level < k_MAX_LEVEL)
					{
						setLevel(m_level + 1);
						m_gameMap.setRawTileObject(m_rawColumn, m_rawRow, rawTile);
						refreshGui();
					}
					break;
				
				case "buttonDown":
					if (m_level > 0)
					{
						setLevel(m_level - 1);
						m_gameMap.setRawTileObject(m_rawColumn, m_rawRow, rawTile);
						refreshGui();
					}
					break;
			}
		}
	}
}