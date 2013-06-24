package game.map
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	import game.FileDefs;
	import game.constants.ObjectsDefs;
	import game.constants.RawTilesDefs;
	
	import inutilib.media.SoundManager;

	public class DoorButton extends GameSprite
	{
		private var m_color:int;

		public function DoorButton(gameMap:GameMap, color:int)
		{
			super(gameMap);
			
			var spriteClass:Class = m_gameMap.spriteClasses[ObjectsDefs.k_DOOR_BUTTON];
			movieClip = new spriteClass as MovieClip;
			movieClip.gotoAndStop(1);

			this.color = color;
			zOrderOffset = -1;
		}
		
		override public function createNew():GameSprite
		{
			var copy:DoorButton = new DoorButton(m_gameMap, m_color);
			copy.setRawPosition(m_rawColumn, m_rawRow);
			return copy as GameSprite;
		}

		override public function get rawTile():int
		{
			return RawTilesDefs.k_DOOR_BUTTON_1 + (m_color << RawTilesDefs.k_SHIFT_OBJECT);
		}
		
		public function set color(value:int):void
		{
			m_color = value;
			var buttonMovieClip:MovieClip = movieClip.getChildAt(1) as MovieClip;
			buttonMovieClip.gotoAndStop(m_color + 1);
		}
		
		public function get color():int
		{
			return m_color;
		}
		
		public function operate():void
		{
			movieClip.gotoAndPlay(1);
		}
		
		override public function update():void
		{
			if (movieClip.currentFrame == movieClip.totalFrames)
			{
				movieClip.gotoAndStop(1);
			}
			else if (movieClip.currentFrame == int(movieClip.totalFrames / 2))
			{
				toggleDoors();
			}
		}
		
		private function toggleDoors():void
		{
			var sprites:Array = m_gameMap.mainScrollMap.mapSprites;
			var operated:Boolean = false;
			var minDist:Number = 12;
			for each (var gameSprite:GameSprite in sprites)
			{
				if (gameSprite is DoorColors)
				{
					var door:DoorColors = gameSprite as DoorColors;
					if (door.color == m_color)
					{
						door.toggle();
						var dist:Number = Point.distance(new Point(m_rawColumn, m_rawRow), new Point(door.rawColumn, door.rawRow));
						if (dist < minDist)
						{
							minDist = dist;
						}
						operated = true;
					}
				}
			}
			if (operated)
			{
				SoundManager.instance.play(FileDefs.k_URL_SFX_DOOR, 0, (15 - minDist) / 15);
			}
		}

		override public function getUnlockLevel():int
		{
			return 2;
		}

		override public function getProblem():String
		{
			var sprites:Array = m_gameMap.mainScrollMap.mapSprites;
			for each (var gameSprite:GameSprite in sprites)
			{
				if (gameSprite is DoorColors)
				{
					var door:DoorColors = gameSprite as DoorColors;
					if (door.color == m_color)
					{
						return null;
					}
				}
			}
			return "There is a button without any matching automatic door. Please put a door with the same color or remove the button!";
		}

	}
}