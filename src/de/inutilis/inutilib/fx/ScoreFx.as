package de.inutilis.inutilib.fx
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import de.inutilis.inutilib.GameTime;
	
	public class ScoreFx extends FxObject
	{
		private var m_time:int;
		private var m_speed:Number;
		private var m_timer:int;
		
		public function ScoreFx(text:String, textColor:int, outlineColor:int, textFormat:TextFormat, time:int, speed:Number)
		{
			m_time = time;
			m_speed = speed;
			
			var sprite:Sprite = new Sprite();
			var textField:TextField = new TextField();
			textField.embedFonts = true;
			textField.defaultTextFormat = textFormat;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.text = text;
			textField.textColor = textColor;
			textField.filters = [new GlowFilter(outlineColor, 1.0, 4, 4, 16)];
			
			textField.width;
			textField.x = -textField.width / 2;
			sprite.alpha = 0;
			
			sprite.addChild(textField);
			
			super(sprite);
		}
		
		override public function update():void
		{
			var frameMillis:int = GameTime.frameMillis;
			m_timer += frameMillis;
			
			sprite.y += m_speed * frameMillis / 1000;
			sprite.alpha = Math.sin(m_timer / m_time * Math.PI);
		}
		
		override public function hasFinished():Boolean
		{
			return m_timer >= m_time;
		}

	}
}