package game.states
{
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	import game.server.GameServer;
	import game.server.answers.AnswerMapInfos;
	import game.ui.PopupWindow;
	import game.value.MapInfo;
	
	import de.inutilis.inutilib.DisplayUtils;
	import de.inutilis.inutilib.media.SoundManager;
	import de.inutilis.inutilib.social.SocialUserManager;
	import de.inutilis.inutilib.statemachine.State;
	import de.inutilis.inutilib.statemachine.StateMachine;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.ScrollList;
	import de.inutilis.inutilib.ui.SplashScreen;
	import de.inutilis.inutilib.ui.ToolTips;
	import de.inutilis.inutilib.ui.Window;
	
	import mx.resources.ResourceManager;
	
	public class MenuOwnMapsState extends State
	{
		[Embed(source = "../../../embed/ui_menus.swf", symbol="UIOwnMaps")]
		private var UIOwnMaps:Class;

		private static var s_mapInfos:Array;

		private var m_parentStateMachine:StateMachine;
		private var m_window:Window;
		private var m_scrollList:ScrollList;
		private var m_toolTips:ToolTips;
		
		public function MenuOwnMapsState(stateMachine:StateMachine, parentStateMachine:StateMachine)
		{
			super(stateMachine);
			m_parentStateMachine = parentStateMachine;
		}
		
		override public function start():void
		{
			SplashScreen.instance.queuePlay("moveToSub", "sub");
			if (s_mapInfos == null)
			{
				requestMapInfos();
			}
			else
			{
				checkForEmptyAndStart();
			}
		}
		
		override public function end():void
		{
			if (m_window != null)
			{
				m_toolTips.release();
				m_window.close();
			}	
		}
		
		override public function update():void
		{
			if (m_scrollList != null)
			{
				m_scrollList.update();
			}
		}
		
		private function requestMapInfos():void
		{
			GameServer.instance.requestUserMapInfos([SocialUserManager.instance.playerUserId], false, onMapInfosReceived);
		}
		
		private function onMapInfosReceived(answer:AnswerMapInfos):void
		{
			if (answer.isOk)
			{
				s_mapInfos = answer.mapInfos;
				s_mapInfos.sortOn("m_dateInMillis", Array.NUMERIC | Array.DESCENDING);
				checkForEmptyAndStart();
			}
			else
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorInfo"));
				popup.open();
			}
		}
		
		private function checkForEmptyAndStart():void
		{
			if (!hasMaps())
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_YES_NO, ResourceManager.getInstance().getString("default", "textAskCreateMap"));
				popup.ui.addEventListener(MouseEvent.CLICK, onEmptyListPopupClick, false, 0, true);
				popup.open();
			}
			else
			{
				createWindow();
			}
		}
		
		private function onEmptyListPopupClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			switch (buttonName)
			{
				case PopupWindow.k_BUTTON_YES:
					editMap(null);
					break;

				case PopupWindow.k_BUTTON_NO:
					var state:State = new MenuMainState(m_stateMachine, m_parentStateMachine);
					m_stateMachine.setState(state);
					break;
			}
		}
		
		private function createWindow():void
		{
			m_window = new Window(MagicStone.uiContainer, new UIOwnMaps as Sprite, 300, PositionRectangle.k_CENTER);
			
			DisplayUtils.setText(m_window.ui, "text", ResourceManager.getInstance().getString("default", "textSelectMapOrCreate"), GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setButtonText(m_window.ui, "buttonCreate", ResourceManager.getInstance().getString("default", "buttonCreateNewMap"), GameDefs.k_TEXT_FORMAT_BOLD);
			
			m_window.ui.addEventListener(MouseEvent.CLICK, onWindowClick, false, 0, true);
			
			m_scrollList = new ScrollList(m_window.ui.getChildByName("listRowMap") as DisplayObjectContainer,
				m_window.ui.getChildByName("scrollArea") as Sprite,
				65,
				m_window.ui.getChildByName("buttonUp") as SimpleButton,
				m_window.ui.getChildByName("buttonDown") as SimpleButton,
				GameDefs.k_LIST_SCROLL_TIME);
			
			for each (var mapInfo:MapInfo in s_mapInfos)
			{
				var item:MapItem = new MapItem(this, mapInfo);
				m_scrollList.addItem(item, false);
			}
			m_scrollList.refreshPositions();
			m_scrollList.scrollThoughCompleteList(GameDefs.k_LIST_SCROLL_THROUGH_TIME);
						
			m_window.open();
			
			m_toolTips = new ToolTips(m_window.ui, MagicStone.gameStage, GameDefs.k_TOOLTIP_TEXT_FORMAT, GameDefs.k_TOOLTIP_OUTLINE_COLOR, PositionRectangle.k_TOP_CENTER);
			m_toolTips.addToolTip("buttonEdit", ResourceManager.getInstance().getString("default", "toolTipEditMap"));
			m_toolTips.addToolTip("buttonDelete", ResourceManager.getInstance().getString("default", "toolTipDeleteMap"));
			m_toolTips.addToolTip("buttonInfo", ResourceManager.getInstance().getString("default", "toolTipMapInfo"));
			m_toolTips.addToolTip("buttonUnpublished", ResourceManager.getInstance().getString("default", "toolTipMapClickForInfo"));
			
			SoundManager.instance.play(FileDefs.k_URL_SFX_WINDOW);
		}
		
		public function removeMapFromList(mapId:int, item:MapItem):void
		{
			m_scrollList.removeItem(item, true);
			for (var i:int = 0; i < s_mapInfos.length; i++)
			{
				var mapInfo:MapInfo = s_mapInfos[i] as MapInfo;
				if (mapInfo.mapId == mapId)
				{
					s_mapInfos.splice(i, 1);
					break;
				}
			}
		}
		
		private function onWindowClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			
			trace("buttonName: " + buttonName);
			
			switch (buttonName)
			{
				case "buttonCreate":
					editMap(null);
					break;

				case "buttonReturn":
					var state:State = new MenuMainState(m_stateMachine, m_parentStateMachine);
					m_stateMachine.setState(state);
					break;
			}
		}

		public function playMap(mapInfo:MapInfo):void
		{
			SplashScreen.instance.queuePlay("subToMap", "subToMapEnd");
			var state:State = new MapLoaderState(m_parentStateMachine, MapLoaderState.k_GO_TO_INGAME, InGameState.k_CAME_FROM_MENU, mapInfo);
			m_parentStateMachine.setState(state);
		}

		public function editMap(mapInfo:MapInfo):void
		{
			SplashScreen.instance.queuePlay("subToEdit", "subToEditEnd");
			var state:State = new MapLoaderState(m_parentStateMachine, MapLoaderState.k_GO_TO_MAP_EDITOR, InGameState.k_CAME_FROM_MENU, mapInfo);
			m_parentStateMachine.setState(state);
		}
		
		public static function reinitMaps():void
		{
			s_mapInfos = null;
		}
		
		public static function hasMaps():Boolean
		{
			return (s_mapInfos != null && s_mapInfos.length > 0);
		}

	}
}


import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import game.GameDefs;
import game.server.GameServer;
import game.server.answers.Answer;
import game.states.MenuOwnMapsState;
import game.ui.MapInfoWindow;
import game.ui.PopupWindow;
import game.value.MapInfo;

import de.inutilis.inutilib.DisplayUtils;
import de.inutilis.inutilib.ui.ScrollListItem;
import de.inutilis.inutilib.ui.Window;

import mx.resources.ResourceManager;

internal class MapItem extends ScrollListItem
{
	[Embed(source = "../../../embed/ui_menus.swf", symbol="ListRowMap")]
	private var ListRowMap:Class;

	[Embed(source = "../../../embed/ui_menus.swf", symbol="ListRowMapPublished")]
	private var ListRowMapPublished:Class;

	private var m_ownMapsState:MenuOwnMapsState;
	private var m_mapInfo:MapInfo;
	private var m_waitPopup:PopupWindow;
	
	public function MapItem(ownMapsState:MenuOwnMapsState, mapInfo:MapInfo)
	{
		m_ownMapsState = ownMapsState;
		m_mapInfo = mapInfo;
		
		var rowSprite:Sprite = mapInfo.published ? (new ListRowMapPublished as Sprite) : (new ListRowMap as Sprite);
		var textField:TextField = DisplayUtils.setText(rowSprite, "textName", (mapInfo.name.length > 0) ? mapInfo.name : ResourceManager.getInstance().getString("default", "textUnnamedMap"), GameDefs.k_TEXT_FORMAT);
		textField.mouseEnabled = false;
		
		textField = DisplayUtils.setText(rowSprite, "textUnlockLevel", mapInfo.unlockLevel.toString(), GameDefs.k_TEXT_FORMAT);
		textField.mouseEnabled = false;
		
		rowSprite.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		super(rowSprite);
	}
	
	private function onClick(e:MouseEvent):void
	{
		var buttonName:String = e.target.name;
		var popup:Window;
		
		switch (buttonName)
		{
			case "buttonPlay":
				m_ownMapsState.playMap(m_mapInfo);
				break;
			
			case "buttonEdit":
				m_ownMapsState.editMap(m_mapInfo);
				break;

			case "buttonDelete":
				popup = new PopupWindow(PopupWindow.k_TYPE_YES_NO, ResourceManager.getInstance().getString("default", "textAskDelete"), false);
				popup.ui.addEventListener(MouseEvent.CLICK, onDeleteClick, false, 0, true);
				popup.open();
				break;
			
			case "buttonUnpublished":
				popup = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textUnpublishedInfo"));
				popup.open();
				break;

			case "buttonInfo":
				var mapInfoWindow:MapInfoWindow = new MapInfoWindow(m_mapInfo);
				mapInfoWindow.open();
				break;
		}
	}
	
	private function onDeleteClick(e:MouseEvent):void
	{
		var buttonName:String = e.target.name as String;
		
		if (buttonName == PopupWindow.k_BUTTON_YES)
		{
			m_waitPopup = new PopupWindow(PopupWindow.k_TYPE_WAIT, ResourceManager.getInstance().getString("default", "textMapDeleted"));
			m_waitPopup.open();
			GameServer.instance.sendDeleteMap(m_mapInfo.mapId, onDeleted);
		}
	}
	
	private function onDeleted(answer:Answer):void
	{
		if (answer.isOk)
		{
			m_waitPopup.waitingDone();
			m_ownMapsState.removeMapFromList(m_mapInfo.mapId, this);
		}
		else
		{
			m_waitPopup.close();
			var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorDeleting"));
			popup.open();
		}
		m_waitPopup = null;
	}
}