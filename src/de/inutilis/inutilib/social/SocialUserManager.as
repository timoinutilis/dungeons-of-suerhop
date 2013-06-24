package de.inutilis.inutilib.social
{

	public class SocialUserManager
	{
		private static var s_instance:SocialUserManager;
		
		private var m_users:Object;
		private var m_playerUserId:int;
		private var m_friendUserIds:Array;
		
		public static function get instance():SocialUserManager
		{
			if (s_instance == null)
			{
				s_instance = new SocialUserManager();
			}
			return s_instance;
		}

		public function SocialUserManager()
		{
			m_users = new Object();
			m_friendUserIds = new Array();
		}
		
		public function setPlayerUser(userId:int, user:SocialUser):void
		{
			m_playerUserId = userId;
			m_users[userId] = user;
		}

		public function addFriendUser(userId:int, user:SocialUser):void
		{
			m_friendUserIds.push(userId);
			m_users[userId] = user;
		}
		
		public function addUser(userId:int, user:SocialUser):void
		{
			m_users[userId] = user;
		}

		public function get playerUserId():int
		{
			return m_playerUserId;
		}
		
		public function get friendUserIds():Array
		{
			return m_friendUserIds;
		}
		
		public function getPlayerUser():SocialUser
		{
			return m_users[m_playerUserId] as SocialUser;
		}
		
		public function getUser(userId:int):SocialUser
		{
			return m_users[userId] as SocialUser;
		}
		
		public function isGuest():Boolean
		{
			return (m_playerUserId == 0);
		}
		
	}
}