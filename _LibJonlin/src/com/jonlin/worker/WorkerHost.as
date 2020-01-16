package com.jonlin.worker
{
	import com.jonlin.core.IDispose;
	
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;

	/**
	 * worker句柄
	 * @author Joli
	 */
	public class WorkerHost implements IDispose
	{	
		internal static const SEND:String = "send";
		internal static const RECV:String = "recv";
		
		/**
		 * 消息处理对象
		 */
		private var _handler:IWorkerHandler;
		
		/**
		 * worker对象 
		 */		
		private var _worker:Worker;
		
		/**
		 * 发送频道 
		 */		
		private var _sendChannel:MessageChannel;
		
		/**
		 * 接收频道 
		 */		
		private var _recvChannel:MessageChannel;
		
		
		public function WorkerHost(swf:ByteArray, handler:IWorkerHandler)
		{
			_handler = handler;
			_worker = WorkerDomain.current.createWorker(swf, true);
			_worker.addEventListener(Event.WORKER_STATE, onChangeState);
			
			_sendChannel = Worker.current.createMessageChannel(_worker);
			_recvChannel = _worker.createMessageChannel(Worker.current);
			_recvChannel.addEventListener(Event.CHANNEL_MESSAGE, onRecvMessage);
			
			_worker.setSharedProperty(SEND, _sendChannel);
			_worker.setSharedProperty(RECV, _recvChannel);
			_worker.start();
		}
		
		public function dispose():void
		{
			if (_sendChannel) {
				_sendChannel.close();
				_sendChannel = null;
			}
			if (_recvChannel) {
				_recvChannel.removeEventListener(Event.CHANNEL_MESSAGE, onRecvMessage);
				_recvChannel.close();
				_recvChannel = null;
			}
			if (_worker) {
				_worker.removeEventListener(Event.WORKER_STATE, onChangeState);
				_worker.terminate();
				_worker = null;
			}
		}
		
		/**
		 * 是否正在运行
		 */
		public function get isRunning():Boolean
		{
			return _worker.state == WorkerState.RUNNING;
		}
		
		/**
		 * worker状态变更
		 */
		private function onChangeState(event:Event):void
		{
			trace("onChangeState:", _worker.state);
		}
		
		/**
		 * 通道消息事件
		 * @param event
		 */		
		private function onRecvMessage(event:Event):void
		{
			//trace("WorkerHost onRecvMessage:", _recvChannel.messageAvailable);
			var buffer:ByteArray = _recvChannel.receive() as ByteArray;
			if (buffer && buffer.bytesAvailable > 0) {
				//trace("WorkerHost recv buffer:", buffer.bytesAvailable);
				_handler.onWorkerRecv(buffer);
			}
		}
		
		/**
		 * 发送消息
		 * @param buffer
		 */		
		public function send(buffer:ByteArray):void
		{
			_sendChannel.send(buffer);
		}
	}
}