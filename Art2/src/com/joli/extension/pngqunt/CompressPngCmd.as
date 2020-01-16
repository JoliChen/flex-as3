package com.joli.extension.pngqunt
{
	import com.jonlin.shell.ShellSession;
	import com.jonlin.shell.events.ShellEvent;
	import com.jonlin.utils.FileUtil;
	
	import flash.desktop.NativeProcessStartupInfo;
	
	/**
	 * 压缩png图片。
	 * @author Adiers
	 */
	public class CompressPngCmd extends ShellSession
	{
		/**完成回调*/
		private var _callback:Function;
		/**参数*/
		private var _info:CompressPngInfo;
		/**是否还未优化*/
		private var _waitOptimize:Boolean;
		
		
		public function CompressPngCmd()
		{
			super();
			_info = new CompressPngInfo();
			_waitOptimize = false;
			addEventListener(ShellEvent.RESULT, onReuslted, false, 0, true);
		}
		
		public function get info():CompressPngInfo
		{
			return _info;
		}
		
		override public function get isRunning():Boolean
		{
			return super.isRunning || _waitOptimize
		}
		
		override protected function newShellEvent(type:String, code:int, msg:String=null):ShellEvent
		{
			var event:ShellEvent = super.newShellEvent(type, code, msg);
			event.exten = {src:_info.srcPath, dst:_info.dstPath}; //返回图片路径
			return event;
		}
		
		/**
		 * 压缩
		 * @param callback:Function			回调函数
		 */
		public function start(callback:Function):void
		{
			_callback = callback;
			if(!_info.pngquant.exists || !_info.pngoptim.exists)
			{
				dispatchEvent(newShellEvent(ShellEvent.EXIT,  CompressPngErrorCode.CL_NOT_EXISTS));
				return;
			}
			
			_waitOptimize = true;
			//创建父目录
			FileUtil.createParent(_info.dstPath);
			
			//执行命令
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			processInfo.arguments = _info.pngquantOptions;
			processInfo.executable = _info.pngquant;
			execute(processInfo);
		}
		
		private function optimize():void
		{
			_waitOptimize = false;
			//执行命令
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			processInfo.arguments = _info.pngoptimOptions;
			processInfo.executable = _info.pngoptim;
			execute(processInfo);
		}
		
		private function onReuslted(event:ShellEvent):void
		{
			if(_waitOptimize)
			{
				optimize();
				return;
			}
			
			var callback:Function =  _callback
			_callback = null;
			if(callback != null)
			{
				callback(event);
			}
			return;
		}
	}
}