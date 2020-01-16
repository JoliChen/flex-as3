package com.joli.modules.flash.animate.process.build
{
	import com.extenal.plist.LocalPlist;
	import com.jonlin.core.IDispose;
	import com.jonlin.utils.BitmapDataUtil;
	import com.jonlin.utils.IOUtil;
	import com.jonlin.utils.MathUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	/**
	 * 图集自动缩回2的N次幂
	 * @author Joli
	 * @date 2019-5-18 下午5:42:13
	 */
	public class AtlasAutoPow2 implements IDispose
	{
		private var _autoPow2Limit:Number;//自动缩回pow2的限制系数
		private var _loader:Loader;
		private var _callback:Function;
		private var _imageFile:File;
		private var _plist:LocalPlist;
		private var _scale:Number;
		private var _bmd:BitmapData;
		private var _pngEncoderOptions:PNGEncoderOptions;
		
		public function AtlasAutoPow2()
		{
			_pngEncoderOptions = new PNGEncoderOptions();
			_callback = null;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageLoadFail);
		}
		
		public function dispose():void
		{
			_callback = null;
			if (_loader) {
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageLoaded);
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImageLoadFail);
				_loader.unloadAndStop(true);
				_loader = null;
			}
		}
		
		public function set autoPow2Limit(limit:Number):void
		{
			_autoPow2Limit = limit;
		}
		
		/**
		 * 自动缩回2的N次幂
		 * @param imageFile 图集文件
		 * @param plistFile 配置文件
		 * @param callback  回调
		 */
		public function shrink(imageFile:File, plistFile:File, callback:Function):void
		{
			if (!plistFile.exists || !imageFile.exists) {
				callback(1);
				return;
			}
			const plist:LocalPlist = new LocalPlist(plistFile);
			const vec2:Array = LocalPlist.parseVec(plist.root.metadata.size);
			calcShrinkPow2Scale(vec2[0], vec2[1]);
			if (isNaN(_scale)) {
				callback(1);
				return;
			}
			_plist = plist;
			_imageFile = imageFile;
			_callback = callback;
			_loader.load(new URLRequest(imageFile.url));
		}
	
		/**
		 * 计算缩回2的N次幂的系数
		 */
		private function calcShrinkPow2Scale(w:Number, h:Number):void {
			const wpow:int = MathUtil.prevPow2(w);
			const hpow:int = MathUtil.prevPow2(h);
			const wscal:Number = wpow / w;
			const hscal:Number = hpow / h;
			if (wscal < _autoPow2Limit) {
				if (hscal < _autoPow2Limit) {
					_scale = NaN;
					return;
				} else {
					_scale = hscal;
					w *= _scale;
					h = hpow;
				}
			} else {
				if (hscal < _autoPow2Limit) {
					_scale = wscal;
					w = wpow;
					h *= _scale;
				} else {
					if (wscal < hscal) {
						_scale = wscal;
						w = wpow;
						h *= _scale;
					} else {
						_scale = hscal;
						w *= _scale;
						h = hpow;
					}
				}
			}
			_bmd = new BitmapData(w, h, true, 0);
		}
		
		private function onImageLoaded(event:Event):void {
			var image:Bitmap = _loader.contentLoaderInfo.content as Bitmap;
			if (!image) {
				if (_callback != null) {
					_callback(1);
				}
				return
			}
			
			rebuildPlist(_bmd.width, _bmd.height, _scale);
			BitmapDataUtil.scale(image.bitmapData, _scale, _scale, _bmd);
			const buf:ByteArray = _bmd.encode(_bmd.rect, _pngEncoderOptions);
			_bmd.dispose();//销毁位图数据
			_bmd = null;
			IOUtil.writeFile(_imageFile, buf);
			
			if (_callback != null) {
				_callback(_scale);
			}
		}
		
		private function onImageLoadFail(event:IOErrorEvent):void {
			if (_callback != null) {
				_callback(1);
			}	
		}
		
		private function rebuildPlist(w:int, h:int, scale:Number):void {
			const root:XML = _plist.xml.dict[0];
			var node:XML, vec:Array, key:String, val:String;
			// 修改帧配置
			for each(node in root.dict[0].dict.children()) {
				if (node.name() == "key") {
					key = node;
					continue;
				}
				if (key == "frame") {
					vec = LocalPlist.parseVec(node);
					vec[0] = Math.floor(vec[0] * scale);//x
					vec[1] = Math.floor(vec[1] * scale);//y
					vec[2] = Math.ceil(vec[2] * scale);//width
					vec[3] = Math.ceil(vec[3] * scale);//height
					val = "{{" + vec[0] + "," + vec[1] + "},{" + vec[2] + "," + vec[3] + "}}";
					node.setChildren(val);
					continue;
				}
				if (key == "offset") {
					vec = LocalPlist.parseVec(node);
					vec[0] = Math.floor(vec[0] * scale);//x
					vec[1] = Math.floor(vec[1] * scale);//y
					val = "{" + vec[0] + "," + vec[1] + "}";
					node.setChildren(val);
					continue;
				}
				if (key == "sourceColorRect") {
					vec = LocalPlist.parseVec(node);
					vec[0] = Math.floor(vec[0] * scale);//x
					vec[1] = Math.floor(vec[1] * scale);//y
					vec[2] = Math.ceil(vec[2] * scale);//width
					vec[3] = Math.ceil(vec[3] * scale);//height
					val = "{{" + vec[0] + "," + vec[1] + "},{" + vec[2] + "," + vec[3] + "}}";
					node.setChildren(val);
					continue;
				}
				if (key == "sourceSize") {
					vec = LocalPlist.parseVec(node);
					vec[0] = Math.ceil(vec[0] * scale);//width
					vec[1] = Math.ceil(vec[1] * scale);//height
					val = "{" + vec[0] + "," + vec[1] + "}";
					node.setChildren(val);
					continue;
				}
			}
			// 修改元数据
			key = null;
			for each(node in root.dict[1].children()) {
				if (node.name() == "key") {
					key = node;
					continue;
				}
				if (key == "size") {
					val = "{" + w + "," + h + "}";
					node.setChildren(val);
					break;
				}
			}
			//trace(_plist.xml);
			_plist.save();
		}
	}
}