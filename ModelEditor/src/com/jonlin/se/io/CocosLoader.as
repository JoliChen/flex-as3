package com.jonlin.se.io
{
	import com.extenal.plist.LocalPlist;
	import com.extenal.plist.lib.PDict;
	import com.jonlin.an.geom.AnVec2;
	import com.jonlin.core.IDispose;
	import com.jonlin.se.support.EditConst;
	import com.jonlin.se.support.EditData;
	import com.jonlin.se.support.EditImage;
	import com.jonlin.utils.BitmapDataUtil;
	import com.jonlin.utils.IOUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Cocos Loader
	 * @author jonlin
	 * @date 2019-8-24 上午11:28:42
	 */
	public class CocosLoader implements IDispose
	{
		private var _loader:Loader;
		private var _plist:LocalPlist;
		private var _modeldata:Object;
		private var _callback:Function;
		
		public function CocosLoader()
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
		}
		
		private function clear():void
		{
			_plist = null;
			_modeldata = null;
			_callback = null;
		}
		
		public function load(plistFile:File, callback:Function):void
		{
			if (!plistFile.exists) {
				callback(null);
				return;
			}
			_plist = new LocalPlist(plistFile);
			_modeldata = _plist.root.metadata["modeldata"];
			if (!_modeldata) {
				callback(null);
				return;
			}
			
			var texPath:String = plistFile.nativePath;
			var dotPos:int = texPath.lastIndexOf(".");
			if (-1 == dotPos) {
				callback(null);
				return;
			}
			texPath = texPath.substring(0, dotPos+1) + EditConst.TEX_TYPE;
			var texFile:File = new File(texPath);
			if (!texFile.exists) {
				callback(null);
				return;
			}
			_callback = callback;
			_loader.loadBytes(IOUtil.readFile(texFile));
		}
		
		private function onTexLoadSucc(event:Event):void
		{
			var bm:Bitmap = _loader.contentLoaderInfo.content as Bitmap;
			if (!bm) {
				this.onImagesLoaded(null);
				return;
			}
			var sourceBmd:BitmapData = bm.bitmapData;
			if (!sourceBmd) {
				this.onImagesLoaded(null);
				return;
			}
			var images:Vector.<EditImage> = this.parseImages(sourceBmd, _plist.root.frames.object);
			_loader.unloadAndStop();
			this.onImagesLoaded(images);
		}
		
		private function onTexLoadFail(event:IOErrorEvent):void
		{
			trace(event.errorID, event.text);
			this.onImagesLoaded(null);
		}
		
		private function parseImages(sourceBmd:BitmapData, frames:Object):Vector.<EditImage>
		{
			var images:Vector.<EditImage> = new Vector.<EditImage>();
			var pos:Point = new Point(0, 0);
			var rect:Rectangle = new Rectangle();
			var item:Object, bmd:BitmapData, img:EditImage;
			for (var key:String in frames) {
				item = frames[key].object;
				img = new EditImage();
				img.name = key.replace(_modeldata["tag"], "");
				img.orig = new AnVec2();
				
				item.frame = item.frame.object.replace(/\{|\}/g, "").split(",");
				if (item.rotated.object) {
					rect.setTo(
						parseInt(item.frame[0]), 
						parseInt(item.frame[1]), 
						parseInt(item.frame[3]),
						parseInt(item.frame[2])
					);
				} else {
					rect.setTo(
						parseInt(item.frame[0]), 
						parseInt(item.frame[1]), 
						parseInt(item.frame[2]), 
						parseInt(item.frame[3])
					);
				}
				pos.x = pos.y = 0;
				bmd = new BitmapData(rect.width, rect.height, true);
				bmd.copyPixels(sourceBmd, rect, pos);
				if (item.rotated.object) {
					img.data = BitmapDataUtil.rotateLeft(bmd);
					bmd.dispose();
				} else {
					img.data = bmd;
				}
				item.sourceColorRect = item.sourceColorRect.object.replace(/\{|\}/g, "").split(",");
				img.orig.x = parseInt(item.sourceColorRect[0]);
				img.orig.y = parseInt(item.sourceColorRect[1]);
				images.push(img);
			}
			return images;
		}
		
		private function onImagesLoaded(images:Vector.<EditImage>):void
		{
			var data:EditData = new EditData(EditData.TYPE_COCOS, _plist.file, images);
			var anchor:Array = _modeldata.anchor.object.replace(/\{|\}/g, "").split(",");
			var size:Array = null;
			for each (var item:PDict in _plist.root.frames.object) {
				size = item.object.sourceSize.object.replace(/\{|\}/g, "").split(",");
				break;
			}
			
			data.fromConfig({
				"frames": _modeldata.frames,
				"width": parseFloat(size[0]),
				"height": parseFloat(size[1]),
				"x": parseFloat(anchor[0]),
				"y": parseFloat(anchor[1])
			});
			
			var callback:Function = _callback;
			this.clear();
			callback(data);
		}
	}
}