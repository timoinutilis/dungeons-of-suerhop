package inutilib.ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import inutilib.MathUtils;

	public class ToolTips
	{
		private var m_container:DisplayObjectContainer;
		private var m_position:int;
		private var m_toolTips:Object;
		private var m_sprite:Sprite;
		private var m_textField:TextField;
		private var m_minX:Number;
		private var m_maxX:Number;
		private var m_minY:Number;
		private var m_maxY:Number;

		
		public function ToolTips(container:DisplayObjectContainer, stage:Stage, textFormat:TextFormat, outlineColor:int, position:int)
		{
			m_container = container;
			m_position = position;
			
			container.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			container.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
			container.addEventListener(MouseEvent.ROLL_OUT, onMouseOut, false, 0, true);
			//container.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			
			m_minX = 3;
			m_minY = 3;
			m_maxX = stage.stageWidth - 3;
			m_maxY = stage.stageHeight - 3;
			
			m_toolTips = new Object();
			
			m_sprite = new Sprite();
			m_sprite.mouseEnabled = false;
			m_sprite.mouseChildren = false;
			
			m_textField = new TextField();
			m_textField.embedFonts = true;
			m_textField.defaultTextFormat = textFormat;
			m_textField.antiAliasType = AntiAliasType.ADVANCED;
			m_textField.autoSize = TextFieldAutoSize.LEFT;
			m_textField.filters = [new GlowFilter(outlineColor, 1.0, 4, 4, 16)];
			
			m_sprite.addChild(m_textField);
		}
		
		public function release():void
		{
			m_container.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			m_container.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			m_container.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			//m_container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			if (m_sprite.parent != null)
			{
				m_container.stage.removeChild(m_sprite);
			}
		}
	
		public function set minX(value:Number):void
		{
			m_minX = value;
		}

		public function set maxX(value:Number):void
		{
			m_maxX = value;
		}

		public function set minY(value:Number):void
		{
			m_minY = value;
		}
		
		public function set maxY(value:Number):void
		{
			m_maxY = value;
		}
		
		public function addToolTip(buttonName:String, text:String):void
		{
			m_toolTips[buttonName] = text;
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			var object:DisplayObject = e.target as DisplayObject;
			var buttonName:String = object.name;

			var rect:Rectangle;
			var posRect:PositionRectangle;
			var posPoint:Point;

			if (m_toolTips.hasOwnProperty(buttonName))
			{
				m_textField.text = m_toolTips[buttonName];
				
				posRect = new PositionRectangle(0, 0, m_textField.width, m_textField.height);
				posPoint = posRect.getOppositePoint(m_position);
				m_textField.x = -posPoint.x;
				m_textField.y = -posPoint.y;
				
				rect = object.getRect(m_container.stage);
				posRect = new PositionRectangle(rect.left, rect.top, rect.width, rect.height);
				posPoint = posRect.getPoint(m_position);

				setPosition(posPoint.x, posPoint.y);
				
				m_container.stage.addChild(m_sprite);
			}
		}

		private function onMouseOut(e:MouseEvent):void
		{
			if (m_container.stage.contains(m_sprite))
			{
				m_container.stage.removeChild(m_sprite);
			}
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
//			if (m_sprite.parent != null)
//			{
//				setPosition(e.stageX, e.stageY);
//			}
		}
		
		private function setPosition(x:Number, y:Number):void
		{
			var rect:Rectangle = m_sprite.getRect(m_sprite);
			m_sprite.x = MathUtils.clamp(x, m_minX - rect.left, m_maxX - rect.right);
			m_sprite.y = MathUtils.clamp(y, m_minY - rect.top, m_maxY - rect.bottom);
		}
	}
}