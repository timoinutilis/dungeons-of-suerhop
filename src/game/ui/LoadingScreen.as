package game.ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import game.GameDefs;
	import game.MagicStone;
	
	public class LoadingScreen extends Sprite
	{
		[Embed(source = "../../../embed/loading_anims.swf", symbol="LoadingAnim")]
		private var LoadingAnim:Class;
		
		private static const k_BAR_WIDTH:Number = 200;
		private static const k_BAR_HEIGHT:Number = 2;
		private static const k_BAR_COLOR_EMPTY:int = 0x333333;
		private static const k_BAR_COLOR_FULL:int = 0xAA0000;

		
		private var m_progressBarEmpty:Sprite;
		private var m_progressBarFull:Sprite;
		
		public function LoadingScreen(width:int, height:int, withProgressBar:Boolean)
		{
			super();
			graphics.beginFill(GameDefs.k_BG_COLOR);
			graphics.drawRect(0, 0, width, height);
			
			var movieClip:MovieClip = new LoadingAnim as MovieClip;
			movieClip.x = width / 2;
			movieClip.y = height / 2;
			addChild(movieClip);
			
			if (withProgressBar)
			{
				m_progressBarEmpty = new Sprite();
				m_progressBarEmpty.graphics.beginFill(k_BAR_COLOR_EMPTY);
				m_progressBarEmpty.graphics.drawRect(0, 0, k_BAR_WIDTH, k_BAR_HEIGHT);
				
				m_progressBarFull = new Sprite();
				m_progressBarFull.graphics.beginFill(k_BAR_COLOR_FULL);
				m_progressBarFull.graphics.drawRect(0, 0, k_BAR_WIDTH, k_BAR_HEIGHT);
				m_progressBarFull.width = 1;
				
				var barX:Number = (width - k_BAR_WIDTH) / 2;
				var barY:Number = height - 50;
				m_progressBarEmpty.x = barX;
				m_progressBarEmpty.y = barY;
				m_progressBarFull.x = barX;
				m_progressBarFull.y = barY;

				addChild(m_progressBarEmpty);
				addChild(m_progressBarFull);
			}
		}
		
		public function set progress(value:Number):void
		{
			if (m_progressBarFull != null)
			{
				m_progressBarFull.scaleX = Math.min(1, value);
			}
		}
	}
}