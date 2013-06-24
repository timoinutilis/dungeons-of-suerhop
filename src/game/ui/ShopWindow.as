package game.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import game.Config;
	import game.FileDefs;
	import game.GameDefs;
	
	import de.inutilis.inutilib.DisplayUtils;
	import de.inutilis.inutilib.media.ImageManager;
	import de.inutilis.inutilib.media.SoundManager;
	import de.inutilis.inutilib.ui.PositionRectangle;
	import de.inutilis.inutilib.ui.Window;

	
	public class ShopWindow extends Window
	{
		[Embed(source = "../../../embed/ui_shop.swf", symbol="UIShop")]
		private var UIShop:Class;
		
		public static const k_GUY_IDLE:String = "idle";
		public static const k_GUY_SHOW:String = "show";
		public static const k_GUY_YES:String = "yes";
		public static const k_GUY_NO:String = "no";
		
		private static const k_FRAME_CLOSE:String = "close";
		
		private var m_visibleItems:int;
		private var m_items:Array;
		private var m_first:int;
		private var m_lowestItem:int;
		private var m_numItems:int;
		private var m_spriteUrl:String;
		private var m_spriteBaseName:String;
		private var m_isBubbleShown:Boolean;
		private var m_nextBubbleText:String;
		private var m_buyIndex:int;
		
		private var m_buttonLeft:SimpleButton;
		private var m_buttonRight:SimpleButton;
		private var m_textPage:TextField;
		private var m_textCoins:TextField;
		private var m_bubble:MovieClip;
		private var m_bubbleText:TextField;
		private var m_guy:MovieClip;

		public function ShopWindow(container:DisplayObjectContainer, lowestItem:int, numItems:int, visibleItems:int, spriteUrl:String, spriteBaseName:String)
		{
			var ui:Sprite = new UIShop as Sprite;
			super(container, ui, 300, PositionRectangle.k_CENTER);
			
			m_visibleItems = visibleItems;
			m_first = -1;
			m_lowestItem = lowestItem;
			m_numItems = numItems;
			m_spriteUrl = spriteUrl;
			m_spriteBaseName = spriteBaseName;
			m_buyIndex = -1;
			
			m_buttonLeft = ui.getChildByName("buttonLeft") as SimpleButton;
			m_buttonRight = ui.getChildByName("buttonRight") as SimpleButton;
			m_textPage = DisplayUtils.setText(ui, "textPage", "", GameDefs.k_TEXT_FORMAT_BOLD);
			m_textCoins = DisplayUtils.setText(ui, "textCoins", "", GameDefs.k_TEXT_FORMAT_BOLD);
			m_bubble = ui.getChildByName("bubble") as MovieClip;
			m_bubbleText = DisplayUtils.setText(m_bubble.getChildAt(0) as Sprite, "text", "", GameDefs.k_TEXT_FORMAT);
			m_guy = ui.getChildByName("guy") as MovieClip;
			
			m_buttonLeft.visible = false;
			m_buttonRight.visible = false;
			m_bubble.visible = false;
			m_bubble.stop();
			guyAnim(k_GUY_IDLE);
			
			deactivateUnusedItemButtons();
			
			ImageManager.instance.request(m_spriteUrl, onLoaded);
		}
		
		override public function open():void
		{
			super.open();
			SoundManager.instance.play(FileDefs.k_URL_SFX_THINGS);
			ui.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		override public function close():void
		{
			ImageManager.instance.release(m_spriteUrl);
			super.close();
			ui.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			var mouseEvent:MouseEvent;
			if (e.keyCode == Keyboard.ENTER)
			{
				mouseEvent = new MouseEvent(MouseEvent.CLICK);
				(ui.getChildByName("buttonClose") as SimpleButton).dispatchEvent(mouseEvent);
			}
			else if (e.keyCode == Keyboard.LEFT)
			{
				if (m_buttonLeft.visible)
				{
					mouseEvent = new MouseEvent(MouseEvent.CLICK);
					m_buttonLeft.dispatchEvent(mouseEvent);
				}
			}
			else if (e.keyCode == Keyboard.RIGHT)
			{
				if (m_buttonRight.visible)
				{
					mouseEvent = new MouseEvent(MouseEvent.CLICK);
					m_buttonRight.dispatchEvent(mouseEvent);
				}
			}
		}
		
		public function get visibleItems():int
		{
			return m_visibleItems;
		}
		
		private function deactivateUnusedItemButtons():void
		{
			var num:int = (m_visibleItems == 2) ? 3 : 2;
			var buttonItemName:String = (m_visibleItems == 2) ? "buttonItem" : "buttonItemA";
			for (var i:int = 0; i < num; i++)
			{
				var button:SimpleButton = ui.getChildByName(buttonItemName + (i + 1)) as SimpleButton;
				button.enabled = false;
				button.mouseEnabled = false;
			}
		}

		private function refreshPage():void
		{
			m_textPage.text = (int)((m_first / m_visibleItems) + 1) + "/" + (int)((m_numItems + m_visibleItems - 1) / m_visibleItems);
			m_buttonLeft.visible = (m_first > 0);
			m_buttonRight.visible = (m_first + m_visibleItems < m_numItems);
			
			var buttonItemName:String = (m_visibleItems == 3) ? "buttonItem" : "buttonItemA";
			for (var i:int = 0; i < m_visibleItems; i++)
			{
				var button:SimpleButton = ui.getChildByName(buttonItemName + (i + 1)) as SimpleButton;
				var enabled:Boolean = (m_first + i < m_numItems);
				button.enabled = enabled;
				button.mouseEnabled = enabled;
			}
		}
		
		public function set coins(value:int):void
		{
			m_textCoins.text = value.toString();
		}
		
		public function showBubble(text:String):void
		{
			if (!m_bubble.visible)
			{
				m_bubbleText.text = text;
				m_bubble.gotoAndPlay(1);
				m_bubble.visible = true;
				m_isBubbleShown = true;
			}
			else
			{
				// close bubble
				m_isBubbleShown = false;
				m_bubble.play();
				m_nextBubbleText = text;
			}
		}
		
		public function hideBubble():void
		{
			if (m_isBubbleShown)
			{
				m_isBubbleShown = false;
				m_bubble.play();
			}
			m_nextBubbleText = null;
		}
		
		public function guyAnim(anim:String):void
		{
			m_guy.gotoAndStop(anim);
		}

		public function get numItems():int
		{
			return m_numItems;
		}
		
		private function onLoaded(url:String, spare:Object):void
		{
			m_items = new Array(m_numItems);
			for (var i:int = 0; i < m_numItems; i++)
			{
				var spriteClass:Class = ImageManager.instance.getSpriteClass(url, m_spriteBaseName + (i + m_lowestItem + 1));
				m_items[i] = new ShopItem(new spriteClass as Sprite);
			}
			setItems(0, false);
		}
		
		public function setItems(first:int, rightToLeft:Boolean):void
		{
			var i:int;
			var item:ShopItem;
			var delay:int = 0;
			var num:int;
			
			if (m_first != -1)
			{
				num = Math.min(m_visibleItems, m_numItems - m_first);
				for (i = 0; i < num; i++)
				{
					item = (m_items[i + m_first] as ShopItem);
					item.hide((rightToLeft ? i : (m_visibleItems - i - 1)) * 200, rightToLeft ? -1 : 1);
				}
				delay = ShopItem.k_SHOP_ITEM_TIME / 2;
			}	

			num = Math.min(m_visibleItems, m_numItems - first);
			var itemName:String = (m_visibleItems == 3) ? "item" : "itemA";
			for (i = 0; i < num; i++)
			{
				item = (m_items[i + first] as ShopItem);
				item.placeholder = ui.getChildByName(itemName + (i + 1)) as Sprite;
				item.show(delay + (rightToLeft ? i : (m_visibleItems - i - 1)) * 200, rightToLeft ? -1 : 1);
			}
			m_first = first;
			
			refreshPage();
		}
		
		public function buyItem(slotIndex:int):void
		{
			m_buyIndex = m_first + slotIndex;
			var item:ShopItem = (m_items[m_buyIndex] as ShopItem);
			item.buy();
			ui.mouseEnabled = false;
			ui.mouseChildren = false;
		}
		
		public function wasBought():Boolean
		{
			return (m_buyIndex != -1 && (m_items[m_buyIndex] as ShopItem).isHidden());
		}
		
		override public function update():void
		{
			super.update();
			if (m_items != null)
			{
				for (var i:int = 0; i < m_numItems; i++)
				{
					var item:ShopItem = (m_items[i] as ShopItem);
					item.update();
				}
			}
			
			if (m_isBubbleShown)
			{
				if (m_bubble.currentFrameLabel == k_FRAME_CLOSE)
				{
					m_bubble.stop();
				}
			}
			else if (m_bubble.visible)
			{
				if (m_bubble.currentFrame == m_bubble.totalFrames)
				{
					m_bubble.visible = false;
					m_bubble.stop();
					if (m_nextBubbleText != null)
					{
						showBubble(m_nextBubbleText);
						m_nextBubbleText = null;
					}
				}
			}
			
			if (m_guy.currentFrameLabel != k_GUY_IDLE)
			{
				var animMovieClip:MovieClip = m_guy.getChildAt(0) as MovieClip;
				if (animMovieClip.currentFrame == animMovieClip.totalFrames)
				{
					guyAnim(k_GUY_IDLE);
				}
			}
		}
	}
	
}


import flash.display.Sprite;

import game.GameDefs;

import de.inutilis.inutilib.GameTime;


internal class ShopItem
{
	public static const k_SHOP_ITEM_TIME:int = 600;
	public static const k_SHOP_ITEM_DISPLACEMENT:int = 340;
	public static const k_SHOP_ITEM_ROTATION:Number = 70;
	public static const k_SHOP_ITEM_BUY_TIME:int = 1000;
	public static const k_SHOP_ITEM_BUY_DISPLACEMENT:int = 60;

	private static const k_STATE_HIDDEN:int = 0;
	private static const k_STATE_COMING:int = 1;
	private static const k_STATE_SHOWN:int = 2;
	private static const k_STATE_LEAVING:int = 3;
	private static const k_STATE_BUY:int = 4;
	
	private var m_sprite:Sprite;
	private var m_placeholder:Sprite;
	private var m_rotationDirection:Number;
	private var m_timer:int;
	private var m_state:int;
	
	public function ShopItem(sprite:Sprite)
	{
		m_sprite = sprite;
		m_sprite.visible = false;
		m_rotationDirection = 1;
	}
	
	public function set placeholder(sprite:Sprite):void
	{
		sprite.addChild(m_sprite);
		m_placeholder = sprite;
	}
	
	public function update():void
	{
		var factor:Number = 0;
		switch (m_state)
		{
			case k_STATE_COMING:
				m_timer += GameTime.frameMillis;
				if (m_timer >= 0)
				{
					if (m_timer < k_SHOP_ITEM_TIME)
					{
						factor = 1 - (m_timer / k_SHOP_ITEM_TIME);
						factor = Math.pow(factor, 2);
						m_sprite.y = factor * k_SHOP_ITEM_DISPLACEMENT;
						m_sprite.rotation = m_rotationDirection * k_SHOP_ITEM_ROTATION * factor;
					}
					else
					{
						m_sprite.y = 0;
						m_sprite.rotation = 0;
						m_state = k_STATE_SHOWN;
					}
				}
				break;
			
			case k_STATE_LEAVING:
				m_timer += GameTime.frameMillis;
				if (m_timer >= 0)
				{
					if (m_timer < k_SHOP_ITEM_TIME)
					{
						factor = m_timer / k_SHOP_ITEM_TIME;
						factor = Math.pow(factor, 2);
						m_sprite.y = factor * k_SHOP_ITEM_DISPLACEMENT;
						m_sprite.rotation = -m_rotationDirection * k_SHOP_ITEM_ROTATION * factor;
					}
					else
					{
						m_sprite.y = k_SHOP_ITEM_DISPLACEMENT;
						m_state = k_STATE_HIDDEN;
						m_sprite.visible = false;
					}
				}
				break;
			
			case k_STATE_BUY:
				m_timer += GameTime.frameMillis;
				if (m_timer < k_SHOP_ITEM_BUY_TIME)
				{
					factor = m_timer / k_SHOP_ITEM_BUY_TIME;
					m_sprite.alpha = Math.min(1, 2 - factor * 2);
					var scale:Number = 1 + factor * 0.5;
					m_sprite.scaleX = scale;
					m_sprite.scaleY = scale;
					m_sprite.y = -Math.sin(factor * Math.PI) * k_SHOP_ITEM_BUY_DISPLACEMENT;
				}
				else
				{
					m_state = k_STATE_HIDDEN;
					m_sprite.visible = false;
				}
				break;
		}
	}
	
	public function show(delay:int, rotationDirection:Number):void
	{
		m_rotationDirection = rotationDirection;
		m_sprite.visible = true;
		if (m_state == k_STATE_HIDDEN)
		{
			m_sprite.y = k_SHOP_ITEM_DISPLACEMENT;
			m_timer = -delay;
		}
		else
		{
			m_timer = k_SHOP_ITEM_TIME - m_timer + GameTime.frameMillis;
		}
		m_state = k_STATE_COMING;
	}
	
	public function hide(delay:int, rotationDirection:Number):void
	{
		m_rotationDirection = rotationDirection;
		if (m_state == k_STATE_SHOWN)
		{
			m_timer = -delay;
		}
		else
		{
			m_timer = k_SHOP_ITEM_TIME - m_timer + GameTime.frameMillis;
		}
		m_state = k_STATE_LEAVING;
	}
	
	public function buy():void
	{
		m_timer = 0;
		m_state = k_STATE_BUY;
	}
	
	public function isHidden():Boolean
	{
		return (m_state == k_STATE_HIDDEN);
	}
}