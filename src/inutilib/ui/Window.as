package inutilib.ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import inutilib.GameTime;
	import inutilib.MathUtils;
	import inutilib.media.SoundManager;

	public class Window
	{
		protected static const k_STATE_CLOSED:int = 0;
		protected static const k_STATE_OPENING:int = 1;
		protected static const k_STATE_OPEN:int = 2;
		protected static const k_STATE_CLOSING:int = 3;
		
		private var m_container:DisplayObjectContainer;
		private var m_ui:Sprite;
		private var m_state:int;
		private var m_position:int;
		private var m_offsetX:Number;
		private var m_offsetY:Number;
		private var m_exclusive:Boolean;
		private var m_buttonSoundId:String;
		private var m_timer:int;
		private var m_animationTime:int;
		private var m_blocker:Sprite;
		
		public function Window(container:DisplayObjectContainer, ui:Sprite, animationTime:int, position:int = 0 /*PositionRectangle.k_TOP_LEFT*/, exclusive:Boolean = false)
		{
			m_container = container;
			m_ui = ui;
			m_animationTime = animationTime;
			m_position = position;
			m_exclusive = exclusive;
			
			m_state = k_STATE_CLOSED;
			m_offsetX = 0;
			m_offsetY = 0;
		}
		
		public function set offsetX(x:Number):void
		{
			m_offsetX = x;
		}

		public function set offsetY(y:Number):void
		{
			m_offsetY = y;
		}
		
		public function open():void
		{
			WindowManager.instance.addWindow(this);
			m_state = k_STATE_OPENING;
			m_timer = 0;
			
			var posRect:PositionRectangle = new PositionRectangle(0, 0, m_container.stage.stageWidth, m_container.stage.stageHeight);
			var posPoint:Point = posRect.getPoint(m_position);
			m_ui.x = posPoint.x + m_offsetX;
			m_ui.y = posPoint.y + m_offsetY;
			var scale:Number = 0.5;
			m_ui.scaleX = scale;
			m_ui.scaleY = scale;
			m_ui.alpha = 0.0;
			
			if (m_exclusive)
			{
				m_blocker = new Sprite();
				m_blocker.graphics.beginFill(0x000000, 0.3);
				m_blocker.graphics.drawRect(0, 0, m_container.stage.stageWidth, m_container.stage.stageHeight);
				m_blocker.alpha = 0.0;
				m_container.addChild(m_blocker);
			}
			
			m_container.addChild(m_ui);
		}
		
		public function close():void
		{
			if (m_state == k_STATE_OPEN || m_state == k_STATE_OPENING)
			{
				m_state = k_STATE_CLOSING;
				m_timer = m_animationTime;
			}
		}
		
		public function update():void
		{
			var scale:Number;
			
			switch (m_state)
			{
				case k_STATE_OPENING:
					m_timer += GameTime.frameMillis;
					if (m_timer >= m_animationTime)
					{
						m_ui.scaleX = 1.0;
						m_ui.scaleY = 1.0;
						m_ui.alpha = 1.0;
						m_state = k_STATE_OPEN;
					}
					else
					{
						scale = MathUtils.interpolateSmoothstep(0.5 + m_timer * 0.5 / m_animationTime);
						m_ui.scaleX = scale;
						m_ui.scaleY = scale;
						m_ui.alpha = m_timer / m_animationTime;
					}
					if (m_exclusive)
					{
						m_blocker.alpha = m_ui.alpha;
					}
					break;
				
				case k_STATE_CLOSING:
					m_timer -= GameTime.frameMillis;
					if (m_timer <= 0)
					{
						m_container.removeChild(m_ui);
						if (m_exclusive)
						{
							m_container.removeChild(m_blocker);
						}
						WindowManager.instance.removeWindow(this);
						m_container.stage.focus = null;
						m_state = k_STATE_CLOSED;
					}
					else
					{
						scale = MathUtils.interpolateSmoothstep(0.5 + m_timer * 0.5 / m_animationTime);
						m_ui.scaleX = scale;
						m_ui.scaleY = scale;
						m_ui.alpha = m_timer / m_animationTime;
						if (m_exclusive)
						{
							m_blocker.alpha = m_ui.alpha;
						}
					}
					break;
			}
		}
		
		public function get ui():Sprite
		{
			return m_ui;
		}
		
		public function get exclusive():Boolean
		{
			return m_exclusive;
		}
		
		public function setButtonSound(id:String):void
		{
			m_buttonSoundId = id;
			m_ui.addEventListener(MouseEvent.MOUSE_DOWN, onButton, false, 0, true);
		}
		
		private function onButton(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			
			if (buttonName != null && buttonName.indexOf("button") == 0)
			{
				SoundManager.instance.play(m_buttonSoundId);
			}
		}

	}
}