package com.jonlin.io
{
	import flash.utils.ByteArray;
	
	/**
	 * 二进制输入接口
	 * @author Joli
	 * @date 2018-7-18 下午9:13:02
	 */
	public interface IReadable
	{
		/**
		 * 从二进制流中读取对象数据 
		 * @param bytes
		 */		
		function read(bytes:ByteArray):void;
	}
}