package inutilib.fx
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class AnimFx extends FxObject
	{
		public function AnimFx(spriteClass:Class)
		{
			var sprite:MovieClip = new spriteClass() as MovieClip;
			super(sprite as Sprite);
		}
		
		override public function hasFinished():Boolean
		{
			var movieClip:MovieClip = sprite as MovieClip;
			return (movieClip.currentFrame == movieClip.totalFrames);
		}

	}
}