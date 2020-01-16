package com.joli.modules.flash.animate.affairs
{
	import com.joli.art2.affairs.task.channel.ITaskResponse;
	
	import flash.utils.ByteArray;
	
	
	/**
	 * 导出SWF动画响应
	 * @author Joli
	 * @date 2018-7-19 上午10:55:29
	 */
	public class AnimateRet implements ITaskResponse
	{
		private var _exitCode:int;
		
		public function AnimateRet(exitCode:int=0)
		{
			_exitCode = exitCode;
		}
		
		public function write(bytes:ByteArray):void
		{
			bytes.writeByte(_exitCode);
		}
		
		public function read(bytes:ByteArray):void
		{
			_exitCode = bytes.readByte();
		}

		public function get exitCode():int
		{
			return _exitCode;
		}
	}
}