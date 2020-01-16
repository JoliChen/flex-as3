package com.jonlin.worker
{
	import flash.utils.ByteArray;
	
	/**
	 * 消息处理接口
	 * @author jonlin
	 * @E-mail: 99755349@qq.com
	 * 创建时间：2019-7-27 下午4:41:57
	 */
	public interface IWorkerHandler
	{
		/**
		 * 接收新消息
		 * @param buffer 消息数据
		 */
		function onWorkerRecv(buffer:ByteArray):void;
	}
}