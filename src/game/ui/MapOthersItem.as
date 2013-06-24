package game.ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import game.GameDefs;
	import game.MagicStone;
	import game.value.MapInfo;
	import game.value.MapStatus;
	
	import inutilib.DisplayUtils;
	import inutilib.GameTime;
	import inutilib.social.SocialUserManager;
	import inutilib.ui.PositionRectangle;
	import inutilib.ui.ScrollListItem;
	
	import mx.resources.ResourceManager;
	
	public class MapOthersItem extends ScrollListItem
	{
		[Embed(source = "../../../embed/ui_menus.swf", symbol="ListRowMapOther")]
		private var ListRowMapOther:Class;
		
		private static const k_DISTANCE_NAME_STAR:Number = 15;
		private static const k_DISTANCE_SCORE_WATCH:Number = 8;
		
		private var m_playFunction:Function;
		private var m_mapInfo:MapInfo;
		
		public function MapOthersItem(playFunction:Function, mapInfo:MapInfo)
		{
			m_playFunction = playFunction;
			m_mapInfo = mapInfo;
			
			var rowSprite:Sprite = new ListRowMapOther as Sprite;
			
			// Name
			var textFieldName:TextField = DisplayUtils.setText(rowSprite, "textName", m_mapInfo.name, GameDefs.k_TEXT_FORMAT);
			textFieldName.mouseEnabled = false;
			
			// Time
			(rowSprite.getChildByName("watch") as Sprite).mouseEnabled = false;
			var seconds:int = mapInfo.m_averageTime;
			var textField:TextField = DisplayUtils.setText(rowSprite, "textTime", GameTime.timeString(seconds), GameDefs.k_TEXT_FORMAT);
			textField.mouseEnabled = false;
			
			// Difficulty
			var movieClip:MovieClip = rowSprite.getChildByName("difficulty") as MovieClip;
			movieClip.mouseEnabled = false;
			var successRatio:Number = m_mapInfo.m_successRatio;
			if (successRatio >= 0.75)
			{
				movieClip.gotoAndStop(1);
			}
			else if (successRatio >= 0.5)
			{
				movieClip.gotoAndStop(2);
			}
			else if (successRatio >= 0.25)
			{
				movieClip.gotoAndStop(3);
			}
			else
			{
				movieClip.gotoAndStop(4);
			}

			// Status and unlock level
			movieClip = rowSprite.getChildByName("status") as MovieClip;
			movieClip.mouseEnabled = false;
			var status:int = MapStatus.k_STATUS_UNPLAYED;
			var score:int = 0;
			if (m_mapInfo.unlockLevel > MagicStone.s_userInfo.getLevel())
			{
				movieClip.gotoAndStop("locked");
			}
			else
			{
				if (MagicStone.s_mapStatus.hasOwnProperty(m_mapInfo.mapId))
				{
					var mapStatus:MapStatus = (MagicStone.s_mapStatus[m_mapInfo.mapId] as MapStatus);
					status = mapStatus.status;
					score = mapStatus.score;
				}
				movieClip.gotoAndStop(status + 1);
			}
			textField = DisplayUtils.setText(movieClip, "textUnlockLevel", m_mapInfo.unlockLevel.toString(), GameDefs.k_TEXT_FORMAT);
			textField.mouseEnabled = false;
			
			// Score
			var sprite:Sprite = rowSprite.getChildByName("star") as Sprite;
			textField = DisplayUtils.setText(rowSprite, "textScore", score.toString(), GameDefs.k_TEXT_FORMAT);
			if (score > 0)
			{
				sprite.mouseEnabled = false;
				textField.mouseEnabled = false;
				var distance:Number = textField.x - sprite.x;
				var scoreWidth:Number = distance + textField.textWidth + k_DISTANCE_SCORE_WATCH;
				var nameWidth:Number = textFieldName.textWidth + k_DISTANCE_NAME_STAR;
				if (nameWidth + scoreWidth > textFieldName.width)
				{
					textFieldName.width = textFieldName.width - scoreWidth;
					nameWidth = textFieldName.width;
				}
				sprite.x = textFieldName.x + nameWidth;
				textField.x = sprite.x + distance;
			}
			else
			{
				sprite.visible = false;
				textField.visible = false;
			}

			rowSprite.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			
			super(rowSprite);
		}
		
		private function onClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name;

			switch (buttonName)
			{
				case "buttonPlay":
					if (m_mapInfo.unlockLevel > MagicStone.s_userInfo.getLevel())
					{
						var window:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textDungeonLocked").replace("%1", m_mapInfo.unlockLevel.toString()));
						window.open();
					}
					else
					{
						m_playFunction(m_mapInfo);
					}
					break;
			}
		}
	}
}