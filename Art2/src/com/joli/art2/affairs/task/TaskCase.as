package com.joli.art2.affairs.task
{
	import com.joli.art2.affairs.task.channel.ITaskResponse;
	import com.joli.art2.console.ILogcat;
	import com.joli.art2.console.LogColor;
	import com.jonlin.worker.WorkerCase;
	import com.jonlin.utils.ReflectUtil;
	
	import flash.utils.ByteArray;
	
	/**
	 * 异步任务
	 * @author Joli
	 * @date 2018-7-19 上午10:59:56
	 */
	public class TaskCase extends WorkerCase implements ILogcat
	{
		private var _tag:String;
		
		public function TaskCase()
		{
			_tag = ReflectUtil.getClassName(this);
			super();
			
		}
		
		override final protected function onWorkerRecv(buffer:ByteArray):void
		{
			const protocol:int = buffer.readByte();
			switch(protocol) {
				case TaskProtocol.RESUME:
					onResume(buffer);
					break;
				default:
					trace(ReflectUtil.getClassName(this), "未支持的协议:", protocol);
					break;
			}
		}
		
		/**
		 * 任务开始
		 * @param bytes
		 */		
		protected function onResume(bytes:ByteArray):void
		{
		}
		
		/**
		 * 退出
		 */
		public function exit(code:int):void
		{
		}
		
		/**
		 * 发送退出消息
		 * @param response
		 */		
		protected final function postExitMsg(response:ITaskResponse):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeByte(TaskProtocol.EXIT);
			response.write(bytes);
			send(bytes);
		}
		
		/**
		 * 输出日志
		 * @param level
		 * @param msg
		 * @param rest
		 */		
		internal function printLog(level:int, msg:String, rest:Array=null):void
		{
			if (rest) {
				for (var i:int = 0; i < rest.length; i++)
				{
					msg = msg.replace(new RegExp("\\{"+ i +"\\}", "g"), rest[i]);
				}
			}
			var bytes:ByteArray = new ByteArray();
			bytes.writeByte(TaskProtocol.STANDARD_OUTPUT);
			bytes.writeByte(level);
			bytes.writeUTF(_tag);
			bytes.writeUTF(msg);
			send(bytes);
		}

		public function debug(msg:String, ... rest):void
		{
			printLog(LogColor.DEBUG, msg, rest);
		}

		public function warn(msg:String, ... rest):void
		{
			printLog(LogColor.WARN, msg, rest);
		}

		public function error(msg:String, ... rest):void
		{
			printLog(LogColor.ERROR, msg, rest);
		}
	}
}