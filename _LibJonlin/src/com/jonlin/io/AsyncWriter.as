package com.jonlin.io
{
	import com.jonlin.event.EventProxy;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import com.jonlin.io.events.IOEvent;
	
	/**
	 * 异步文件输出
	 * @author Joli
	 */
	final public class AsyncWriter extends EventProxy
	{
		/**
		 * 输出异常
		 * @eventType com.jonlin.io.events.IOEvent
		 */
		[Event(name="IOERROR", type="com.jonlin.io.events.IOEvent")]
		
		/**
		 * 输出完成
		 * @eventType com.jonlin.io.events.IOEvent
		 */
		[Event(name="COMPLETE", type="com.jonlin.io.events.IOEvent")]
		
		/**
		 * 输出进度
		 * @eventType com.jonlin.io.events.IOEvent
		 */
		[Event(name="PROGRESS", type="com.jonlin.io.events.IOEvent")]
		
		/**
		 * 是否正在运行中（非闲置状态） 
		 */
		private var _isRunning:Boolean;
		
		/**
		 * 文件路径 
		 */		
		private var _fileUrl:String;
		
		/**
		 *本地文件流 
		 */		
		private var _stream:FileStream;
		
		public function AsyncWriter() {
			super();
			_isRunning = false;
			_fileUrl = null;
			_stream = new FileStream();
			_stream.addEventListener(Event.CLOSE, onClose, false, 0, true);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			_stream.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onProgress, false, 0, true);
		}
		
		override public function dispose():void
		{
			_isRunning = false;
			_fileUrl = null;
			if (_stream) {
				_stream.removeEventListener(Event.CLOSE, onClose);
				_stream.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				_stream.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onProgress);
				close();
				_stream = null;
			}
		}
		
		/**
		 * 关闭文件流
		 */
		private function close():void
		{
			try {
				_stream.close();
			} catch(error:Error) {
				trace("文件流关闭异常:" + error.getStackTrace());
			}
		}
		
		/**
		 * 是否正在运行中（非闲置状态）
		 */
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
		/**
		 * 是否已失效
		 */
		public function get isInvalidated():Boolean
		{
			return null == _fileUrl;
		}
		
		/**
		 * 当前输出文件的地址
		 */		
		public function get url():String
		{
			return _fileUrl;
		}
		
		/**
		 * 开始写入文件
		 * @param file:File 文件对象
		 * @param fileBytes:ByteArray 文件数据
		 */
		public function write(file:File, fileBytes:ByteArray):void
		{
			if(_isRunning) {
				throw new Error("异步文件输出器繁忙！");
				return;
			}
			_isRunning = true;
			_fileUrl = file.url;
			try {
				_stream.openAsync(file, FileMode.WRITE);//打开文件流
				_stream.writeBytes(fileBytes);//写入缓冲区
			} catch(error:Error) {
				trace("文件写入异常:" + error.getStackTrace());
			} finally {
				close();//关闭文件流
			}
		}
		
		private function onClose(event:Event = null):void
		{
			_isRunning = false;
			if (isInvalidated) {
				return;//已失效，就不需要玩下执行了。
			}
			if (hasEventListener(IOEvent.COMPLETE)) {
				var e:IOEvent = new IOEvent(IOEvent.COMPLETE, _fileUrl);
				_fileUrl = null;
				dispatchEvent(e);
			} else {
				_fileUrl = null;
			}
		}
		
		private function onError(event:IOErrorEvent):void
		{
			trace("写入文件异常:" + event.text);
			_isRunning = false;
			if (isInvalidated) {
				close();//关闭输出流
				return;//已失效，就不需要玩下执行了。
			}
			if (hasEventListener(IOEvent.IOERROR)) {
				var e:IOEvent = new IOEvent(IOEvent.IOERROR, _fileUrl);
				_fileUrl = null;
				dispatchEvent(e);
			} else {
				_fileUrl = null;
			}
		}
		
 		private function onProgress(event:OutputProgressEvent):void
		{
			if (isInvalidated) {
				return;//已失效，就不需要玩下执行了。
			}
			if (hasEventListener(IOEvent.PROGRESS)) {
				dispatchEvent(new IOEvent(IOEvent.PROGRESS, _fileUrl, [event.bytesPending, event.bytesTotal]));
			}
		}
	}
}