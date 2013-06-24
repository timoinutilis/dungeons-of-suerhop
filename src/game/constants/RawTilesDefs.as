package game.constants
{
	public class RawTilesDefs
	{
		public static const k_MASK_TILE:int = 0x000000FF;
		public static const k_MASK_OBJECT:int = 0x00FFFF00;
		public static const k_SHIFT_OBJECT:int = 8;

		public static const k_UNDEFINED:int = 0;
		public static const k_EARTH:int = 1;
		public static const k_FLOOR:int = 2;
		public static const k_SECRET:int = 3;

		public static const k_MAIN_CHARACTER:int = 1 << k_SHIFT_OBJECT;
		public static const k_DOOR:int = 2 << k_SHIFT_OBJECT;
		public static const k_KEY:int = 3 << k_SHIFT_OBJECT;
		public static const k_TREASURE:int = 4 << k_SHIFT_OBJECT;
		public static const k_MAGIC_STONE:int = 5 << k_SHIFT_OBJECT;
		public static const k_SHOP_ARMOR:int = 6 << k_SHIFT_OBJECT;
		public static const k_SHOP_SHIELD:int = 7 << k_SHIFT_OBJECT;
		public static const k_SHOP_WEAPON:int = 8 << k_SHIFT_OBJECT;
		public static const k_POTION:int = 9 << k_SHIFT_OBJECT;
		public static const k_ENEMY_1:int = 10 << k_SHIFT_OBJECT;
		public static const k_ENEMY_2:int = 11 << k_SHIFT_OBJECT;
		public static const k_ENEMY_3:int = 12 << k_SHIFT_OBJECT;
		public static const k_ENEMY_4:int = 13 << k_SHIFT_OBJECT;
		public static const k_ENEMY_5:int = 14 << k_SHIFT_OBJECT;
		public static const k_ENEMY_6:int = 15 << k_SHIFT_OBJECT;
		public static const k_ENEMY_7:int = 16 << k_SHIFT_OBJECT;
		public static const k_ENEMY_8:int = 17 << k_SHIFT_OBJECT;
		public static const k_ENEMY_9:int = 18 << k_SHIFT_OBJECT;
		public static const k_ENEMY_10:int = 19 << k_SHIFT_OBJECT;
		public static const k_DOOR_OPEN:int = 20 << k_SHIFT_OBJECT;
		public static const k_GEMSTONES:int = 21 << k_SHIFT_OBJECT;
		public static const k_DOOR_COLORS_1:int = 22 << k_SHIFT_OBJECT;
		public static const k_DOOR_COLORS_2:int = 23 << k_SHIFT_OBJECT;
		public static const k_DOOR_COLORS_3:int = 24 << k_SHIFT_OBJECT;
		public static const k_DOOR_COLORS_4:int = 25 << k_SHIFT_OBJECT;
		public static const k_DOOR_COLORS_OPEN_1:int = 26 << k_SHIFT_OBJECT;
		public static const k_DOOR_COLORS_OPEN_2:int = 27 << k_SHIFT_OBJECT;
		public static const k_DOOR_COLORS_OPEN_3:int = 28 << k_SHIFT_OBJECT;
		public static const k_DOOR_COLORS_OPEN_4:int = 29 << k_SHIFT_OBJECT;
		public static const k_DOOR_BUTTON_1:int = 30 << k_SHIFT_OBJECT;
		public static const k_DOOR_BUTTON_2:int = 31 << k_SHIFT_OBJECT;
		public static const k_DOOR_BUTTON_3:int = 32 << k_SHIFT_OBJECT;
		public static const k_DOOR_BUTTON_4:int = 33 << k_SHIFT_OBJECT;
		public static const k_MESSAGE:int = 34 << k_SHIFT_OBJECT;
		public static const k_CROSS:int = 35 << k_SHIFT_OBJECT;
		public static const k_BROKEN_FLOOR:int = 36 << k_SHIFT_OBJECT;
		public static const k_BROKEN_FLOOR_2_GOOD:int = 37 << k_SHIFT_OBJECT;
		public static const k_BROKEN_FLOOR_2_BAD:int = 38 << k_SHIFT_OBJECT;
		public static const k_HOLE:int = 39 << k_SHIFT_OBJECT;
		
		public static const k_DISCOVERED:int = 1 << 31;
	}
}