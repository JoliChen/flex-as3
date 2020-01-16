package com.joli.art2.affairs
{
	/**
	 * 模块功能接口
	 * @author Joli
	 * @date 2018-7-18 下午2:29:49
	 */
	public interface IAffairsTask
	{
		/**
		 * 执行功能
		 */		
		function resume():void;
		
		/**
		 * 获取DAO
		 */
		function get dao():IAffairsDAO;
	}
}