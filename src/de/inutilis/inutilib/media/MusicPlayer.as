package de.inutilis.inutilib.media
{
	import flash.errors.IOError;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	import de.inutilis.inutilib.UserOptions;

	public class MusicPlayer
	{
		private static var s_instance:MusicPlayer;
		
		private var m_url:String;
		private var m_currentPlayer:SoundLoopPlayer;
		private var m_oldPlayer:SoundLoopPlayer;
		private var m_updateTime:int;
		private var m_enabled:Boolean;

		public static function get instance():MusicPlayer
		{
			if (s_instance == null)
			{
				s_instance = new MusicPlayer();
			}
			return s_instance;
		}

		public function MusicPlayer()
		{
			m_updateTime = 50;
			m_enabled = UserOptions.instance.getBoolean(UserOptions.k_MUSIC);
		}
		
		public function set updateTime(time:int):void
		{
			m_updateTime = time;
		}
		
		public function play(url:String, fadeOutTime:int, fadeInTime:int = 0):void
		{
			if (m_url == null || url != m_url)
			{
				if (m_enabled)
				{
					stop(fadeOutTime);
					
					var sound:Sound = new Sound(new URLRequest(url));
					m_currentPlayer = new SoundLoopPlayer(sound, m_updateTime);
					m_currentPlayer.play(fadeInTime);
				}
				
				m_url = url;
			}
		}
		
		public function stop(fadeOutTime:int):void
		{
			if (m_currentPlayer != null)
			{
				m_oldPlayer = m_currentPlayer;
				m_oldPlayer.stop(fadeOutTime);
				m_currentPlayer = null;
			}
			m_url = null;
		}
		
		public function update():void
		{
			if (m_oldPlayer != null && m_oldPlayer.currentState == SoundLoopPlayer.k_STATE_STOP)
			{
				try
				{
					m_oldPlayer.sound.close();
				}
				catch (e:IOError)
				{
					// ignore
				}
				m_oldPlayer.release();
				m_oldPlayer = null;
			}
		}
		
		public function set enabled(value:Boolean):void
		{
			if (value != m_enabled)
			{
				UserOptions.instance.setBoolean(UserOptions.k_MUSIC, value);
				m_enabled = value;
				
				if (m_enabled)
				{
					if (m_url != null)
					{
						var sound:Sound = new Sound(new URLRequest(m_url));
						m_currentPlayer = new SoundLoopPlayer(sound, m_updateTime);
						m_currentPlayer.play(0);
					}
				}
				else
				{
					if (m_currentPlayer != null)
					{
						m_currentPlayer.stop(0);
						m_currentPlayer = null;
					}
					
					if (m_oldPlayer != null)
					{
						m_oldPlayer.stop(0);
						m_oldPlayer = null;
					}
				}
			}
		}
		
		public function get enabled():Boolean
		{
			return m_enabled;
		}
	}
}