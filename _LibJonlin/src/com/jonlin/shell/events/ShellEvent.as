package com.jonlin.shell.events
{
	import com.jonlin.event.IAttachEvent;
	
	import flash.events.Event;
	
	/**
	 * 命令行退出事件
	 * @author Joli
	 * @date 2018-7-17 下午4:57:25
	 */
	public class ShellEvent extends Event implements IAttachEvent
	{
		public static const EXIT:String = "EXIT";
		
		private var _code:int;
		private var _data:*;
		
		public function ShellEvent(type:String, code:int, data:*=undefined)
		{
			super(type, false, false);
			_code = code;
			_data = data;
		}
		
		/**
		 * 状态码 
		 * @return 
		 */		
		public function get code():int
		{
			return _code;
		}

		public function get data():*
		{
			return _data;
		}

	}
}