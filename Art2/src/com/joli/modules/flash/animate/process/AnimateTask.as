package com.joli.modules.flash.animate.process
{
	import com.joli.art2.affairs.task.TaskExecutor;
	import com.joli.art2.affairs.task.TaskCase;
	import com.joli.extension.drawswf.animate.parser.AnimateParser;
	import com.joli.extension.drawswf.constans.AnimateOut;
	import com.jonlin.utils.FileUtil;
	import com.jonlin.utils.TimeUtil;
	import com.jonlin.utils.IOUtil;
	import com.jonlin.utils.Regular;
	import com.jonlin.utils.TextUtil;
	import com.joli.modules.flash.animate.affairs.AnimateReq;
	import com.joli.modules.flash.animate.process.build.AnimateOutput;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	
	/**
	 * SWF动画导出任务
	 * @author Joli
	 * @date 2018-7-18 下午6:48:56
	 */
	public class AnimateTask extends TaskExecutor
	{
		/**
		 * 任务请求参数
		 */		
		private var _request:AnimateReq;
		
		/**
		 * 应用程序域
		 */		
		private var _swfDomain:ApplicationDomain;
		
		/**
		 * SWF加载器
		 */
		private var _loader:Loader;
		
		/**
		 * SWF索引
		 */		
		private var _swfPos:int;
		
		/**
		 * SWF路径
		 */		
		private var _swfUrl:String;
		
		/**
		 * 动画分析 
		 */		
		private var _animateParser:AnimateParser;
		
		/**
		 * 动画输出
		 */		
		private var _animateOutput:AnimateOutput;
				

		public function AnimateTask(asyncTask:TaskCase)
		{
			super(asyncTask);
		}
		
		override public function dispose():void
		{
			super.dispose();
			if (_loader) {
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onloadSwfIOError);
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onloadSwfComplete);
				_loader.unloadAndStop();
				_loader = null;
			}
			if (_animateParser) {
				_animateParser.dispose();
				_animateParser = null;
			}
			if (_animateOutput) {
				_animateOutput.dispose();
				_animateOutput = null;
			}
			_swfPos = 0;
			_swfUrl = null;
			_swfDomain = null;
			_request = null;
		}
		
		public function start(request:AnimateReq):void 
		{
			debug("开始动画导出任务");
			_request = request;
			_swfDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			_swfPos = 0;
			_swfUrl = null;
			
			_animateOutput = new AnimateOutput(this, request.dest_dir, request.make_dir);
			_animateOutput.setOptions(request);
			_animateParser = new AnimateParser(this, _animateOutput);
			_animateParser.warnMovieclipEnable = request.print_mc_warns
			exportNextSWF();
		}
		
		private function exportNextSWF():void
		{
			if (_loader) {
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onloadSwfIOError);
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onloadSwfComplete);
				_loader.unloadAndStop();
				_loader = null;
			}
			if (_swfPos < _request.src_files.length) {
				_swfUrl = _request.src_files[_swfPos++];
				debug("载入:{0} {1}", _swfPos, _swfUrl);
				const context:LoaderContext = new LoaderContext(false, _swfDomain);
				context.allowLoadBytesCodeExecution = true; 
				context.allowCodeImport = true;
				context.checkPolicyFile = false;
				context.requestedContentParent = null;
				context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onloadSwfIOError);
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onloadSwfComplete);
				_loader.loadBytes(IOUtil.read(_swfUrl), context);
			} else {
				onParseComplete(); // on parse complete
			}
		}
		
		private function onloadSwfIOError(event:IOErrorEvent):void
		{
			exportNextSWF();
		}
		
		private function onloadSwfComplete(event:Event):void
		{
			_loader.stopAllMovieClips();
			const swf:DisplayObjectContainer = _loader.contentLoaderInfo.content as DisplayObjectContainer;
			if (!swf) {
				error("加载失败:{0}", _swfUrl);
				exportNextSWF();
				return;
			}
			for (var i:int=swf.numChildren-1, anim:MovieClip, child:DisplayObject; i>-1; --i) {
				child = swf.getChildAt(i);
				if (child is MovieClip) {
					anim = child as MovieClip;
					break;
				}
			}
			if (!anim) {
				error("未找到动画影片剪辑:{0}", _swfUrl);
				exportNextSWF();
				return;
			}
			switch (_request.animate_source) {
				case AnimateOut.multiple:
					exportMultipleAnimates(anim);
					break;
				case AnimateOut.onlyOne:
					exportOnlyoneAnimate(anim);
					break;
			}
		}

		private function exportOnlyoneAnimate(animateMC:MovieClip):void
		{
			const animateName:String = FileUtil.getFilename(_swfUrl);
			if (!Regular.isInteger(animateName)) {
				error("SWF名称无法转成动画ID:{0}", _swfUrl);
				exportNextSWF();
				return;
			}
			const animateId:uint = uint(animateName);
			debug("parse animate:{0}", animateId);
			_animateParser.parse(animateMC, animateId, _request.animate_format);
			exportNextSWF();
		}
		
		private function exportMultipleAnimates(animatesMC:MovieClip):void
		{
			var child:DisplayObject;
			if (null != _request.animate_id_set && _request.animate_id_set.length > 0) {
				var animate_id_set:Array = _request.animate_id_set.split(",");
				for (var m:int=0, animateId:int, tempId:String; m<animate_id_set.length; ++m) {
					tempId = TextUtil.trim(animate_id_set[m]);
					if (tempId.length <= 0) {
						continue;
					}
					animateId = parseInt(tempId);
					animatesMC.gotoAndStop(animateId);
					for (var n:int=animatesMC.numChildren-1; n>-1; --n) {
						child = animatesMC.getChildAt(n);
						if (child is MovieClip) {
							debug("parse animate:{0}", animateId);
							_animateParser.parse(child as MovieClip, animateId, _request.animate_format);
							break;
						}
					}
				}
			} else {
				for (var i:int=1, end:int=animatesMC.totalFrames+1, j:int; i<end; ++i) {
					animatesMC.gotoAndStop(i);
					for (j=animatesMC.numChildren-1; j>-1; --j) {
						child = animatesMC.getChildAt(j);
						if (child is MovieClip) {
							debug("parse animate:{0}", i);
							_animateParser.parse(child as MovieClip, i, _request.animate_format);
							break;
						}
					}
				}
			}
			exportNextSWF();
		}
		
		private function onParseComplete():void
		{
			if (_animateParser) {
				_animateParser.dispose();
				_animateParser = null;
			}
			TimeUtil.delay(60, outputAnimate);
		}
		
		private function outputAnimate():void
		{
			_animateOutput.output(_swfDomain, onOutputComplete);
		}
		
		private function onOutputComplete():void
		{
			if (_animateOutput) {
				_animateOutput.dispose();
				_animateOutput = null;
			}
			debug("export animate done");
			exitTask(0);
		}
	}
}