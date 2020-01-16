package com.joli.modules.artist.image.slim.process.utils
{
	import com.joli.art2.console.ILogcat;
	import com.jonlin.core.IDispose;
	import com.jonlin.utils.FileUtil;
	import com.joli.modules.artist.image.slim.process.utils.kit.TinyPNG;
	
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	/**
	 * 
	 * @author Joli
	 * @date 2019-3-29 下午2:59:39
	 */
	public class SlimGroup implements ISlimImageHandler, IDispose
	{
		private static const filter:Vector.<String> = Vector.<String>(["png", "jpg", "jpeg"]);
		private var _errorMap:Dictionary;
		private var _slimKits:Vector.<ISlimImageKit>;
		private var _slimImgs:Vector.<File>;
		private var _srcPos:int;
		private var _dstDir:String;
		private var _log:ILogcat;
		private var _handler:ISlimGroupHandler;
		
		public function SlimGroup(nums:int, log:ILogcat)
		{
			_log = log;
			_slimKits = new Vector.<ISlimImageKit>(nums, true);
			for (var i:int=_slimKits.length-1; i>-1; --i) {
				_slimKits[i] = new TinyPNG(log);
			}
		}
		
		public function dispose():void {
			if (_slimKits) {
				for (var i:int=_slimKits.length-1; i>-1; --i) {
					_slimKits[i].dispose();
				}
				_slimKits = null;
			}
			if (_slimImgs) {
				_slimImgs.length = 0;
				_slimImgs = null;
			}
			_log = null;
			_handler = null;
			_errorMap = null;
		}
		
		public function onSlimError(srcImage:String, errorMsg:String):void
		{
			_errorMap[srcImage] = errorMsg;
		}
		
		public function onSlimExit(kit:ISlimImageKit):void
		{
			if (_slimImgs.length > 0) {
				slimNext(kit);
				return;
			}
			dumpErrors();
			_handler.onSlimComplete(0);
		}
		
		private function dumpErrors():void
		{
			for (var image:String in _errorMap) {
				_log.error("{0}\n{1}", image, _errorMap[image]);
			}
			_errorMap = new Dictionary();
		}
		
		public function start(srcDir:String, dstDir:String, handler:ISlimGroupHandler, recursive:Boolean=true):void
		{
			_slimImgs = FileUtil.listFiles(srcDir, filter, recursive);
			if (0 == _slimImgs.length) {
				handler.onSlimComplete(0);
				return;
			}
			_dstDir = dstDir;
			_srcPos = srcDir.length;
			_handler = handler;
			_errorMap = new Dictionary();
			
			const num:int = Math.min(_slimKits.length, _slimImgs.length);
			for (var i:int=0; i<num; i++) {
				slimNext(_slimKits[i]);
			}
		}
		
		private function slimNext(kit:ISlimImageKit):void
		{
			if (!kit.isIdle()) {
				return;
			}
			const srcPath:String = _slimImgs.pop().nativePath;
			const dstPath:String = _dstDir + srcPath.substring(_srcPos);
			kit.slim(srcPath, dstPath, this);
		}
		
	}
}