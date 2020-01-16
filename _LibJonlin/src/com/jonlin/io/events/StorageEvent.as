package com.jonlin.io.events
{
	import flash.events.Event;

	/**
	 * 数据存储事件
	 * @author jonlin
	 * @date 2019-8-13 下午2:19:34
	 */
	public class StorageEvent extends Event
	{
		public static const STORAGE_CHANGE:String = "STORAGE_CHANGE";
		public static const STORAGE_DELETE:String = "STORAGE_DELETE";
		
		private var _filedKey:*;
		private var _oldValue:*;
		private var _newValue:*;
		
		public function StorageEvent(type:String, filedKey:*, oldValue:*, newValue:*=undefined)
		{
			super(type, false, false);
			_filedKey = filedKey;
			_oldValue = oldValue;
			_newValue = newValue;
		}
		
		public function get filedKey():*
		{
			return _filedKey;
		}

		public function get oldValue():*
		{
			return _oldValue;
		}
		
		public function get newValue():*
		{
			return _newValue;
		}
	}
}