package com.jonlin.io
{
	import flash.utils.ByteArray;
	
	/**
	 * 二进制输出接口
	 * @author Joli
	 * @date 2018-7-18 下午9:13:20
	 */
	public interface IWriteable
	{
		/**
		 * 将对象写入二进制流
		 * @return 
		 */		
		function write(bytes:ByteArray):void;
	}
}