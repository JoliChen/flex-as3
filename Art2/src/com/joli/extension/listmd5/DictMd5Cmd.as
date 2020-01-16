package com.joli.extension.listmd5
{
	import com.jonlin.shell.ShellSession;
	import com.jonlin.shell.events.ShellEvent;
	import com.jonlin.structure.TreeMap;
	import com.jonlin.utils.FileUtil;
	
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	
	/**
	 * 目录MD5命令
	 * @Amumu
	 */
	public class DictMd5Cmd extends ShellSession
	{
		private static const exe_path:String = "res/cmd/md5sums_v1.2.exe";
		private static const head_end:int = 114;
		private static const split_exp:RegExp = /\s{2,}/;
		
		/**命令行参数*/
		private var _options:Vector.<String>;
		
		/**MD5列表*/
		private var _md5dict:TreeMap;
		/**目录列表*/
		private var _folders:Array;
		/**总目录数*/
		private var _totals:int;
		/**当前索引*/
		private var _index:int;
		/**回调*/
		private var _callback:Function;
		
		/**根目录*/
		private var _rootPath:String;
		/**当前遍历的目录*/
		private var _currPath:String;
		/**输出信息*/
		private var _logMsg:String;
		
		public function DictMd5Cmd()
		{
			super();
			
			_options = new Vector.<String>();
			_options[0] = "-e";	//output simple
			_options[1] = "-b";	//output simple
			_options[2] = "-n";	//output simple
			_options[3] = "";		//source folder path
			
			addEventListener(ShellEvent.RESULT, onReuslted, false, 0, true);
			addEventListener(ShellEvent.PROGRESS, onProgress, false, 0, true);
		}
		
		override public function get isRunning():Boolean
		{
			return super.isRunning || _index < _totals;
		}
		
		/**
		 * 压缩
		 * @param root:String				命令参数
		 * @param callback:Function 	回调函数
		 */
		public function start(root:String, callback:Function):void
		{
			_rootPath = root;
			_callback = callback;
			_md5dict = new TreeMap();
			
			_folders = FileUtil.listDirs(root);
			_totals = _folders.length;
			_index = 0;
			
			printDictMd5();
		}
		
		private function printDictMd5():void
		{
			if(_index >= _totals)
			{
				var callback:Function = _callback, dict:TreeMap = _md5dict;
				
				_callback = null;
				_md5dict = null;
				_rootPath = _currPath = null;
				_index = _totals = 0;
				
				if(callback != null)
				{
					callback(dict);
				}
				return;
			}
			
			_currPath = _folders[_index++];
			_options[3] = _currPath;
			_logMsg = "";
			
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			processInfo.arguments = _options.slice();
			processInfo.executable = FileUtil.newFile(exe_path, File.applicationDirectory);
			execute(processInfo);
		}
		
		private function onProgress(event:ShellEvent):void
		{
			_logMsg += event.message;
		}
		
		private function onReuslted(event:ShellEvent):void
		{
			var msg:String = _logMsg;
			_logMsg = null;
			msg = msg.substr(head_end);// del head content
			//trace(msg);
			var md5Items:Array = msg.split("\r\n");
			md5Items.pop();// del last line
			
			if(md5Items.length)
			{
				var itemStr:String, itemSpt:Array, folder:String, filename:String, filemd5:String;
				folder = _currPath.replace(_rootPath, "") + File.separator;
				folder =folder .replace(/\\/g, "/").substr(1);
				
				for(var i:int=0, len:int = md5Items.length; i < len; ++i)
				{
					itemStr = md5Items[i];
					itemSpt = itemStr.split(split_exp);
					
					filename = folder + itemSpt[0];
					filemd5 = itemSpt[1];
					if(filemd5)
					{
						_md5dict.setValue(filename, filemd5);
					}
					else
					{
						trace("can not get md5", filename);
					}
				}
			}
			
			//print next
			printDictMd5();
		}
	}
}