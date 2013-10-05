package game
{
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class GameDefs
	{
		public static const k_VERSION:String = "2.4 beta";
		
		public static const k_USE_ONLINE_SERVER:Boolean = true;
		public static const k_OFFLINE_SERVER_DELAY:Number = 2000;
		public static const k_ONLINE_SERVER_LOGIN_URL:String = "http://apps.timokloss.com/dungeons/backend/login.php";
		public static const k_ONLINE_SERVER_REQUEST_URL:String = "http://apps.timokloss.com/dungeons/backend/request.php";
		public static const k_ONLINE_SERVER_SEND_URL:String = "http://apps.timokloss.com/dungeons/backend/send.php";
		
		public static const k_DEFAULT_LOCALE:String = "en_US";
		public static const k_LOCALES:Array = ["en_US", "de_DE", "es_ES", "fr_FR"];
		
		public static const k_BG_COLOR:int = 0x000000;

		public static const k_TEXT_FORMAT:TextFormat = new TextFormat("_playtime");
		public static const k_TEXT_FORMAT_BOLD:TextFormat = new TextFormat("_playtime");

		public static const k_CREDITS_TEXT_FORMAT:TextFormat = new TextFormat("_playtime", 24, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER);

		public static const k_FX_TEXT_FORMAT:TextFormat = new TextFormat("_playtime", 24);
		public static const k_FX_OUTLINE_COLOR:int = 0x000000;

		public static const k_TOOLTIP_OUTLINE_COLOR:int = 0x000000;
		public static const k_TOOLTIP_TEXT_FORMAT:TextFormat = new TextFormat("_playtime", 20, 0xFFFFFF);
		
		public static const k_MUSIC_FADE_TIME:int = 500;
		
		public static const k_LIST_SCROLL_TIME:int = 1000;
		public static const k_LIST_SCROLL_THROUGH_TIME:int = 1500;
		
		public static const k_TILE_WIDTH:int = 48;
		public static const k_TILE_HEIGHT:int = 48;
		public static const k_DISCOVER_TILE_WIDTH:int = 96;
		public static const k_DISCOVER_TILE_HEIGHT:int = 96;
		
		public static const k_MAP_DEFAULT_NUM_COLUMNS:int = 30;
		public static const k_MAP_DEFAULT_NUM_ROWS:int = 30;
		
		public static const k_EDITOR_SCROLL:int = k_TILE_WIDTH * 4;
		public static const k_EDITOR_FLASH_TIME:Number = 1500;
		public static const k_EDITOR_FADE_TIME:Number = 1000;
		public static const k_EDITOR_MAP_INCREASE_TILES:int = 4;
		
		// editor rules
		
		public static const k_MAX_SECRETS_TOGETHER:int = 3;
		public static const k_MAX_REWARDS_TOGETHER:int = 9;
		
		// gameplay
		
		public static const k_POINTS_PER_LEVEL:int = 500;
		
		public static const k_MAX_HEALTH:int = 30;
		
		public static const k_GAME_TREASURE_COINS_MIN:int = 10;
		public static const k_GAME_TREASURE_COINS_MAX:int = 20;
		
		public static const k_PRICES_ARMOR:Array = [20, 40, 60, 80, 100, 120, 140, 160, 180];
		public static const k_PRICES_SHIELD:Array = [20, 40, 60, 80, 100, 120, 140, 160, 180];
		public static const k_PRICES_WEAPON:Array = [20, 40, 60, 80, 100, 120, 140, 160, 180];

		public static const k_SHIELD_LEVEL_BLOCKS:Array = [0.0, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6];
		public static const k_WEAPON_LEVEL_DAMAGES:Array = [1, 4, 5, 6, 7, 8, 9, 10, 11, 12];
		public static const k_ARMOR_LEVEL_PROTECTIONS:Array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
		
		public static const k_ENEMY_HEALTH_LEVEL_1:int = 5;
		public static const k_ENEMY_HEALTH_MIN:int = 10;
		public static const k_ENEMY_HEALTH_MAX:int = 15;
		
		public static const k_ENEMY_LEVEL_BLOCKS:Array = [0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45];
		public static const k_ENEMY_LEVEL_DAMAGES:Array = [1, 2, 4, 5, 7, 8, 10, 11, 13, 14];
		public static const k_ENEMY_LEVEL_PROTECTIONS:Array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
		
		public static const k_SECONDS_WALK:Number = 0.7;
		public static const k_SECONDS_OPEN_DOOR:Number = 2;
		public static const k_SECONDS_FIGHT_ROUND:Number = 2;
		public static const k_SECONDS_SHOP_BUY:Number = 10;
		
		public static const k_SCORE_WIN:int = 50;
		public static const k_SCORE_SECRET_WAY:int = 1;
		public static const k_SCORE_GEMSTONES:int = 5;
		public static const k_SCORE_TREASURE:int = 5;
		public static const k_SCORE_KEY:int = 1;
		public static const k_SCORE_DOOR:int = 1;
		public static const k_SCORE_POTION:int = 1;
		public static const k_SCORE_LEVEL_ENEMY:Array = [10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
	}
}