package game.map
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	import game.GameDefs;
	import game.constants.RawTilesDefs;
	import game.constants.TilesDefs;

	public class TilePreview extends GameSprite
	{
		public function TilePreview(gameMap:GameMap, bitmaps:Array, rawTile:int)
		{
			super(gameMap);
			
			var firstTile:int = 0;
			switch (rawTile)
			{
				case RawTilesDefs.k_EARTH:
					firstTile = TilesDefs.k_EARTH_1A;
					break;
				
				case RawTilesDefs.k_SECRET:
					firstTile = TilesDefs.k_SECRET_1A;
					break;

				case RawTilesDefs.k_FLOOR:
					firstTile = TilesDefs.k_FLOOR_1A;
					break;
			}
			
			var tileMovieClip:MovieClip = new MovieClip;
			
			for (var i:int = 0; i < 4; i++)
			{
				var bitmap:Bitmap = new Bitmap(bitmaps[firstTile + i] as BitmapData);
				bitmap.x = (i % 2 == 0) ? -GameDefs.k_TILE_WIDTH : 0;
				bitmap.y = (i < 2) ? -GameDefs.k_TILE_HEIGHT : 0;
				tileMovieClip.addChild(bitmap);
			}
			
			movieClip = tileMovieClip;
		}
		
		override public function isPositionValid():Boolean
		{
			return true;
		}

	}
}