package com.jonlin.io.events
{
	import flash.events.Event;
	
	
	/**
	 * 异步IO事件
	 * @author Joli
	 * @date 2018-7-16 下午4:29:41
	 */
	public class IOEvent extends Event
	{
		public static const IOERROR:String = "IOError";
		public static const COMPLETE:String = "Complete";
		public static const PROGRESS:String = "Progress";
		
		private var _fileUrl:String;
		private var _extend:*;
		
		public function IOEvent(type:String, fileUrl:String, extend:*=null) {
			super(type, false, false);
			_fileUrl = fileUrl;
			_extend = extend;
		}
		
		public function get fileUrl():String
		{
			return _fileUrl;
		}
		
		public function get extend():*
		{
			return _extend;
		}
	}
}