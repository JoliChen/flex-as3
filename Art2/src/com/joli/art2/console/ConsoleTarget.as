package com.joli.art2.console
{
	import com.joli.art2.gui.ConsoleUI;
	
	import mx.core.mx_internal;
	import mx.logging.targets.TraceTarget;
	
	use namespace mx_internal;
	
	/**
	 * 控制台输出log
	 * @author Joli
	 * @date 2018-7-16 下午9:17:22
	 */
	public class ConsoleTarget extends TraceTarget
	{
		private var _console:ConsoleUI;
		
		public function ConsoleTarget(console:ConsoleUI)
		{
			super();
			_console = console;
		}
		
		override mx_internal function internalLog(message:String):void
		{
			super.mx_internal::internalLog(message);
			_console.append(message);
		}
	}
}