package com.joli.art2.console
{
	
	/**
	 * 输出日志接口
	 * @author Joli
	 * @date 2018-8-7 下午5:35:34
	 */
	public interface ILogcat
	{
		/**
		 * 输出调试信息
		 * @param msg
		 * @param rest
		 */
		function debug(msg:String, ... rest):void;
		
		/**
		 * 输出警告信息
		 * @param msg
		 * @param rest
		 */
		function warn(msg:String, ... rest):void;
		
		/**
		 * 输出错误信息
		 * @param msg
		 * @param rest
		 */
		function error(msg:String, ... rest):void;
	}
}