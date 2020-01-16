package com.joli.art2.affairs.task.standard
{
	import com.joli.art2.Art;
	import com.joli.art2.console.LogColor;
	
	import flash.utils.ByteArray;

	/**
	 * 任务输出
	 * @author Joli
	 * @date 2018-7-17 下午9:18:05
	 */
	public final class TaskStandardOutput
	{
		/**
		 * 接收日志
		 * @param bytes
		 */		
		public static function print(bytes:ByteArray):void
		{
			const level:int = bytes.readByte();
			const clazz:String = bytes.readUTF();
			const track:String = bytes.readUTF();
			switch(level)
			{
				case LogColor.DEBUG:
					Art.logger(clazz).debug(track);
					break;
				case LogColor.WARN:
					Art.logger(clazz).warn(track);
					break;
				case LogColor.ERROR:
					Art.logger(clazz).error(track);
					break;
			}
		}
	}
}