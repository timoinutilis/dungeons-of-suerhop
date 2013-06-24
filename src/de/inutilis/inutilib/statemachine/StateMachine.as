package de.inutilis.inutilib.statemachine
{
	public class StateMachine
	{
		private var m_stateQueue:Array;
		private var m_currentState:State;
		private var m_switchState:Boolean;
		
		public function StateMachine()
		{
			m_stateQueue = new Array();
		}
		
		public function quit():void
		{
			m_stateQueue.length = 0;
			m_switchState = true;
			update();
		}
		
		public function addState(state:State):void
		{
			m_stateQueue.push(state);
		}
		
		public function setState(state:State):void
		{
			m_stateQueue.push(state);
			m_switchState = true;
		}
		
		public function exitCurrentState():void
		{
			m_switchState = true;
		}
		
		public function get currentState():State
		{
			return m_currentState;
		}
		
		public function update():void
		{
			if (m_switchState)
			{
				if (m_currentState != null)
				{
					m_currentState.end();
					trace("==== State End: " + m_currentState + " ====");
					m_currentState = null;
				}
				
				if (m_stateQueue.length > 0)
				{
					m_currentState = m_stateQueue.shift() as State;
					trace("==== State Start: " + m_currentState + " ====");
					m_currentState.start();
				}
				
				m_switchState = false;
			}
			
			if (m_currentState != null)
			{
				m_currentState.update();
			}
		}
	}
}