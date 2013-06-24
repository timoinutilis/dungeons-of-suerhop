package inutilib.media
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;

	public class ImageManager
	{
		private static var s_instance:ImageManager;
		
		private var m_urlEntities:Object;
		
		public static function get instance():ImageManager
		{
			if (s_instance == null)
			{
				s_instance = new ImageManager();
			}
			return s_instance;
		}
		
		public function ImageManager()
		{
			m_urlEntities = new Object();
		}
		
		public function request(url:String, onLoadedFunc:Function, spare:Object = null):void
		{
			trace("ImageManager: request " + url);
			var entity:Entity = m_urlEntities[url];
			if (entity == null)
			{
				entity = new Entity(url);
				m_urlEntities[url] = entity;
			}
			
			entity.addInstance(onLoadedFunc, spare);
		}

		public function release(url:String):void
		{
			trace("ImageManager: release " + url);
			var entity:Entity = m_urlEntities[url];
			entity.removeInstance();
		}
		
		public function getBitmapData(url:String):BitmapData
		{
			var entity:Entity = m_urlEntities[url];
			return entity.bitmapData;
		}
		
		public function getSpriteClass(url:String, symbol:String):Class
		{
			var entity:Entity = m_urlEntities[url];
			return entity.getSpriteClass(symbol);
		}
		
		public function existsSpriteClass(url:String, symbol:String):Boolean
		{
			var entity:Entity = m_urlEntities[url];
			return entity.existsSpriteClass(symbol);
		}
		
		public function getContent(url:String):DisplayObject
		{
			var entity:Entity = m_urlEntities[url];
			return entity.getContent();
		}
		
	}
	
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.net.URLRequest;

class Entity
{
	private var m_url:String;
	private var m_isLoaded:Boolean;
	private var m_onLoadedFuncs:Array;
	private var m_spares:Array;
	private var m_loader:Loader;
	private var m_instanceCounter:int;
	
	public function Entity(url:String)
	{
		m_url = url;
		m_onLoadedFuncs = new Array();
		m_spares = new Array();
	}
	
	public function addInstance(onLoadedFunc:Function, spare:Object = null):void
	{
		m_instanceCounter++;
		if (m_isLoaded)
		{
			onLoadedFunc(m_url, spare);
		}
		else
		{
			m_onLoadedFuncs.push(onLoadedFunc);
			m_spares.push(spare);
			
			if (m_loader == null)
			{
				m_loader = new Loader();
				var urlReq:URLRequest = new URLRequest(m_url);
				m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
				m_loader.load(urlReq);
			}
		}
	}
	
	public function removeInstance():void
	{
		m_instanceCounter--;
	}
	
	public function get bitmapData():BitmapData
	{
		return (m_loader.content as Bitmap).bitmapData;
	}
	
	public function getSpriteClass(symbol:String):Class
	{
		return m_loader.contentLoaderInfo.applicationDomain.getDefinition(symbol) as Class;
	}

	public function existsSpriteClass(symbol:String):Boolean
	{
		return m_loader.contentLoaderInfo.applicationDomain.hasDefinition(symbol);
	}

	public function getContent():DisplayObject
	{
		if (m_loader.content is MovieClip)
		{
			(m_loader.content as MovieClip).gotoAndPlay(1);
		}
		return m_loader.content;
	}
	
	private function onLoadComplete(e:Event):void
	{
		m_isLoaded = true;
		for (var i:int = 0; i < m_onLoadedFuncs.length; i++)
		{
			var func:Function = m_onLoadedFuncs[i];
			var spare:Object = m_spares[i];
			func(m_url, spare);
		}
		m_onLoadedFuncs = null;
		m_spares = null;
	}
}