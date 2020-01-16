package com.jonlin.utils
{
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * 时间工具
	 * @author Joli
	 * @date 2018-7-16 下午4:59:34
	 */
	public final class TimeUtil
	{
		/**
		 * 延迟执行 
		 * @param time
		 * @param closure
		 * @param args
		 */		
		static public function delay(time:Number, closure:Function, ...args):void
		{
			var id:uint = 0;
			id = setTimeout(function():void {
				if(id != 0) {
					clearTimeout(id);
				}
				if(closure != null) {
					closure.apply(null, args);
				}
			}, time);
		}
	}
}