package inutilib.map
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import inutilib.media.ImageManager;
	
	public class IDImagesLoader extends EventDispatcher
	{
		public static const k_TYPE_BITMAP_DATA:int = 0;
		public static const k_TYPE_SWF_CLASS:int = 1;
		
		private var m_type:int;
		private var m_loader:URLLoader;
		private var m_bitmaps:Array;
		private var m_spriteClasses:Array;
		private var m_urlIds:Object;
		private var m_numImagesToLoad:int;
		private var m_imagesPath:String;
		
		public function IDImagesLoader(type:int)
		{
			super(null);
			m_type = type;
		}
		
		public function requestFromXML(url:String, imagesPath:String):void
		{
			m_imagesPath = imagesPath;
			
			if (m_type == k_TYPE_BITMAP_DATA)
			{
				m_bitmaps = new Array();
			}
			else
			{
				m_spriteClasses = new Array();
			}
			
//			m_urlIds = new Object();
			
			m_loader = new URLLoader();
			var urlReq:URLRequest = new URLRequest(url);
			m_loader.addEventListener(Event.COMPLETE, onLoadXMLComplete, false, 0, true);
			m_loader.load(urlReq);
		}
		
		public function release():void
		{
			if (m_loader != null)
			{
				m_loader.close();
			}
			
//			for (var url:String in m_urlIds)
//			{
//				ImageManager.instance.release(url);
//			}
		}
		
		public function get bitmaps():Array
		{
			return m_bitmaps;
		}
		
		public function get spriteClasses():Array
		{
			return m_spriteClasses;
		}
		
		private function onLoadXMLComplete(e:Event):void
		{
			var xml:XML = new XML(m_loader.data);
			m_numImagesToLoad = xml.elements().length();
			for each (var element:XML in xml.elements())
			{
				var spare:Object = new Object();
				spare.id = parseInt(element.attribute("id").toString());
				spare.symbol = element.attribute("symbol").toString()
				var url:String = element.toString();
//				m_urlIds[m_imagesPath + url] = id;
				ImageManager.instance.request(m_imagesPath + url, onLoadImageComplete, spare);
			}
			m_loader = null;
		}
		
		private function onLoadImageComplete(url:String, spare:Object):void
		{
			var id:int = spare.id; //m_urlIds[url];
			
			switch (m_type)
			{
				case k_TYPE_BITMAP_DATA:
					m_bitmaps[id] = ImageManager.instance.getBitmapData(url);
					break;
				
				case k_TYPE_SWF_CLASS:
					m_spriteClasses[id] = ImageManager.instance.getSpriteClass(url, spare.symbol);
					break;
			}
			
			m_numImagesToLoad--;
			if (m_numImagesToLoad == 0)
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
	}
}