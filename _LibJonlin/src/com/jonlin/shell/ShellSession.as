package com.jonlin.shell
{
	import com.jonlin.event.EventProxy;
	import com.jonlin.shell.events.ShellEvent;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	/**
	 * shell会话
	 * @author Joli
	 */
	public class ShellSession extends EventProxy
	{
		/**
		 * 开启调试模式
		 */
		private static const DEBUG_NATIVE:Boolean = false;
		
		/**
		 * 本地进程
		 */
		private var _nativeProcess:NativeProcess;
		
		/**
		 * 附带参数
		 */
		private var _attachment:*;
		
		public function ShellSession()
		{
			super();
			_nativeProcess = new NativeProcess();
			_nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, onExitHandler);
			_nativeProcess.addEventListener(Event.STANDARD_OUTPUT_CLOSE, onStandardOutputClose);
			_nativeProcess.addEventListener(Event.STANDARD_INPUT_CLOSE, onStandardInputClose);
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStandardOutputData);
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStandardErrorData);
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onStandardInputProgress);
			_nativeProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onStandardOutputIOError);
			_nativeProcess.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onStandardInputIOError);
		}
		
		public override function dispose():void
		{
			if (_nativeProcess) {
				_nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, onExitHandler);
				_nativeProcess.removeEventListener(Event.STANDARD_OUTPUT_CLOSE, onStandardOutputClose);
				_nativeProcess.removeEventListener(Event.STANDARD_INPUT_CLOSE, onStandardInputClose);
				_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStandardErrorData);
				_nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStandardOutputData);
				_nativeProcess.removeEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onStandardInputProgress);
				_nativeProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onStandardOutputIOError);
				_nativeProcess.removeEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onStandardInputIOError);
				_nativeProcess = null;
			}
			_attachment = undefined;
			super.dispose();
		}
		
		private function onExitHandler(event:NativeProcessExitEvent):void
		{
			if (DEBUG_NATIVE) {
				trace("shell exit:", event.exitCode);
			}
			if (hasEventListener(ShellEvent.EXIT)) {
				dispatchEvent(new ShellEvent(ShellEvent.EXIT, event.exitCode, _attachment));
			}
		}
		
		private function onStandardOutputClose(event:Event):void
		{
			if (DEBUG_NATIVE) {
				trace("onStandardOutputClose");
			}
		}
		private function onStandardInputClose(event:Event):void
		{
			if (DEBUG_NATIVE) {
				trace("onStandardInputClose", _nativeProcess.running);
			}
		}
		
		private function onStandardErrorData(event:ProgressEvent):void
		{
			if (DEBUG_NATIVE) {
				const input:IDataInput = _nativeProcess.standardError;
				trace("standardErrorData:", input.readUTFBytes(input.bytesAvailable));
			}
		}
		private function onStandardOutputData(event:ProgressEvent):void
		{
			if (DEBUG_NATIVE) {
				const input:IDataInput = _nativeProcess.standardOutput;
				trace("standardOutputData:", input.readUTFBytes(input.bytesAvailable));
			}
		}
		private function onStandardInputProgress(event:ProgressEvent):void
		{
			if (DEBUG_NATIVE) {
				trace("onStandardInputProgress:", event.bytesLoaded, event.bytesTotal);
			}
		}
		
		private function onStandardOutputIOError(event:IOErrorEvent):void
		{
			if (DEBUG_NATIVE) {
				trace("onStandardOutputIOError:", event.text);
			}
		}
		private function onStandardInputIOError(event:IOErrorEvent):void
		{
			if (DEBUG_NATIVE) {
				trace("onStandardInputIOError:", event.text);
			}
		}
		
		/**
		 * 是否正在运行
		 */
		public function get isRunning():Boolean
		{
			return _nativeProcess.running;
		}
		
		/**
		 * 执行shell命令
		 * @param command
		 * @param attachment
		 * @param closeInput
		 * @return 是否启动
		 */
		public function execute(command:IShellCommand, attachment:*=undefined, closeInput:Boolean=true):void
		{
			_attachment = attachment;
			if (!NativeProcess.isSupported) {
				throw new Error("NativeProcess not supported");
			}
			const exec:File = new File(command.executable);
			if (!exec.exists) {
				throw new Error("executable not exists");
			}
			
			const processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			processInfo.executable = exec;
			processInfo.arguments = command.arguments;
			_nativeProcess.start(processInfo);

			if (closeInput && _nativeProcess.running) {
				_nativeProcess.closeInput();
			}
		}
	}
}