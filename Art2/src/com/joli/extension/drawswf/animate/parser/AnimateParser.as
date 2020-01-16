package com.joli.extension.drawswf.animate.parser
{
	import com.joli.art2.console.ILogcat;
	import com.joli.extension.drawswf.animate.struct.AnimateData;
	import com.joli.extension.drawswf.animate.struct.AnimateElement;
	import com.joli.extension.drawswf.animate.struct.AnimateFrame;
	import com.joli.extension.drawswf.animate.struct.AnimateMotion;
	import com.joli.extension.drawswf.motion.MotionData;
	import com.joli.extension.drawswf.utils.MotionCompressUtil;
	import com.joli.extension.drawswf.utils.MotionReader;
	import com.jonlin.core.IDispose;
	import com.jonlin.utils.ReflectUtil;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	/**
	 * 动画解析器
	 * @author Joli
	 * @date 2018-7-20 下午2:20:52
	 */
	public class AnimateParser implements IDispose
	{
		private var _log:ILogcat;
		private var _animateOutput:IAnimateOutput;
		private var _printAniWarns:Boolean;
		
		// 空白动画帧唯一单例
		private var _blankAnimateFrame:AnimateFrame;
		// 动画属性读取器
		private var _motionReader:MotionReader;
		
		private var _animateData:AnimateData;
		private var _childrenSet:Vector.<DisplayObject>;
		
		/**
		 * 动画解析器
		 * @param logcat 日志输出
		 * @param animateOutput 动画输出器
		 */		
		public function AnimateParser(logcat:ILogcat, animateOutput:IAnimateOutput)
		{
			super();
			_log = logcat;
			_animateOutput = animateOutput;
			_blankAnimateFrame = new AnimateFrame();
			_motionReader = new MotionReader();
		}
		
		public function dispose():void
		{
			_log = null;
			_animateOutput = null;
			_blankAnimateFrame = null;
			_animateData = null;
			if (_motionReader) {
				_motionReader.dispose();
				_motionReader = null;
			}
			if (_childrenSet) {
				_childrenSet.length = 0;
				_childrenSet = null;
			}
		}
		
		/**
		 * 输出动画分析警告 
		 * @param enable
		 */		
		public function set warnMovieclipEnable(enable:Boolean):void
		{
			_printAniWarns = enable;
		}
		
		/**
		 * 分析影片剪辑
		 * @param mc
		 * @param animateId
		 * @param exportFmt
		 * @param scale
		 */		
		public function parse(mc:MovieClip, animateId:uint, exportFmt:String, scale:Number=1):void
		{
			const animateData:AnimateData = new AnimateData(animateId);
			// on parse begin
			_animateData = animateData;
			_childrenSet = new Vector.<DisplayObject>();
			_motionReader.begin(exportFmt, animateData.colorFilters);
			// doing parse
			parseAnim(mc);
			// on parse end
			_motionReader.end();
			_childrenSet = null;
			_animateData = null;
			
			// trace("filter:", animateData.colorFilters.length, "[" + animateData.colorFilters + "]");
			// validate animate data
			for (var i:int=0, len:int=animateData.sequence.length; i<len; ++i) {
				if (animateData.sequence[i].motions.length > 0) {
					_animateOutput.putAnimate(animateData);
					return;
				}
			}
			_log.error("动画数据无效:{0}", animateId);
		}
		
		private function parseAnim(mc:MovieClip):void
		{
			var frameData:AnimateFrame;
			var frameIndex:int;
			var elementNums:int;
			const frameEnd:int = mc.totalFrames + 1;
			for (var i:int=1; i<frameEnd; ++i) {
				mc.gotoAndStop(i);
				elementNums = mc.numChildren;
				if (0 == elementNums) {
					_animateData.sequence.push(_blankAnimateFrame);
					continue;
				}
				frameIndex = i - 1; // 程序中是数组形式实现（索引从0开始），这里需要-1才能跟程序对上。
				frameData = new AnimateFrame();
				_animateData.sequence.push(frameData);
				parseFrame(mc, frameIndex, elementNums, frameData);
			}
			compressMotion();
		}
		
		private function parseFrame(mc:MovieClip, frameIndex:uint, children:int, frameData:AnimateFrame):void
		{
			var motionData:AnimateMotion;
			var elementId:uint;
			var sheetClass:String;
			var child:DisplayObject;
			var childPos:int;
			for (var j:int=0; j<children; ++j) {
				child = mc.getChildAt(j);
				if (!child.visible || 0.0 == child.alpha) {
					continue;
				}
				sheetClass = ReflectUtil.getClassPath(child, null);
				if ("flash.display::MovieClip" == sheetClass) {
					if (_printAniWarns) {
						_log.warn("子元件未设置链接类[{0}-{1}\t{2}]", frameIndex+1, j, sheetClass);
					}
					continue;
				}
				if (!(child is MovieClip)) {
					if (_printAniWarns) {
						_log.warn("子元件不是影片剪辑[{0}-{1}\t{2}]", frameIndex+1, j, sheetClass);
					}
					continue;
				}
				childPos = _childrenSet.lastIndexOf(child);
				if (-1 != childPos) {
					elementId = childPos;
				} else {
					elementId = _childrenSet.length;
					_childrenSet[elementId] = child;
					createElement(elementId, sheetClass, frameIndex);
				}
				motionData = new AnimateMotion(elementId);
				frameData.motions.push(motionData);
				_motionReader.read(child, motionData.attrValues);
			}
		}
		
		private function createElement(elementId:uint, sheetClass:String, birthFrame:uint):void
		{
			const sheetId:uint = _animateOutput.putSheet(sheetClass);
			const element:AnimateElement = new AnimateElement(elementId, sheetId, birthFrame);
			_animateData.elements[elementId] = element;
		}
		
		private function compressMotion():void {
			const elementFramesMap:Dictionary = new Dictionary();
			const animateFrames:Vector.<AnimateFrame> = _animateData.sequence;
			var animateChilds:Vector.<AnimateMotion>;
			var animateMotion:AnimateMotion;
			var elementFrames:Vector.<MotionData>;
			var elementId:String;
			for (var i:int=0, len:int=animateFrames.length, j:int; i<len; ++i) {
				animateChilds = animateFrames[i].motions;
				for (j=animateChilds.length-1; j>-1; --j) {
					animateMotion = animateChilds[j];
					elementId = String(animateMotion.elementId);
					if (elementId in elementFramesMap) {
						elementFrames = elementFramesMap[elementId];
					} else {
						elementFrames = new Vector.<MotionData>();
						elementFramesMap[elementId] = elementFrames;
					}
					elementFrames.push(animateMotion);
				}
			}
			const keys:Vector.<int> = _motionReader.motionKeySet;
			const stas:Vector.<AnimateElement> = _animateData.elements;
			for (elementId in elementFramesMap) {
				MotionCompressUtil.slim(elementFramesMap[elementId], keys, stas[uint(elementId)]);
			}
		}
	}
}