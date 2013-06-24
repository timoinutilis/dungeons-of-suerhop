package de.inutilis.inutilib.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import de.inutilis.inutilib.GameTime;
	import de.inutilis.inutilib.MathUtils;

	public class ScrollList extends ScrollArea
	{
		private var m_areaSprite:Sprite;
		private var m_itemHeight:Number;
		private var m_buttonUp:SimpleButton;
		private var m_buttonDown:SimpleButton;
		private var m_defaultScrollTime:int;
		private var m_items:Array;
		private var m_listHeight:Number;
		private var m_numVisible:int;
		
		public function ScrollList(container:DisplayObjectContainer, areaSprite:Sprite, itemHeight:Number, buttonUp:SimpleButton, buttonDown:SimpleButton, defaultScrollTime:int)
		{
			super(container);

			m_areaSprite = areaSprite;
			m_itemHeight = itemHeight;
			m_buttonUp = buttonUp;
			m_buttonDown = buttonDown;
			m_defaultScrollTime = defaultScrollTime;
			
			m_listHeight = 0;
			m_numVisible = Math.floor(areaSprite.height / itemHeight);
			m_items = new Array();
			
			// clean container
			for (var i:int = m_container.numChildren - 1; i >= 0; i--)
			{
				m_container.removeChildAt(i);
			}
			
			refreshButtons();
			
			m_buttonUp.addEventListener(MouseEvent.MOUSE_DOWN, onButtonUp, false, 0, true);
			m_buttonDown.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown, false, 0, true);
		}
		
		public function addItem(item:ScrollListItem, refresh:Boolean = true):void
		{
			m_items.push(item);
			m_container.addChild(item.sprite);
			if (refresh)
			{
				refreshPositions();
			}
		}
		
		public function removeItem(item:ScrollListItem, refresh:Boolean = true):void
		{
			var index:int = m_items.indexOf(item);
			m_items.splice(index, 1);
			m_container.removeChild(item.sprite);
			if (refresh)
			{
				refreshPositions();
			}
		}
		
		public function refreshPositions():void
		{
			var itemY:Number = 0;
			for each (var item:ScrollListItem in m_items)
			{
				item.sprite.y = itemY;
				itemY += m_itemHeight;
			}
			m_listHeight = itemY;
			refreshButtons();
		}
		
		public function scrollUp(scrollTime:int):void
		{
			if (canScrollUp())
			{
				scrollTo(Math.max(0, m_scrollEnd - m_numVisible * m_itemHeight), scrollTime);
				refreshButtons();
			}
		}
		
		public function scrollDown(scrollTime:int):void
		{
			if (canScrollDown())
			{
				scrollTo(Math.min(m_listHeight - m_numVisible * m_itemHeight, m_scrollEnd + m_numVisible * m_itemHeight), scrollTime);
				refreshButtons();
			}
		}
		
		public function scrollThoughCompleteList(scrollTime:int):void
		{
			if (m_numVisible < m_items.length)
			{
				var onePage:Number = m_numVisible * m_itemHeight;
				var scrollHeight:Number = m_listHeight - onePage;
				if (scrollHeight > onePage * 2)
				{
					scrollFromTo(onePage * 2, 0, scrollTime * 1.5, scrollTime * 0.5);
				}
				else
				{
					scrollFromTo(scrollHeight, 0, scrollTime);
				}
			}
		}
				
		public function canScrollUp():Boolean
		{
			return (m_scrollEnd > 0);
		}
		
		public function canScrollDown():Boolean
		{
			return (m_scrollEnd + m_numVisible * m_itemHeight < m_listHeight);
		}
		
		private function refreshButtons():void
		{
			m_buttonUp.visible = canScrollUp();
			m_buttonDown.visible = canScrollDown();
		}
		
		private function onButtonUp(e:MouseEvent):void
		{
			scrollUp(m_defaultScrollTime);
		}

		private function onButtonDown(e:MouseEvent):void
		{
			scrollDown(m_defaultScrollTime);
		}
	}
}