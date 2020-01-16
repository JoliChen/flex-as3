package com.jonlin.worker
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.MessageChannelState;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	
	/**
	 * worker实现
	 * @author Joli
	 */
	public class WorkerCase extends Sprite
	{
		/**
		 * 发送频道
		 */
		private var _sendChannel:MessageChannel;
		
		/**
		 * 接收频道
		 */
		private var _recvChannel:MessageChannel;
		
		public function WorkerCase()
		{
			super();
			_sendChannel = Worker.current.getSharedProperty(WorkerHost.RECV) as MessageChannel;
			_recvChannel = Worker.current.getSharedProperty(WorkerHost.SEND) as MessageChannel;
			_recvChannel.addEventListener(Event.CHANNEL_MESSAGE, onRecvMessage);
		}
		
		/**
		 * 通道消息事件
		 * @param event
		 */		
		private function onRecvMessage(event:Event):void
		{
			//trace("WorkerCase onRecvMessage:", _recvChannel.messageAvailable);
			var buffer:ByteArray = _recvChannel.receive() as ByteArray;
			if (buffer && buffer.bytesAvailable > 0) {
				//trace("WorkerCase recv buffer:", buffer.bytesAvailable);
				onWorkerRecv(buffer);
			}
		}
		
		/**
		 * 接收新消息
		 */
		protected function onWorkerRecv(buffer:ByteArray):void
		{
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