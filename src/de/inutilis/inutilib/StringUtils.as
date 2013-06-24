package de.inutilis.inutilib
{
	import com.adobe.utils.StringUtil;

	public class StringUtils
	{
		public static function toTitle(text:String):String
		{
			text = StringUtil.trim(text);
			if (text.length > 0)
			{
				var titleText:String = text.charAt(0).toUpperCase();
				var pos:int = 1;
				var nextSpace:int = -1;
				while ((nextSpace = text.indexOf(" ", pos)) != -1)
				{
					titleText += text.substring(pos, nextSpace + 1).toLowerCase();
					pos = nextSpace + 1;
					titleText += text.substr(pos, 1);
					pos++;
				}
				titleText += text.substring(pos).toLowerCase();
				return titleText;
			}
			return text;
		}
	}
}