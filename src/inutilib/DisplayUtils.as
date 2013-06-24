package inutilib
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class DisplayUtils
	{
		public static const k_BUTTON_TEXT_FIELD:String = "text";
		
		public static function setText(container:DisplayObjectContainer, textFieldName:String, text:String, textFormat:TextFormat = null, optimizedAnimation:Boolean = false):TextField
		{
			var textField:TextField = container.getChildByName(textFieldName) as TextField;
			setTextField(textField, text, textFormat, optimizedAnimation);
			return textField;
		}
		
		public static function setTextField(textField:TextField, text:String, textFormat:TextFormat = null, optimizedAnimation:Boolean = false):void
		{
			if (textFormat != null)
			{
				textField.embedFonts = true;				
				textField.defaultTextFormat = textFormat;
				textField.antiAliasType = optimizedAnimation ? AntiAliasType.NORMAL : AntiAliasType.ADVANCED;
			}
			textField.text = text;
		}
		
		public static function setButtonText(container:DisplayObjectContainer, buttonName:String, text:String, textFormat:TextFormat = null):SimpleButton
		{
			var simpleButton:SimpleButton = container.getChildByName(buttonName) as SimpleButton;
			setButtonStateText(simpleButton.upState, text, textFormat);
			setButtonStateText(simpleButton.overState, text, textFormat);
			setButtonStateText(simpleButton.downState, text, textFormat);
			return simpleButton;
		}
		
		private static function setButtonStateText(object:DisplayObject, text:String, textFormat:TextFormat = null):void
		{
			if (object is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = object as DisplayObjectContainer;
				for (var i:int = 0; i < container.numChildren; i++)
				{
					var child:DisplayObject = container.getChildAt(i);
					if (child is TextField)
					{
						setTextField(child as TextField, text, textFormat);
					}
				}
			}
			else if (object is TextField)
			{
				setTextField(object as TextField, text, textFormat);
			}
		}
		
		public static function collectAllSprites(rootSprite:Sprite, map:Object):void
		{
			for (var i:int = 0; i < rootSprite.numChildren; i++)
			{
				var child:Sprite = rootSprite.getChildAt(i) as Sprite;
				if (child != null)
				{
					var name:String = child.name;
					if (map.hasOwnProperty(name))
					{
						name += ".";
					}
					map[name] = child;
					collectAllSprites(child, map);
				}
			}
		}
		
		public static function printDisplayObjects(rootObject:DisplayObjectContainer, prefix:String = ""):void
		{
			for (var i:int = 0; i < rootObject.numChildren; i++)
			{
				var child:DisplayObject = rootObject.getChildAt(i);
				if (child != null)
				{
					trace(prefix + child.name + " - " + child);
					if (child is DisplayObjectContainer)
					{
						printDisplayObjects(child as DisplayObjectContainer, prefix + "   ");
					}
				}
			}
		}
	}
}