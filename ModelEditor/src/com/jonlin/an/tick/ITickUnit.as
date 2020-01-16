package com.jonlin.an.tick
{
	/**
	 * 心跳单元接口
	 * @author jonlin
	 * @date 2019-8-10 上午11:12:11
	 */
	public interface ITickUnit
	{
		function get isDead():Boolean;
		
		function tick():void;
	}
}