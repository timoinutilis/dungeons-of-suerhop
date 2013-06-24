package game.states
{
	import flash.events.KeyboardEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import game.FileDefs;
	import game.GameDefs;
	import game.MagicStone;
	import game.map.Enemy;
	import game.map.GameSprite;
	import game.map.MainCharacter;
	
	import inutilib.GameTime;
	import inutilib.MathUtils;
	import inutilib.fx.FxManager;
	import inutilib.fx.ScoreFx;
	import inutilib.media.SoundManager;
	import inutilib.statemachine.State;
	import inutilib.statemachine.StateMachine;
	
	public class FightState extends State
	{
		private static const k_STATE_ENEMY_ATTACK:int = 0;
		private static const k_STATE_PLAYER_INPUT:int = 1;
		private static const k_STATE_PLAYER_ATTACK:int = 2;
		private static const k_STATE_ENEMY_WAIT:int = 3;
		private static const k_STATE_EXIT:int = 4;
		
		private var m_inGame:InGameState;
		private var m_enemy:Enemy;
		private var m_mainCharacter:MainCharacter;
		private var m_state:int;
		private var m_attackKey:uint;
		private var m_timer:int;
		private var m_blockSuccessful:Boolean;
		private var m_enemyHealth:int;
		
		public function FightState(stateMachine:StateMachine, inGame:InGameState, enemy:Enemy, moveDir:int)
		{
			super(stateMachine);
			m_inGame = inGame;
			m_enemy = enemy;
			
			m_mainCharacter = m_inGame.gameMap.mainCharacter;
			if (enemy.level == 0)
			{
				m_enemyHealth = GameDefs.k_ENEMY_HEALTH_LEVEL_1;
			}
			else
			{
				m_enemyHealth = MathUtils.randomInt(GameDefs.k_ENEMY_HEALTH_MIN, GameDefs.k_ENEMY_HEALTH_MAX);
			}
			
			switch (moveDir)
			{
				case GameSprite.k_DIR_LEFT:
					enemy.direction = GameSprite.k_DIR_RIGHT;
					m_attackKey = Keyboard.LEFT;
					break;
				
				case GameSprite.k_DIR_RIGHT:
					enemy.direction = GameSprite.k_DIR_LEFT;
					m_attackKey = Keyboard.RIGHT;
					break;
				
				case GameSprite.k_DIR_UP:
					enemy.direction = GameSprite.k_DIR_DOWN;
					m_attackKey = Keyboard.UP;
					break;
				
				case GameSprite.k_DIR_DOWN:
					enemy.direction = GameSprite.k_DIR_UP;
					m_attackKey = Keyboard.DOWN;
					break;
			}

		}
		
		override public function start():void
		{
			m_enemy.onAttackHandler = onEnemyAttack;
			m_mainCharacter.onAttackHandler = onPlayerAttack;
			
			m_enemy.appear();
			m_timer = 400;
			m_state = k_STATE_ENEMY_WAIT;

			MagicStone.gameStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		override public function end():void
		{
			MagicStone.gameStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			m_enemy.onAttackHandler = null;
		}
		
		override public function update():void
		{
			switch (m_state)
			{
				case k_STATE_ENEMY_ATTACK:
					if (m_enemy.isIdle() && m_mainCharacter.isIdle())
					{
						m_state = k_STATE_PLAYER_INPUT;
					}
					break;
				
				case k_STATE_PLAYER_INPUT:
					break;
				
				case k_STATE_PLAYER_ATTACK:
					if (m_enemy.isIdle() && m_mainCharacter.isIdle())
					{
						if (m_enemyHealth > 0)
						{
							m_timer = 200;
							m_state = k_STATE_ENEMY_WAIT;
						}
						else
						{
							m_inGame.addScore(GameDefs.k_SCORE_LEVEL_ENEMY[m_enemy.level]);
							m_stateMachine.exitCurrentState();
						}
					}
					break;
				
				case k_STATE_ENEMY_WAIT:
					m_timer -= GameTime.frameMillis;
					if (m_timer <= 0 && m_enemy.isIdle() && m_mainCharacter.isIdle())
					{
						enemyAttack();
					}
					break;
			}
		}
		
		private function enemyAttack():void
		{
			m_enemy.attack();
			m_state = k_STATE_ENEMY_ATTACK;

			m_blockSuccessful = Math.random() < GameDefs.k_SHIELD_LEVEL_BLOCKS[m_inGame.getEquipment(InGameState.k_EQUIPMENT_SHIELD)];
			if (m_blockSuccessful)
			{
				m_inGame.gameMap.mainCharacter.block();
				SoundManager.instance.play(FileDefs.k_URL_SFX_ATTACK_SWORD_BLOCKED);
			}
			else
			{
				SoundManager.instance.play(FileDefs.k_URL_SFX_ATTACK_SWORD);
			}
			
			m_inGame.addSeconds(GameDefs.k_SECONDS_FIGHT_ROUND);
		}
		
		private function playerAttack():void
		{
			m_inGame.gameMap.mainCharacter.attack();
			m_state = k_STATE_PLAYER_ATTACK;
			
			m_blockSuccessful = Math.random() < GameDefs.k_ENEMY_LEVEL_BLOCKS[m_enemy.level];
			if (m_blockSuccessful)
			{
				m_enemy.block();
				SoundManager.instance.play(FileDefs.k_URL_SFX_ATTACK_SWORD_BLOCKED);
			}
			else
			{
				SoundManager.instance.play(FileDefs.k_URL_SFX_ATTACK_SWORD);
			}
		}
		
		private function onEnemyAttack():void
		{
			if (!m_blockSuccessful)
			{
				var damage:int = GameDefs.k_ENEMY_LEVEL_DAMAGES[m_enemy.level];
				damage = Math.max(1, damage - GameDefs.k_ARMOR_LEVEL_PROTECTIONS[m_inGame.getEquipment(InGameState.k_EQUIPMENT_ARMOR)]);
				m_inGame.addHealth(-damage);

				var point:Point = m_mainCharacter.getFxPoint();
				FxManager.instance.addFx(new ScoreFx("-" + damage, 0xFF4400, GameDefs.k_FX_OUTLINE_COLOR, GameDefs.k_FX_TEXT_FORMAT, 1000, 0), point.x, point.y);

				if (damage > 0)
				{
					if (m_inGame.health > 0)
					{
						m_mainCharacter.hurt();
					}
					else
					{
						m_mainCharacter.die();
					}
				}	
			}
		}

		private function onPlayerAttack():void
		{
			if (!m_blockSuccessful)
			{
				var damage:int = GameDefs.k_WEAPON_LEVEL_DAMAGES[m_inGame.getEquipment(InGameState.k_EQUIPMENT_WEAPON)];
				damage = Math.max(1, damage - GameDefs.k_ENEMY_LEVEL_PROTECTIONS[m_enemy.level]);
				m_enemyHealth = Math.max(0, m_enemyHealth - damage);

				var point:Point = m_enemy.getFxPoint();
				FxManager.instance.addFx(new ScoreFx("-" + damage, 0xFF4400, GameDefs.k_FX_OUTLINE_COLOR, GameDefs.k_FX_TEXT_FORMAT, 1000, 0), point.x, point.y);

				if (damage > 0)
				{
					if (m_enemyHealth > 0)
					{
						m_enemy.hurt();
					}
					else
					{
						m_enemy.die();
					}
				}	
			}
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (m_state == k_STATE_PLAYER_INPUT)
			{
				if (e.keyCode == m_attackKey || e.keyCode == Keyboard.SPACE)
				{
					playerAttack();
				}
				else if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT)
				{
					m_state = k_STATE_EXIT;
					m_enemy.hide();
					m_stateMachine.exitCurrentState();
				}
			}
		}
	}
}