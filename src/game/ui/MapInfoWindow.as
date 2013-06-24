package game.ui
{
	import com.facebook.graph.Facebook;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	import game.value.MapInfo;
	
	import de.inutilis.inutilib.DisplayUtils;
	import de.inutilis.inutilib.GameTime;
	import de.inutilis.inutilib.media.SoundManager;
	import de.inutilis.inutilib.social.SocialUserManager;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.Window;
	
	import mx.resources.ResourceManager;
	
	public class MapInfoWindow extends Window
	{
		[Embed(source = "../../../embed/ui_popups.swf", symbol="UIMapInfo")]
		private var UIMapInfo:Class;
		
		private var m_mapInfo:MapInfo;
		private var m_buttonOk:SimpleButton;

		public function MapInfoWindow(mapInfo:MapInfo)
		{
			m_mapInfo = mapInfo;
			
			var ui:Sprite = new UIMapInfo() as Sprite;
			
			DisplayUtils.setText(ui, "textTitle", mapInfo.name, GameDefs.k_TEXT_FORMAT_BOLD);
			
			DisplayUtils.setText(ui, "textPlayed", ResourceManager.getInstance().getString("default", "textPlayed"), GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(ui, "textPlayedValue", mapInfo.numPlayed.toString(), GameDefs.k_TEXT_FORMAT);

			DisplayUtils.setText(ui, "textSuccesses", ResourceManager.getInstance().getString("default", "textSuccesses"), GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(ui, "textSuccessesValue", mapInfo.numSuccesses + " (" + Math.round(mapInfo.m_successRatio * 100) + "%)", GameDefs.k_TEXT_FORMAT);

			DisplayUtils.setText(ui, "textPlaytime", ResourceManager.getInstance().getString("default", "textPlaytime"), GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(ui, "textPlaytimeValue", GameTime.timeString(mapInfo.m_averageTime), GameDefs.k_TEXT_FORMAT);

			DisplayUtils.setText(ui, "textDate", ResourceManager.getInstance().getString("default", "textDate"), GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(ui, "textDateValue", mapInfo.creationDate.getDate() + "/" + mapInfo.creationDate.getMonth() + "/" + mapInfo.creationDate.getFullYear(), GameDefs.k_TEXT_FORMAT);

			DisplayUtils.setText(ui, "textLikes", ResourceManager.getInstance().getString("default", "textLikes"), GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(ui, "textLikesValue", mapInfo.numLikes.toString(), GameDefs.k_TEXT_FORMAT);
			
			m_buttonOk = DisplayUtils.setButtonText(ui, "buttonOk", ResourceManager.getInstance().getString("default", "buttonOk"), GameDefs.k_TEXT_FORMAT_BOLD);
			DisplayUtils.setButtonText(ui, "buttonInvite", ResourceManager.getInstance().getString("default", "buttonInvite"), GameDefs.k_TEXT_FORMAT_BOLD);

			ui.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			
			super(MagicStone.uiContainer, ui, 200, PositionRectangle.k_CENTER, true);
		}
		
		override public function open():void
		{
			super.open();
			SoundManager.instance.play(FileDefs.k_URL_SFX_PAPER);
			ui.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		override public function close():void
		{
			super.close();
			SoundManager.instance.play(FileDefs.k_URL_SFX_PAPER_CLOSE);
			ui.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		private function onClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			switch (buttonName)
			{
				case "buttonLikesInfo":
					ui.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textLikeInfo"));
					popup.ui.addEventListener(MouseEvent.CLICK, onPopupClick, false, 0, true);
					popup.open();
					break;
				
				case "buttonInvite":
					invite();
					break;
				
				case "buttonOk":
					close();
					break;
			}
		}
		
		private function onPopupClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			if (buttonName == PopupWindow.k_BUTTON_OK)
			{
				ui.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.CLICK);
				m_buttonOk.dispatchEvent(mouseEvent);
			}
		}

		private function invite():void
		{
			if (Config.useFacebook)
			{
				MagicStone.log("Fb Invite");
				
				var name:String = SocialUserManager.instance.getPlayerUser().name;
				var message:String = ResourceManager.getInstance().getString("default", "textInvitedPlayMapMsg").replace("%1", name).replace("%2", m_mapInfo.name);
				var params:Object = new Object();
				params.title = ResourceManager.getInstance().getString("default", "textInviteTitle");
				params.message = message;
				params.data = m_mapInfo.mapId;
				Facebook.ui("apprequests", params);
			}
		}

	}
}