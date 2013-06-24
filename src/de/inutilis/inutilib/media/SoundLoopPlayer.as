package de.inutilis.inutilib.media
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;

	public class SoundLoopPlayer
	{
		public static const k_STATE_STOP:int = 0;
		public static const k_STATE_FADE_IN:int = 1;
		public static const k_STATE_PLAY:int = 2;
		public static const k_STATE_FADE_OUT:int = 3;
		
		private var m_sound:Sound;
		private var m_updateTime:int;
		private var m_soundChannel:SoundChannel;
		private var m_soundTransform:SoundTransform;
		private var m_state:int;
		private var m_timer:Timer;
		private var m_fadeTime:int;
		
		public function SoundLoopPlayer(sound:Sound, updateTime:int)
		{
			m_sound = sound;
			m_updateTime = updateTime;
			
			m_soundTransform = new SoundTransform(0);
			
			m_timer = new Timer(m_updateTime);
			m_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
		}
		
		public function release():void
		{
			if (m_soundChannel != null)
			{
				stopNow();
			}
		}
		
		public function get currentState():int
		{
			return m_state;
		}
		
		public function get sound():Sound
		{
			return m_sound;
		}
		
		public function play(fadeInTime:int):void
		{
			if (m_state == k_STATE_FADE_OUT || m_state == k_STATE_STOP)
			{
				m_fadeTime = fadeInTime;
				
				if (fadeInTime > 0)
				{
					m_state = k_STATE_FADE_IN;
				}
				else
				{
					m_state = k_STATE_PLAY;
					m_soundTransform.volume = 1;
				}
	
				if (m_soundChannel == null)
				{
					m_soundChannel = m_sound.play(0, int.MAX_VALUE, m_soundTransform);
					m_timer.start();
				}
				else
				{
					m_soundChannel.soundTransform = m_soundTransform;
				}
			}
		}
		
		public function stop(fadeOutTime:int):void
		{
			if (m_state == k_STATE_FADE_IN || m_state == k_STATE_PLAY)
			{
				m_fadeTime = fadeOutTime;
				
				if (fadeOutTime > 0)
				{
					m_state = k_STATE_FADE_OUT;
				}
				else
				{
					stopNow();
				}
			}	
		}
		
		private function stopNow():void
		{
			m_soundTransform.volume = 0;
			m_soundChannel.stop();
			m_soundChannel = null;
			m_state = k_STATE_STOP;
			m_timer.stop();
		}
		
		private function onTimer(e:TimerEvent):void
		{
			var volume:Number;
			
			if (m_soundChannel != null)
			{
				switch (m_state)
				{
					case k_STATE_FADE_IN:
						volume = m_soundTransform.volume;
						volume += m_updateTime / m_fadeTime;
						if (volume >= 1)
						{
							m_soundTransform.volume = 1;
							m_state = k_STATE_PLAY;
						}
						else
						{
							m_soundTransform.volume = volume;
						}
						m_soundChannel.soundTransform = m_soundTransform;
						break;
					
					case k_STATE_FADE_OUT:
						volume = m_soundTransform.volume;
						volume -= m_updateTime / m_fadeTime;
						if (volume <= 0)
						{
							stopNow();
						}
						else
						{
							m_soundTransform.volume = volume;
							m_soundChannel.soundTransform = m_soundTransform;
						}
						break;
				}
			}
		}
	}
}