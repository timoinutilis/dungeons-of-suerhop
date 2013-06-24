package game.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import game.GameDefs;
	import game.MagicStone;
	
	import inutilib.media.MusicPlayer;
	import inutilib.media.SoundManager;
	import inutilib.ui.PositionRectangle;
	import inutilib.ui.ToolTips;
	import inutilib.ui.Window;
	
	import mx.resources.ResourceManager;
	
	public class UserOptionsWindow extends Window
	{
		[Embed(source = "../../../embed/ui_user_options.swf", symbol="UIUserOptions")]
		private var UIUserOptions:Class;
		
		private var m_toolTips:ToolTips;
		private var m_crossSfx:Sprite;
		private var m_crossMusic:Sprite;
		
		public function UserOptionsWindow()
		{
			var ui:Sprite = new UIUserOptions() as Sprite;
			
			m_crossSfx = ui.getChildByName("crossSfx") as Sprite;
			m_crossSfx.visible = !SoundManager.instance.enabled
			m_crossSfx.mouseEnabled = false;
			
			m_crossMusic = ui.getChildByName("crossMusic") as Sprite;
			m_crossMusic.visible = !MusicPlayer.instance.enabled;
			m_crossMusic.mouseEnabled = false;
			
			m_toolTips = new ToolTips(ui, MagicStone.gameStage, GameDefs.k_TOOLTIP_TEXT_FORMAT, GameDefs.k_TOOLTIP_OUTLINE_COLOR, PositionRectangle.k_CENTER_RIGHT);
			m_toolTips.addToolTip("buttonSfx", ResourceManager.getInstance().getString("default", "toolTipOptionSfx"));
			m_toolTips.addToolTip("buttonMusic", ResourceManager.getInstance().getString("default", "toolTipOptionMusic"));

			ui.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			
			super(MagicStone.uiContainer, ui, 200, PositionRectangle.k_BOTTOM_LEFT);
		}
		
		private function onClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			switch (buttonName)
			{
				case "buttonSfx":
					SoundManager.instance.enabled = !SoundManager.instance.enabled;
					m_crossSfx.visible = !SoundManager.instance.enabled;
					break;
				
				case "buttonMusic":
					MusicPlayer.instance.enabled = !MusicPlayer.instance.enabled;
					m_crossMusic.visible = !MusicPlayer.instance.enabled;
					break;
			}
		}
	}
}