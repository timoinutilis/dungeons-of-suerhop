package game.states
{
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
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
	import de.inutilis.inutilib.social.SocialUserManager;
	import de.inutilis.inutilib.statemachine.State;
	import de.inutilis.inutilib.statemachine.StateMachine;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.ScrollList;
	import de.inutilis.inutilib.ui.SplashScreen;
	import de.inutilis.inutilib.ui.ToolTips;
	import de.inutilis.inutilib.ui.Window;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	public class MenuTopMapsState extends State
	{
		[Embed(source = "../../../embed/ui_menus.swf", symbol="UIFriendMaps")]
		private var UIFriendMaps:Class;
		
		private static var s_mapInfos:Array;
		
		private var m_parentStateMachine:StateMachine;
		private var m_window:Window;
		private var m_scrollList:ScrollList;
		private var m_toolTips:ToolTips;
		
		public function MenuTopMapsState(stateMachine:StateMachine, parentStateMachine:StateMachine)
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
			GameServer.instance.requestTopMapInfos(onMapInfosReceived);
		}
		
		private function onMapInfosReceived(answer:AnswerMapInfos):void
		{
			if (answer.isOk)
			{
				s_mapInfos = answer.mapInfos;
				//s_mapInfos.sortOn("m_averageTime", Array.NUMERIC);
				s_mapInfos.sortOn(["preSort", "m_dateInMillis"], [Array.NUMERIC | Array.DESCENDING, Array.NUMERIC | Array.DESCENDING]);
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
			
			var res:IResourceManager = ResourceManager.getInstance();
						
			DisplayUtils.setText(m_window.ui, "text", res.getString("default", "textSelectMap"), GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(m_window.ui, "textColumns", res.getString("default", "textColumnsInfo"), GameDefs.k_TEXT_FORMAT);
			
			var scoreField:Sprite = m_window.ui.getChildByName("scoreField") as Sprite;
			DisplayUtils.setText(scoreField, "textLevel", MagicStone.s_userInfo.getLevel().toString(), GameDefs.k_TEXT_FORMAT);
			DisplayUtils.setText(scoreField, "textTotalScore", MagicStone.s_userInfo.totalScore.toString(), GameDefs.k_TEXT_FORMAT);
			
			m_toolTips = new ToolTips(scoreField, MagicStone.gameStage, GameDefs.k_TOOLTIP_TEXT_FORMAT, GameDefs.k_TOOLTIP_OUTLINE_COLOR, PositionRectangle.k_TOP_CENTER);
			m_toolTips.addToolTip("textLevel", res.getString("default", "toolTipYourLevel"));
			m_toolTips.addToolTip("textTotalScore", res.getString("default", "toolTipYourTotalScore").replace("%1", MagicStone.s_userInfo.getLevel() * GameDefs.k_POINTS_PER_LEVEL));

			m_window.ui.addEventListener(MouseEvent.CLICK, onWindowClick, false, 0, true);
			
			m_scrollList = new ScrollList(m_window.ui.getChildByName("listRowMap") as DisplayObjectContainer,
				m_window.ui.getChildByName("scrollArea") as Sprite,
				65,
				m_window.ui.getChildByName("buttonUp") as SimpleButton,
				m_window.ui.getChildByName("buttonDown") as SimpleButton,
				GameDefs.k_LIST_SCROLL_TIME);
			
			for each (var mapInfo:MapInfo in s_mapInfos)
			{
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
