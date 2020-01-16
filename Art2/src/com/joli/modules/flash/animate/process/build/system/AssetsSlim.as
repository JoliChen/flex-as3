package com.joli.modules.flash.animate.process.build.system
{
	import com.joli.art2.console.ILogcat;
	import com.jonlin.core.IDispose;
	import com.jonlin.utils.FileUtil;
	import com.joli.modules.artist.image.slim.process.utils.ISlimGroupHandler;
	import com.joli.modules.artist.image.slim.process.utils.SlimGroup;
	
	import flash.filesystem.File;
	
	/**
	 * 动画图片压缩
	 * @author Joli
	 * @date 2019-3-29 下午9:29:44
	 */
	internal class AssetsSlim implements ISlimGroupHandler, IDispose
	{
		private var _log:ILogcat;
		private var _destSheetDir:File;
		private var _destGroupDir:File;
		private var _unslimSheetDir:File;
		private var _unslimGroupDir:File;
		private var _slim2:SlimGroup;
		
		private var _step:int;
		private var _callback:Function;
		
		public function AssetsSlim(log:ILogcat, unslimDir:File, sheetDir:File, groupDir:File)
		{
			_log = log;
			_destSheetDir = sheetDir;
			_destGroupDir = groupDir;
			_unslimSheetDir = FileUtil.newFile("sheet", unslimDir);
			_unslimGroupDir = FileUtil.newFile("group", unslimDir);
		}
		
		public function setup():void {
			if (_unslimSheetDir.exists) {
				try {
					_unslimSheetDir.deleteDirectory(true);
				} catch(error:Error) {
					_log.error(error.getStackTrace());
				}
			}
			if (_unslimGroupDir.exists) {
				try {
					_unslimGroupDir.deleteDirectory(true);
				} catch(error:Error) {
					_log.error(error.getStackTrace());
				}
			}
			_unslimSheetDir.createDirectory();
			_unslimGroupDir.createDirectory();
			
			if (!_slim2) {
				_slim2 = new SlimGroup(5, _log);
			}
		}

		public final function fullSheetPair(sheetId:uint, pair:SpriteSheetPair):void
		{
			pair.setPair(sheetId.toString(), _unslimSheetDir);
		}

		public final function fullGroupPair(groupId:uint, pair:SpriteSheetPair):void
		{
			pair.setPair(groupId.toString(), _unslimGroupDir);
		}
		
		public function start(callback:Function):void {
			_log.debug("start slim sheet ...");
			_callback = callback;
			_step = 1;
			copyPlists();
			_slim2.start(_unslimSheetDir.nativePath, _destSheetDir.nativePath, this);
		}
		
		private function copyPlists():void {
			const filter:Vector.<String> = Vector.<String>([AnimateDisk.texDataFormat.substring(1)]);
			const plists:Vector.<File> = new Vector.<File>();
			FileUtil.fillFiles(plists, _unslimSheetDir, filter, false);
			for (var i:int=plists.length-1; i>-1; --i) {
				FileUtil.moveToDir(plists[i], _destSheetDir);
			}
			
			plists.length = 0;
			FileUtil.fillFiles(plists, _unslimGroupDir, filter, false);
			for (i=plists.length-1; i>-1; --i) {
				FileUtil.moveToDir(plists[i], _destGroupDir);
			}
		}
		
		public function onSlimComplete(errorCode:int):void {
			if (1 == _step) {
				_step = 2;
				_slim2.start(_unslimGroupDir.nativePath, _destGroupDir.nativePath, this);
			} else if (2 == _step) {
				_step = 3;
				onFinish();
			}
		}

		private function onFinish():void {
			_log.debug("all sheet slim done");
			if (_callback != null) {
				_callback();
			}
		}
		
		public function dispose():void {
			_log = null;
			_callback = null;
			if (_slim2) {
				_slim2.dispose();
				_slim2 = null;
			}
		}
	}
}