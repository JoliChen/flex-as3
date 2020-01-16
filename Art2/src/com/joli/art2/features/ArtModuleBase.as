package com.joli.art2.features
{
	import com.jonlin.core.IDispose;

	/**
	 * 工具模块基础定义定义
	 * @author Joli
	 * @date 2018-7-16 下午5:48:45
	 */
	public class ArtModuleBase implements IDispose
	{
		private var _id:uint;
		private var _name:String;
		
		public function ArtModuleBase(id:uint, name:String)
		{
			_id = id;
			_name = name;
		}
		
		public function dispose():void
		{
			_id = 0;
			_name = null;
		}
		
		/**
		 * 模块ID
		 * @return 
		 */		
		public function get id():uint
		{
			return _id;
		}
		
		/**
		 * 模块名称
		 * @return 
		 */		
		public function get name():String
		{
			return _name;
		}
		
		/**
		 * 模块GUI
		 * @return 
		 */		
		public function get gui():IModuleGUI 
		{
			return null;
		}
	}
}