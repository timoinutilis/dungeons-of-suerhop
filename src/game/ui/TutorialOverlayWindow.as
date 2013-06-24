package game.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import game.GameDefs;
	import game.MagicStone;
	
	import de.inutilis.inutilib.DisplayUtils;
	import de.inutilis.inutilib.GameTime;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.Window;
	
	public class TutorialOverlayWindow extends Window
	{
		[Embed(source = "../../../embed/ui_tutorial.swf", symbol="UIKeys")]
		private var UIKeys:Class;
		
		public static const k_TIME:int = 4000;
		
		private var m_timer:int;
		private var m_finished:Boolean;

		public function TutorialOverlayWindow(text:String, windowOffsetY:Number = 0)
		{
			var ui:Sprite = new UIKeys() as Sprite;
			DisplayUtils.setText(ui, "text", text, GameDefs.k_TEXT_FORMAT, true);
			ui.mouseEnabled = false;
			ui.mouseChildren = false;
			
			m_timer = 0;
			
			super(MagicStone.uiContainer, ui, 1000, PositionRectangle.k_BOTTOM_CENTER);
			
			offsetY = windowOffsetY;
		}
		
		override public function update():void
		{
			super.update();
			
			if (!m_finished)
			{
				m_timer += GameTime.frameMillis;
				if (m_timer >= k_TIME)
				{
					close();
					m_finished = true;
				}
			}
		}
	}
}