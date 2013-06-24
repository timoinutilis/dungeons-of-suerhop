package game.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import game.GameDefs;
	import game.MagicStone;
	
	import inutilib.DisplayUtils;
	import inutilib.ui.PositionRectangle;
	import inutilib.ui.RadioButtons;
	import inutilib.ui.ScrollArea;
	import inutilib.ui.ToolTips;
	import inutilib.ui.Window;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	public class EditorToolsWindow extends Window
	{
		[Embed(source = "../../../embed/ui_editor_tools.swf", symbol="UIEditorTools")]
		private var UIEditorTools:Class;
		
		private static const k_NUM_LEVELS:int = 3;
		private static const k_LINE_HEIGHT:Number = 60;

		private var m_toolTipsTools:ToolTips;
		private var m_levelRadioButtons:RadioButtons;
		private var m_toolsButtons:Sprite;
		private var m_toolsRadioButtons:RadioButtons;
		private var m_scrollArea:ScrollArea;
		private var m_unlockLevelTextField:TextField;

		public function EditorToolsWindow(container:DisplayObjectContainer)
		{
			var ui:Sprite = new UIEditorTools as Sprite;
			
			for (var level:int = 1; level <= k_NUM_LEVELS; level++)
			{
				DisplayUtils.setButtonText(ui, "buttonLevel" + level, level.toString(), GameDefs.k_TEXT_FORMAT);
			}

			m_levelRadioButtons = new RadioButtons();
			m_levelRadioButtons.addButtons(ui, "buttonLevel");
			m_levelRadioButtons.setSelectedButtonIndex(0);
			
			m_unlockLevelTextField = DisplayUtils.setText(ui, "textUnlockLevel", "1", GameDefs.k_TEXT_FORMAT);
			m_unlockLevelTextField.mouseEnabled = false;
			
			m_toolsButtons = ui.getChildByName("itemButtons") as Sprite;
			m_scrollArea = new ScrollArea(m_toolsButtons);
			
			m_toolsRadioButtons = new RadioButtons();
			m_toolsRadioButtons.addButtons(ui, "buttonToolTile");
			m_toolsRadioButtons.addButtons(m_toolsButtons, "buttonToolObject");
			m_toolsRadioButtons.setSelectedButtonIndex(1);
			
			ui.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			
			super(container, ui, 300, PositionRectangle.k_BOTTOM_CENTER);

			createToolTipsTools();
			
		}
		
		override public function close():void
		{
			m_toolTipsTools.release();
			super.close();
		}
		
		override public function update():void
		{
			super.update();
			m_scrollArea.update();
		}
		
		public function set selectedLevel(level:int):void
		{
			m_scrollArea.scrollTo((level - 1) * k_LINE_HEIGHT, 500);
		}
		
		public function set unlockLevel(level:int):void
		{
			m_unlockLevelTextField.text = level.toString();
		}

		private function createToolTipsTools():void
		{
			m_toolTipsTools = new ToolTips(ui, MagicStone.gameStage, GameDefs.k_TOOLTIP_TEXT_FORMAT, GameDefs.k_TOOLTIP_OUTLINE_COLOR, PositionRectangle.k_TOP_CENTER);
			
			var res:IResourceManager = ResourceManager.getInstance();

			for (var level:int = 1; level <= k_NUM_LEVELS; level++)
			{
				m_toolTipsTools.addToolTip("buttonLevel" + level, res.getString("default", "toolTipItemsLevel").replace("%1", level));
			}
			m_toolTipsTools.addToolTip("buttonUnlockLevel", res.getString("default", "toolTipUnlockLevel"));
			
			// basic tools
			m_toolTipsTools.addToolTip("buttonToolTile1", res.getString("default", "toolTipRefill"));
			m_toolTipsTools.addToolTip("buttonToolTile2", res.getString("default", "toolTipDig"));
			m_toolTipsTools.addToolTip("buttonToolTile3", res.getString("default", "toolTipDigSecretWay"));
			
			// level 1
			m_toolTipsTools.addToolTip("buttonToolObject1", res.getString("default", "toolTipMainCharacter"));
			m_toolTipsTools.addToolTip("buttonToolObject2", res.getString("default", "toolTipMagicStone"));
			m_toolTipsTools.addToolTip("buttonToolObject3", res.getString("default", "toolTipDoor"));
			m_toolTipsTools.addToolTip("buttonToolObject4", res.getString("default", "toolTipKey"));
			m_toolTipsTools.addToolTip("buttonToolObject5", res.getString("default", "toolTipWeaponShop"));
			m_toolTipsTools.addToolTip("buttonToolObject6", res.getString("default", "toolTipShieldShop"));
			m_toolTipsTools.addToolTip("buttonToolObject7", res.getString("default", "toolTipArmorShop"));
			m_toolTipsTools.addToolTip("buttonToolObject8", res.getString("default", "toolTipCoins"));
			m_toolTipsTools.addToolTip("buttonToolObject9", res.getString("default", "toolTipPotion"));
			m_toolTipsTools.addToolTip("buttonToolObject10", res.getString("default", "toolTipEnemy"));
			m_toolTipsTools.addToolTip("buttonToolObject11", res.getString("default", "toolTipGemstones"));
			
			// level 2
			m_toolTipsTools.addToolTip("buttonToolObject12", res.getString("default", "toolTipDoorButton1"));
			m_toolTipsTools.addToolTip("buttonToolObject13", res.getString("default", "toolTipDoorButton2"));
			m_toolTipsTools.addToolTip("buttonToolObject14", res.getString("default", "toolTipDoorButton3"));
			m_toolTipsTools.addToolTip("buttonToolObject15", res.getString("default", "toolTipDoorButton4"));
			m_toolTipsTools.addToolTip("buttonToolObject16", res.getString("default", "toolTipDoorColor1"));
			m_toolTipsTools.addToolTip("buttonToolObject17", res.getString("default", "toolTipDoorColor2"));
			m_toolTipsTools.addToolTip("buttonToolObject18", res.getString("default", "toolTipDoorColor3"));
			m_toolTipsTools.addToolTip("buttonToolObject19", res.getString("default", "toolTipDoorColor4"));

			// level 3
			m_toolTipsTools.addToolTip("buttonToolObject20", res.getString("default", "toolTipMessage"));
			m_toolTipsTools.addToolTip("buttonToolObject21", res.getString("default", "toolTipCross"));
			m_toolTipsTools.addToolTip("buttonToolObject22", res.getString("default", "toolTipBrokenFloor"));
			m_toolTipsTools.addToolTip("buttonToolObject23", res.getString("default", "toolTipBrokenFloor2good"));
			m_toolTipsTools.addToolTip("buttonToolObject24", res.getString("default", "toolTipBrokenFloor2bad"));
			m_toolTipsTools.addToolTip("buttonToolObject25", res.getString("default", "toolTipHole"));
		}
		
		private function onClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			switch (buttonName)
			{
				case "buttonLevel1":
					selectedLevel = 1;
					break;

				case "buttonLevel2":
					selectedLevel = 2;
					break;

				case "buttonLevel3":
					selectedLevel = 3;
					break;
			}
		}

	}
}