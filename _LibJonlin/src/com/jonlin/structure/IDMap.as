package com.jonlin.structure
{
	import flash.utils.Dictionary;
	
	/**
	 * ID映射表
	 * @author Joli
	 * @date 2018-7-19 下午4:34:38
	 */
	public class IDMap
	{
		/**
		 * 元素ID分配 
		 */		
		private var _base:uint;
		
		/**
		 * 元素计数字典 
		 */		
		private var _dict:Dictionary;
		
		
		public function IDMap() 
		{
			clear();
		}
		
		/**
		 * 重置
		 */		
		public function clear():void
		{
			_base = 0;
			_dict = new Dictionary();
		}
		
		/**
		 * 元素是否已开始计数
		 * @param element
		 */
		public function contains(element:*):Boolean
		{
			return element in _dict;
		}
		
		/**
		 * 添加到计数器
		 * @param element
		 */
		public function put(element:*):uint
		{
			var uuid:uint = 0;
			if (contains(element)) {
				uuid = _dict[element];
			} else {
				uuid = ++_base;
				_dict[element] = uuid
			}
			return uuid;
		}
		
		/**
		 * 获取UUID
		 * @param element
		 */
		public function getID(element:*):uint
		{
			return put(element);
		}
	}
}