package game
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	
	import game.ui.LoadingScreen;

	public class Preloader extends MovieClip
	{
		private var m_loadingScreen:LoadingScreen;
		
		public function Preloader()
		{
			super();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			
			m_loadingScreen = new LoadingScreen(stage.stageWidth, stage.stageHeight, true);
			m_loadingScreen.name = "LoadingScreen";
			addChild(m_loadingScreen);
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			m_loadingScreen.progress = e.bytesLoaded / e.bytesTotal * 0.8;
		}

		private function onEnterFrame(e:Event):void
		{
			if (currentFrame == totalFrames)
			{
				stop();
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				
				var mainClass:Class = getDefinitionByName("game.MagicStone") as Class;
				addChild(new mainClass() as DisplayObject);
			}
		}
				 
	}
}