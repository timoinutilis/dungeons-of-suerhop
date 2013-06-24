package game.states
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	import game.server.GameServer;
	import game.server.answers.AnswerMapInfos;
	import game.ui.MapOthersItem;
	import game.ui.PopupWindow;
	import game.value.MapInfo;
	
	import de.inutilis.inutilib.DisplayUtils;
	import de.inutilis.inutilib.media.SoundManager;
	import de.inutilis.inutilib.social.SocialUser;
	import de.inutilis.inutilib.social.SocialUserManager;
	import de.inutilis.inutilib.statemachine.State;
	import de.inutilis.inutilib.statemachine.StateMachine;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.ScrollList;
	import de.inutilis.inutilib.ui.SplashScreen;
	import de.inutilis.inutilib.ui.Window;
	
	import mx.resources.ResourceManager;
	
	public class MenuFriendMapsState extends State
	{
		[Embed(source = "../../../embed/ui_menus.swf", symbol="UIFriendMaps")]
		private var UIFriendMaps:Class;
		
		private static var s_mapInfos:Array;
		
		private var m_parentStateMachine:StateMachine;
		private var m_window:Window;
		private var m_scrollList:ScrollList;
		
		public function MenuFriendMapsState(stateMachine:StateMachine, parentStateMachine:StateMachine)
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
				createWindow();
			}
		}
		
		override public function end():void
		{
			if (m_window != null)
			{
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
			GameServer.instance.requestUserMapInfos(SocialUserManager.instance.friendUserIds, true, onMapInfosReceived);
		}
		
		private function onMapInfosReceived(answer:AnswerMapInfos):void
		{
			if (answer.isOk)
			{
				s_mapInfos = answer.mapInfos;
				s_mapInfos.sortOn(["userId", "m_dateInMillis"], [Array.NUMERIC, Array.NUMERIC | Array.DESCENDING]);
				createWindow();
			}
			else
			{
				var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "errorInfo"));
				popup.open();
			}
		}
		
		private function createWindow():void
		{
			m_window = new Window(MagicStone.uiContainer, new UIFriendMaps as Sprite, 300, PositionRectangle.k_CENTER);
			
			DisplayUtils.setText(m_window.ui, "text", ResourceManager.getInstance().getString("default", "textSelectMap"), GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(m_window.ui, "textColumns", ResourceManager.getInstance().getString("default", "textColumnsInfo"), GameDefs.k_TEXT_FORMAT);
			
			var scoreField:Sprite = m_window.ui.getChildByName("scoreField") as Sprite;
			scoreField.visible = false;
			
			m_window.ui.addEventListener(MouseEvent.CLICK, onWindowClick, false, 0, true);
			
			m_scrollList = new ScrollList(m_window.ui.getChildByName("listRowMap") as DisplayObjectContainer,
				m_window.ui.getChildByName("scrollArea") as Sprite,
				65,
				m_window.ui.getChildByName("buttonUp") as SimpleButton,
				m_window.ui.getChildByName("buttonDown") as SimpleButton,
				GameDefs.k_LIST_SCROLL_TIME);
			
			var lastUserId:int = 0;
			for each (var mapInfo:MapInfo in s_mapInfos)
			{
				if (mapInfo.userId != lastUserId)
				{
					var user:SocialUser = SocialUserManager.instance.getUser(mapInfo.userId);
					var friendItem:FriendItem = new FriendItem(user.name, user.pictureUrl);
					m_scrollList.addItem(friendItem, false);
					lastUserId = mapInfo.userId;
				}
				var item:MapOthersItem = new MapOthersItem(playMap, mapInfo);
				m_scrollList.addItem(item, false);
			}
			m_scrollList.refreshPositions();
			m_scrollList.scrollThoughCompleteList(GameDefs.k_LIST_SCROLL_THROUGH_TIME);
			
			m_window.open();

			SoundManager.instance.play(FileDefs.k_URL_SFX_WINDOW);
		}
		
		private function onWindowClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			
			trace("buttonName: " + buttonName);
			
			switch (buttonName)
			{
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
	}
}


import flash.display.Loader;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.text.TextField;

import game.GameDefs;
import game.states.MenuFriendMapsState;
import game.states.MenuOwnMapsState;

import de.inutilis.inutilib.DisplayUtils;
import de.inutilis.inutilib.ui.ScrollListItem;

import mx.resources.ResourceManager;

internal class FriendItem extends ScrollListItem
{
	[Embed(source = "../../../embed/ui_menus.swf", symbol="ListRowFriend")]
	private var ListRowFriend:Class;
	
	public function FriendItem(name:String, pictureUrl:String)
	{
		var rowSprite:Sprite = new ListRowFriend as Sprite;
		DisplayUtils.setText(rowSprite, "textName", ResourceManager.getInstance().getString("default", "textMapsBy").replace("%1", name), GameDefs.k_TEXT_FORMAT_BOLD);
		
		var loader:Loader = new Loader();
		loader.load(new URLRequest(pictureUrl));
		(rowSprite.getChildByName("profile") as Sprite).addChild(loader);
		
		super(rowSprite);
	}
}