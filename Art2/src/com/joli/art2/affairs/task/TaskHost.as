package com.joli.art2.affairs.task
{
	import com.joli.art2.ArtFactory;
	import com.joli.art2.affairs.task.channel.ITaskRequest;
	import com.joli.art2.affairs.task.standard.TaskStandardOutput;
	import com.jonlin.core.IDispose;
	import com.jonlin.utils.FileUtil;
	import com.jonlin.utils.IOUtil;
	import com.jonlin.worker.IWorkerHandler;
	import com.jonlin.worker.WorkerHost;
	
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	/**
	 * 异步任务会话
	 * @author Joli
	 * @date 2018-7-18 下午2:36:51
	 */
	public class TaskHost implements IDispose, IWorkerHandler
	{
		private var _exitCallback:Function;
		private var _workerHost:WorkerHost;
		
		private static function loadWorker(workerName:String):ByteArray
		{
			const path:String = FileUtil.join(ArtFactory.MOUNT_ROOT, "workers", workerName + ".swf");
			return IOUtil.readFile(FileUtil.newFile(path, File.applicationDirectory));
		}
		
		/**
		 * 构造函数
		 * @param workerName worker名称
		 */		
		public function TaskHost(workerName:String)
		{
			_workerHost = new WorkerHost(loadWorker(workerName), this);
		}
		
		public function dispose():void
		{
			_exitCallback = null;
			if (null != _workerHost) {
				_workerHost.dispose();
				_workerHost = null;
			}
		}
		
		public function onWorkerRecv(buffer:ByteArray):void
		{
			const protocol:int = buffer.readByte();
			switch(protocol)
			{
				case TaskProtocol.STANDARD_OUTPUT:
					TaskStandardOutput.print(buffer);
					break;
				case TaskProtocol.EXIT:
					_exitCallback(buffer);
					break;
			}
		}
		
		/**
		 * 开始任务
		 * @param request 任务参数
		 * @param exitCallback 退出回调。如：exitCallback(bytes:ByteArray):void;
		 */		
		public function start(request:ITaskRequest, exitCallback:Function):void
		{
			_exitCallback = exitCallback;
			var bytes:ByteArray = new ByteArray();
			bytes.writeByte(TaskProtocol.RESUME);
			request.write(bytes);
			_workerHost.send(bytes);
		}
	}
}