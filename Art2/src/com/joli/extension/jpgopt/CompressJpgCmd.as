package com.joli.extension.jpgopt
{
	import com.jonlin.shell.ShellSession;
	import com.jonlin.shell.events.ShellEvent;
	import com.jonlin.utils.FileUtil;
	
	import flash.desktop.NativeProcessStartupInfo;
	
	/**
	 * 压缩jpg图片。
	 * @author Adiers
	 */
	public class CompressJpgCmd extends ShellSession
	{
		/**完成回调*/
		private var _callback:Function;
		/**参数*/
		private var _info:CompressJpgInfo;
		
		public function CompressJpgCmd()
		{
			super();
			_info = new CompressJpgInfo();
			addEventListener(ShellEvent.RESULT, onReuslted, false, 0, true);
		}
		
		public function get info():CompressJpgInfo
		{
			return _info;
		}
		
		override protected function newShellEvent(type:String, code:int, msg:String=null):ShellEvent
		{
			var event:ShellEvent = super.newShellEvent(type, code, msg);
			event.exten = {src:_info.srcPath, dst:_info.dstPath}; //返回图片路径
			return event;
		}
		
		/**
		 * 压缩
		 * @param callback:Function 回调函数
		 */
		public function start(callback:Function):void
		{
			if(!_info.jpgoptim.exists)
			{
				dispatchEvent(newShellEvent(ShellEvent.EXIT,  CompressJpgErrorCode.CL_NOT_EXISTS));
				return;
			}
			
			_callback = callback;
			//创建父目录
			FileUtil.createParent(_info.dstPath);
			
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			processInfo.arguments = _info.jpgoptimOptions
			processInfo.executable = _info.jpgoptim;
			execute(processInfo);
		}
		
		private function onReuslted(event:ShellEvent):void
		{
			var callback:Function =  _callback
			_callback = null;
			if(callback != null)
			{
				callback(event);
			}
		}
	}
}
