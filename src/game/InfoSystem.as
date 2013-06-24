package game
{
	import flash.events.MouseEvent;
	
	import game.server.GameServer;
	import game.server.answers.Answer;
	import game.ui.PopupWindow;
	
	import inutilib.social.SocialUserManager;
	
	import mx.resources.ResourceManager;

	public class InfoSystem
	{
		public static const k_NO_INFO:int = -1;
		
		private var m_onFinishCallback:Function;
		
		public function InfoSystem()
		{
		}
		
		public function getNextInfo():int
		{
			var lastInfo:int = MagicStone.s_userInfo.lastInfo;
			
			if (lastInfo == 0 && !SocialUserManager.instance.isGuest())
			{
				return 1;
			}
			else if (lastInfo <= 1 && Config.useFacebook)
			{
				return 2;
			}

			return k_NO_INFO;
		}
		
		public function showInfo(info:int, onFinishCallback:Function):void
		{
			m_onFinishCallback = onFinishCallback;
			
			GameServer.instance.sendLastInfo(SocialUserManager.instance.playerUserId, info, onSent);
			MagicStone.s_userInfo.lastInfo = info;
			
			var popup:PopupWindow = new PopupWindow(PopupWindow.k_TYPE_OK, ResourceManager.getInstance().getString("default", "textInfo" + info));
			popup.ui.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			popup.open();
		}
		
		private function onClick(e:MouseEvent):void
		{
			var buttonName:String = e.target.name as String;
			if (buttonName == PopupWindow.k_BUTTON_OK)
			{
				m_onFinishCallback();
			}
		}
		
		private function onSent(a:Answer):void
		{
			// ignore
		}

	}
}