package com.joli.art2.affairs.task
{
	import com.joli.art2.console.ILogcat;
	import com.joli.art2.console.LogColor;
	import com.jonlin.core.IDispose;
	
	/**
	 * 异步任务阶段
	 * @author Joli
	 * @date 2018-7-19 上午11:06:52
	 */
	public class TaskExecutor implements IDispose, ILogcat
	{
		/**
		 * 所属异步任务 
		 */		
		private var _asyncTask:TaskCase;
		
		/**
		 * 构造
		 * @param asyncTask
		 */		
		public function TaskExecutor(asyncTask:TaskCase)
		{
			_asyncTask = asyncTask;
		}
		
		public function dispose():void
		{
			_asyncTask = null;
		}
		
		protected function exitTask(code:int):void
		{
			_asyncTask.exit(code);
		}
		
 		public function debug(msg:String, ... rest):void
		{
			_asyncTask.printLog(LogColor.DEBUG, msg, rest);
		}
		
 		public function warn(msg:String, ... rest):void
		{
			_asyncTask.printLog(LogColor.WARN, msg, rest);
		}

		public function error(msg:String, ... rest):void
		{
			_asyncTask.printLog(LogColor.ERROR, msg, rest);
		}
	}
}