package com.joli.modules.artist.image.slim.affairs
{
	import com.joli.art2.affairs.task.channel.ITaskResponse;
	
	import flash.utils.ByteArray;
	
	
	/**
	 * 图片压缩任务响应
	 * @author Joli
	 * @date 2018-8-30 下午3:16:51
	 */
	public class SlimImageRet implements ITaskResponse
	{
		private var _exitCode:int;
		
		public function SlimImageRet(exitCode:int=0)
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