package inutilib.social
{
	public class SocialUser
	{
		private var m_name:String;
		private var m_pictureUrl:String;
		
		public function SocialUser(name:String, pictureUrl:String)
		{
			m_name = name;
			m_pictureUrl = pictureUrl;
		}
		
		public function get name():String
		{
			return m_name;
		}
		
		public function get pictureUrl():String
		{
			return m_pictureUrl;
		}
	}
}