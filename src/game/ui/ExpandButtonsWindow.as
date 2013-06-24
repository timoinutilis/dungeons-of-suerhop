package game.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	
	import game.MagicStone;
	
	import de.inutilis.inutilib.ui.Window;
	
	public class ExpandButtonsWindow extends Window
	{
		[Embed(source = "../../../embed/ui_editor_tools.swf", symbol="ExpandButtonUp")]
		private var ExpandButtonUp:Class;

		[Embed(source = "../../../embed/ui_editor_tools.swf", symbol="ExpandButtonDown")]
		private var ExpandButtonDown:Class;

		[Embed(source = "../../../embed/ui_editor_tools.swf", symbol="ExpandButtonLeft")]
		private var ExpandButtonLeft:Class;

		[Embed(source = "../../../embed/ui_editor_tools.swf", symbol="ExpandButtonRight")]
		private var ExpandButtonRight:Class;
		
		private var m_buttonUp:SimpleButton;
		private var m_buttonDown:SimpleButton;
		private var m_buttonLeft:SimpleButton;
		private var m_buttonRight:SimpleButton;

		public function ExpandButtonsWindow(container:DisplayObjectContainer)
		{
			var uiSprite:Sprite = new Sprite();
			
			m_buttonUp = new ExpandButtonUp as SimpleButton;
			m_buttonUp.name = "buttonUp";
			uiSprite.addChild(m_buttonUp);

			m_buttonDown = new ExpandButtonDown as SimpleButton;
			m_buttonDown.name = "buttonDown";
			uiSprite.addChild(m_buttonDown);

			m_buttonLeft = new ExpandButtonLeft as SimpleButton;
			m_buttonLeft.name = "buttonLeft";
			uiSprite.addChild(m_buttonLeft);

			m_buttonRight = new ExpandButtonRight as SimpleButton;
			m_buttonRight.name = "buttonRight";
			uiSprite.addChild(m_buttonRight);

			super(container, uiSprite, 0);
		}
		
		public function refreshPositions(mapPosX:Number, mapPosY:Number, mapWidth:Number, mapHeight:Number):void
		{
			var stageWidth:Number = MagicStone.gameStage.stageWidth;
			var stageHeight:Number = MagicStone.gameStage.stageHeight;
			var stageCenterX:Number = stageWidth / 2;
			var stageCenterY:Number = stageHeight / 2;
			
			m_buttonUp.x = stageCenterX;
			m_buttonUp.y = Math.min(mapPosY, stageHeight);

			m_buttonDown.x = stageCenterX;
			m_buttonDown.y = Math.max(mapPosY + mapHeight, 0);

			m_buttonLeft.x = Math.min(mapPosX, stageWidth);
			m_buttonLeft.y = stageCenterY;

			m_buttonRight.x = Math.max(mapPosX + mapWidth, 0);
			m_buttonRight.y = stageCenterY;
		}
	}
}