package com.jonlin.utils.io
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import com.jonlin.utils.IOUtil;
	
	/**
	 * 显示对象加载工具
	 * @author Adiers
	 */
	public final class LoaderUtil
	{
		/**
		 * 加载显示资源
		 * @param path:String 资源路径
		 * @param callback:Function	回调函数
		 */
		static public function load(path:String, domain:ApplicationDomain, callback:Function):void
		{
			const loader:Loader = new Loader();
			const loadif:LoaderInfo = loader.contentLoaderInfo;
			function finish(display:DisplayObject):void {
				loadif.removeEventListener(Event.COMPLETE, loadComplete);
				loadif.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
				loadif.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtError);
				loader.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtError);
				loader.stopAllMovieClips();
				callback(display);
				loader.unloadAndStop();
			}
			function loadComplete(event:Event):void {
				finish(loadif.content);
			}
			function loadError(event:IOErrorEvent):void {
				finish(null);
			}
			function uncaughtError(event:UncaughtErrorEvent):void {
				finish(null);
			}
			loadif.addEventListener(Event.COMPLETE, loadComplete);
			loadif.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			loadif.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtError);
			loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtError);
			
			for (var i:int=0; i<3; ++i) {
				const bytes:ByteArray = IOUtil.read(path);
				if (null == bytes || bytes.bytesAvailable <= 0) {
					continue;
				}
				const context:LoaderContext = new LoaderContext(false, domain);
				context.allowLoadBytesCodeExecution = true; 
				context.allowCodeImport = true;
				context.checkPolicyFile = false;
				context.requestedContentParent = null;
				context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
				loader.loadBytes(bytes, context);
				return;
			}
			finish(null);
		}
	}
}