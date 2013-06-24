package inutilib.media
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import inutilib.UserOptions;

	public class SoundManager
	{		
		private static var s_instance:SoundManager;
		
		private var m_urlEntities:Object;
		private var m_enabled:Boolean;

		
		public static function get instance():SoundManager
		{
			if (s_instance == null)
			{
				s_instance = new SoundManager();
			}
			return s_instance;
		}

		public function SoundManager()
		{
			m_urlEntities = new Object();
			m_enabled = UserOptions.instance.getBoolean(UserOptions.k_SFX);
		}
		
		public function request(url:String, id:String = null):Sound
		{
			trace("SoundManager: request " + url);
			if (id == null)
			{
				id = url;
			}
			var entity:Entity = m_urlEntities[id];
			if (entity == null)
			{
				entity = new Entity(url);
				m_urlEntities[id] = entity;
			}
			entity.addInstance();
			return entity.getSound();
		}
		
		public function release(id:String):void
		{
			trace("SoundManager: release " + id);
			var entity:Entity = m_urlEntities[id];
			entity.removeInstance();
		}
		
		public function play(id:String, loops:int = 0, volume:Number = 1.0):SoundChannel
		{
			if (m_enabled)
			{
				var entity:Entity = m_urlEntities[id];
				if (entity != null)
				{
					var sound:Sound = entity.getSound();
					var sndTrans:SoundTransform;
					if (volume != 1.0)
					{
						sndTrans = new SoundTransform(volume);
					}
					return sound.play(0, loops, sndTrans);
				}
			}
			return null;
		}
		
		public function getSound(id:String):Sound
		{
			var entity:Entity = m_urlEntities[id];
			if (entity != null)
			{
				return entity.getSound();
			}
			return null;
		}
		
		public function set enabled(value:Boolean):void
		{
			if (value != m_enabled)
			{
				UserOptions.instance.setBoolean(UserOptions.k_SFX, value);
				m_enabled = value;
			}
		}
		
		public function get enabled():Boolean
		{
			return m_enabled;
		}
	}
}


import flash.media.Sound;
import flash.net.URLRequest;

class Entity
{
	private var m_url:String;
	private var m_sound:Sound;
	private var m_instanceCounter:int;

	public function Entity(url:String)
	{
		m_url = url;
	}
	
	public function addInstance():void
	{
		m_instanceCounter++;
		if (m_sound == null)
		{
			m_sound = new Sound(new URLRequest(m_url));
		}
	}
	
	public function removeInstance():void
	{
		m_instanceCounter--;
	}
	
	public function getSound():Sound
	{
		return m_sound;
	}
}