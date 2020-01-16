package com.jonlin.se.io
{
	import com.jonlin.an.geom.AnVec2;
	import com.jonlin.core.IDispose;
	import com.jonlin.se.support.EditConst;
	import com.jonlin.se.support.EditData;
	import com.jonlin.se.support.EditImage;
	import com.jonlin.utils.FileUtil;
	import com.jonlin.utils.IOUtil;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;

	/**
	 * 套装加载器
	 * @author jonlin
	 * @date 2019-8-10 下午6:49:01
	 */
	public class SuiteLoader implements IDispose
	{
		private var _loader:Loader;
		private var _step:int;
		private var _dirFile:File;
		private var _texFiles:Vector.<File>;
		private var _callback:Function;
		
		private var _editImgs:Vector.<EditImage>;
		private var _editData:EditData;
		
		public function SuiteLoader()
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onTexLoadSucc);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onTexLoadFail);
		}
		
		public function dispose():void
		{
			if (_loader) {
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onTexLoadSucc);
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onTexLoadFail);
				_loader.unloadAndStop();
				_loader = null;
			}
			this.clear();
		}
		
		private function clear():void
		{
			_dirFile = null;
			_texFiles = null;
			_editImgs = null;
			_editData = null;
			_callback = null;
		}
		
		public function load(dirFile:File, callback:Function):void
		{
			_texFiles = FileUtil.listFiles(dirFile.nativePath, EditConst.TEX_FILTER, false);
			const count:int = _texFiles.length;
			if (count == 0) {
				callback(null);
				return;
			}
			
			_texFiles.sort(function(a:File, b:File):int { return a.name > b.name ? 1 : -1; });
			_callback = callback;
			_editImgs = new Vector.<EditImage>();
			_dirFile = dirFile;
			_step = -1;
			this.nextFile();
		}
		
		private function nextFile():void
		{
			if (++_step >= _texFiles.length) {
				onTexLoadComplete();
				return;
			}
			_loader.loadBytes(IOUtil.readFile(_texFiles[_step]));
		}
		
		private function onTexLoadSucc(event:Event):void
		{
			var bm:Bitmap = _loader.contentLoaderInfo.content as Bitmap;
			if (bm) {
				var ei:EditImage = new EditImage();
				ei.name = FileUtil.getFilename(_texFiles[_step]);
				ei.data = bm.bitmapData.clone();
				ei.orig = new AnVec2();
				_editImgs.push(ei);
				_loader.unloadAndStop();
			}
			this.nextFile();
		}
		
		private function onTexLoadFail(event:IOErrorEvent):void
		{
			this.nextFile();
		}
		
		private function onTexLoadComplete():void
		{
			var data:EditData = new EditData(EditData.TYPE_SUITE, _dirFile, _editImgs);
			do {
				var sfjFile:File = FileUtil.newFile(EditConst.SFJ, _dirFile);
				if (sfjFile.exists) {
					var obj:Object = JSON.parse(IOUtil.readString(sfjFile));
					if (obj) {
						data.fromConfig(obj);
						break;
					}
				}
				data.fromDeafault();
			} while(false);
			
			var callback:Function = _callback;
			this.clear();
			callback(data);
		}
	}
}