package game.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import game.FileDefs;
	import game.GameDefs;
	
	import de.inutilis.inutilib.DisplayUtils;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.ProgressBar;
	import de.inutilis.inutilib.ui.Window;
	
	public class InGameWindow extends Window
	{
		[Embed(source = "../../../embed/ui_ingame.swf", symbol="UIIngame")]
		private var UIIngame:Class;
		
		private static const k_VALUE_COINS:int = 0;
		private static const k_VALUE_KEYS:int = 1;
		private static const k_VALUE_SCORE:int = 2;
		private static const k_VALUE_HEALTH:int = 3;
		
		private var m_textCoins:TextField;
		private var m_textKeys:TextField;
		private var m_textScore:TextField;
		private var m_textHealth:TextField;
		private var m_coin:MovieClip;
		private var m_key:MovieClip;
		private var m_star:MovieClip;
		private var m_helpGlow:MovieClip;
		
		private var m_actualValues:Array;
		private var m_shownValues:Array;
		private var m_lastDiff:Array;
		
		private var m_barHealth:ProgressBar;

		public function InGameWindow(container:DisplayObjectContainer, startCoins:int, startKeys:int, startScore:int, startHealth:int)
		{
			var ui:Sprite = new UIIngame as Sprite;
			super(container, ui, 300, PositionRectangle.k_TOP_CENTER);
			
			m_actualValues = [startCoins, startKeys, startScore, startHealth];
			m_shownValues = [startCoins, startKeys, startScore, startHealth];
			m_lastDiff = [0, 0, 0, 0];

			m_textCoins = DisplayUtils.setText(ui, "textCoins", "0", GameDefs.k_TEXT_FORMAT_BOLD);
			m_textKeys = DisplayUtils.setText(ui, "textKeys", "0", GameDefs.k_TEXT_FORMAT_BOLD);
			m_textScore = DisplayUtils.setText(ui, "textScore", "0", GameDefs.k_TEXT_FORMAT_BOLD);
			m_textHealth = DisplayUtils.setText(ui, "textHealth", "0", GameDefs.k_TEXT_FORMAT_BOLD);
			m_coin = ui.getChildByName("coin") as MovieClip;
			m_key = ui.getChildByName("key") as MovieClip;
			m_star = ui.getChildByName("star") as MovieClip;
			m_helpGlow = ui.getChildByName("animHelpGlow") as MovieClip;
			
			m_barHealth = new ProgressBar(ui.getChildByName("barHealth") as Sprite, GameDefs.k_MAX_HEALTH, startHealth);
			
			m_coin.stop();
			m_key.stop();
			m_star.stop();
			m_helpGlow.mouseEnabled = false;
			m_helpGlow.mouseChildren = false;
			m_helpGlow.visible = false;
			
			refreshTexts();
		}
		
		public function set coins(value:int):void
		{
			m_coin.gotoAndPlay(2);
			m_lastDiff[k_VALUE_COINS] = value - m_actualValues[k_VALUE_COINS];
			m_actualValues[k_VALUE_COINS] = value;
		}

		public function set keys(value:int):void
		{
			m_key.gotoAndPlay(2);
			m_lastDiff[k_VALUE_KEYS] = value - m_actualValues[k_VALUE_KEYS];
			m_actualValues[k_VALUE_KEYS] = value;
		}

		public function set score(value:int):void
		{
			m_star.gotoAndPlay(2);
			m_lastDiff[k_VALUE_SCORE] = value - m_actualValues[k_VALUE_SCORE];
			m_actualValues[k_VALUE_SCORE] = value;
		}

		public function set health(value:int):void
		{
			m_lastDiff[k_VALUE_HEALTH] = value - m_actualValues[k_VALUE_HEALTH];
			m_actualValues[k_VALUE_HEALTH] = value;
			m_barHealth.currentValue = value;
		}
		
		public function setHelpGlowVisible(visible:Boolean):void
		{
			m_helpGlow.visible = visible;
		}
		
		private function refreshTexts():void
		{
			m_textCoins.text = m_shownValues[k_VALUE_COINS].toString();
			m_textKeys.text = m_shownValues[k_VALUE_KEYS].toString();
			m_textScore.text = m_shownValues[k_VALUE_SCORE].toString();
			m_textHealth.text = m_shownValues[k_VALUE_HEALTH] + " / " + GameDefs.k_MAX_HEALTH;
		}

		override public function update():void
		{
			super.update();
			
			// icon animations
			if (m_coin.currentFrame == m_coin.totalFrames)
			{
				m_coin.gotoAndStop(1);
			}
			if (m_key.currentFrame == m_key.totalFrames)
			{
				m_key.gotoAndStop(1);
			}
			if (m_star.currentFrame == m_star.totalFrames)
			{
				m_star.gotoAndStop(1);
			}
			
			// text fields
			var changed:Boolean = false;
			for (var i:int = 0; i < m_actualValues.length; i++)
			{
				if (m_actualValues[i] != m_shownValues[i])
				{
					var diff:int = m_lastDiff[i];
					var frameDiff:int = diff / 30;
					if (frameDiff == 0)
					{
						frameDiff = (diff > 0) ? 1 : -1;
					}
					m_shownValues[i] += frameDiff;
					if (   (diff > 0 && m_shownValues[i] > m_actualValues[i])
						|| (diff < 0 && m_shownValues[i] < m_actualValues[i]) )
					{
						m_shownValues[i] = m_actualValues[i];
						m_lastDiff[i] = 0;
					}
					changed = true;
				}
			}
			if (changed)
			{
				refreshTexts();
			}
			
			// health bar
			m_barHealth.update();
		}
	}
}