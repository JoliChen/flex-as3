package com.jonlin.shell
{
	/**
	 * shell启动信息接口
	 * @author Joli
	 * @date 2018-7-16 下午1:24:40
	 */
	public interface IShellCommand
	{
		/**
		 * 获取命令行执行程序
		 * @return 
		 */
		function get executable():String;
		
		/**
		 * 获取命令行参数
		 * @return 
		 */		
		function get arguments():Vector.<String>;
	}
}