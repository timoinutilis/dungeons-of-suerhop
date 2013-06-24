package game.states
{
	import flash.events.MouseEvent;
	
	import flashx.textLayout.elements.BreakElement;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	import game.ui.ShopWindow;
	
	import inutilib.media.SoundManager;
	import inutilib.statemachine.State;
	import inutilib.statemachine.StateMachine;
	import inutilib.ui.WindowEvent;
	
	import mx.resources.ResourceManager;
	
	public class ShopState extends State
	{		
		private var m_window:ShopWindow;
		private var m_firstItem:int;
		private var m_lowest:int;
		private var m_inGame:InGameState;
		private var m_type:int;
		
		public function ShopState(stateMachine:StateMachine, inGame:InGameState, type:int)
		{
			super(stateMachine);
			m_inGame = inGame;
			m_type = type;
		}
		
		override public function start():void
		{
			var visibleItems:int = 3;
			var spriteFile:String;
			var spriteBaseName:String;
			switch (m_type)
			{
				case InGameState.k_EQUIPMENT_ARMOR:
					visibleItems = 2;
					spriteFile = FileDefs.k_URL_ARMORS;
					spriteBaseName = "Armor";
					break;
				
				case InGameState.k_EQUIPMENT_SHIELD:
					spriteFile = FileDefs.k_URL_SHIELDS;
					spriteBaseName = "Shield";
					break;
				
				case InGameState.k_EQUIPMENT_WEAPON:
					spriteFile = FileDefs.k_URL_SWORDS;
					spriteBaseName = "Sword";
					break;
			}
			m_lowest = Math.max(0, m_inGame.getEquipment(m_type) - 1);
			m_window = new ShopWindow(MagicStone.uiContainer, m_lowest, 9 - m_lowest, visibleItems, Config.resPath + spriteFile, spriteBaseName);
			m_window.coins = m_inGame.coins;
			m_window.ui.addEventListener(MouseEvent.CLICK, onWindowClick, false, 0, true);
			m_window.ui.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			m_window.ui.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
			m_window.ui.addEventListener(MouseEvent.ROLL_OUT, onMouseOut, false, 0, true);
			m_window.open();
			
			m_window.guyAnim(ShopWindow.k_GUY_SHOW);
			
			m_inGame.closeHud();
		}
		
		override public function end():void
		{
			m_window.close();
			m_inGame.openHud();
		}
		
		override public function update():void
		{
			if (m_window.wasBought())
			{
				m_stateMachine.exitCurrentState();
			}
		}

		private function getItemPrice(item:int):int
		{
			switch (m_type)
			{
				case InGameState.k_EQUIPMENT_ARMOR:
					return GameDefs.k_PRICES_ARMOR[item - 1];
				
				case InGameState.k_EQUIPMENT_SHIELD:
					return GameDefs.k_PRICES_SHIELD[item - 1];
				
				case InGameState.k_EQUIPMENT_WEAPON:
					return GameDefs.k_PRICES_WEAPON[item - 1];
			}
			return 0;
		}
		
		private function onWindowClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			
			trace("buttonName: " + buttonName);
			
			var state:State;
			switch (buttonName)
			{
				case "buttonClose":
					m_stateMachine.exitCurrentState();
					break;
				
				case "buttonLeft":
					if (m_firstItem > 0)
					{
						m_firstItem -= m_window.visibleItems;
						m_window.setItems(m_firstItem, true);
						m_window.guyAnim(ShopWindow.k_GUY_SHOW);
						SoundManager.instance.play(FileDefs.k_URL_SFX_THINGS);
					}
					break;
				
				case "buttonRight":
					if (m_firstItem < m_window.numItems - m_window.visibleItems)
					{
						m_firstItem += m_window.visibleItems;
						m_window.setItems(m_firstItem, false);
						m_window.guyAnim(ShopWindow.k_GUY_SHOW);
						SoundManager.instance.play(FileDefs.k_URL_SFX_THINGS);
					}
					break;
				
				case "buttonItem1":
				case "buttonItemA1":
					onClickedItem(0);
					break;
				
				case "buttonItem2":
				case "buttonItemA2":
					onClickedItem(1);
					break;

				case "buttonItem3":
					onClickedItem(2);
					break;
			}
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			
			switch (buttonName)
			{
				case "buttonItem1":
				case "buttonItemA1":
					onOverItem(0);
					break;
				
				case "buttonItem2":
				case "buttonItemA2":
					onOverItem(1);
					break;
				
				case "buttonItem3":
					onOverItem(2);
					break;
			}
		}

		private function onMouseOut(e:MouseEvent):void
		{
			m_window.hideBubble();
		}

		private function onClickedItem(index:int):void
		{
			var item:int = m_lowest + m_firstItem + index + 1;
			if (item == m_inGame.getEquipment(m_type))
			{
				m_window.showBubble(ResourceManager.getInstance().getString("default", "textYouHaveAlready"));
				m_window.guyAnim(ShopWindow.k_GUY_NO);
			}
			else
			{
				var price:int = getItemPrice(item);
				if (price > m_inGame.coins)
				{
					m_window.showBubble(ResourceManager.getInstance().getString("default", "textNotEnoughCoins"));
					m_window.guyAnim(ShopWindow.k_GUY_NO);
				}
				else
				{
					m_inGame.addCoins(-price);
					m_window.coins = m_inGame.coins;
					m_inGame.setEquipment(m_type, item);
					m_window.hideBubble();
					m_inGame.addSeconds(GameDefs.k_SECONDS_SHOP_BUY);
					m_window.guyAnim(ShopWindow.k_GUY_YES);
					m_window.buyItem(index);
					SoundManager.instance.play(FileDefs.k_URL_SFX_PAY);
				}
			}
		}
		
		private function onOverItem(index:int):void
		{
			var item:int = m_lowest + m_firstItem + index + 1;
			var text:String;
			if (item == m_inGame.getEquipment(m_type))
			{
				text = ResourceManager.getInstance().getString("default", "textThisIsYours");
			}
			else
			{
				text = ResourceManager.getInstance().getString("default", "textItemCoins") + " " + getItemPrice(item);
			}
			switch (m_type)
			{
				case InGameState.k_EQUIPMENT_ARMOR:
					text += "\r" + ResourceManager.getInstance().getString("default", "textItemProtection") + " " + GameDefs.k_ARMOR_LEVEL_PROTECTIONS[item];
					break;
				
				case InGameState.k_EQUIPMENT_SHIELD:
					text += "\r" + ResourceManager.getInstance().getString("default", "textItemBlock") + " " + Math.round(GameDefs.k_SHIELD_LEVEL_BLOCKS[item] * 100) + "%";
					break;
				
				case InGameState.k_EQUIPMENT_WEAPON:
					text += "\r" + ResourceManager.getInstance().getString("default", "textItemDamage") + " " + GameDefs.k_WEAPON_LEVEL_DAMAGES[item];
					break;
			}
			m_window.showBubble(text);
		}
		
	}
}