package com.joli.extension.drawswf.animate.parser.draw
{
	import com.jonlin.core.IDispose;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	/**
	 * 影片剪辑播放播放控制
	 * @author Joli
	 * @date 2018-7-20 下午11:49:03
	 */
	public final class MovieClipSteper implements IDispose
	{
		/**
		 * 要播放的多层嵌套影片剪辑
		 */		
		private var _mc:MovieClip;
		
		/**
		 * 子级影片剪辑播放状态 
		 */		
		private var _playStateDic:Dictionary;
		
		/**
		 * 子级影片剪辑播放帧 
		 */		
		private var _playFrameDic:Dictionary;
		
		
		public function MovieClipSteper() {}
		
		/**
		 * 初始化
		 * @param mc
		 */
		public function init(mc:MovieClip):void
		{
			_mc = mc;
			_playStateDic = new Dictionary();
			_playFrameDic = new Dictionary();
		}
		
		public function dispose():void
		{
			_mc = null;
			_playStateDic = null;
			_playFrameDic = null;
		}
		
		/**
		 * 播放到下一帧
		 * @param frame:int 指定帧
		 */
		public function next(frame:int = 0):void
		{
			if (frame == 0) {
				_mc.nextFrame();
			} else {
				_mc.gotoAndStop(frame);
			}
			
			// 重置播放状态
			for (var m:* in _playStateDic) {
				_playStateDic[m] = false;
			}
			playNode(_mc);
		}
		
		/**
		 * 播放容器中的影片
		 * @param container:DisplayObjectContainer		容器
		 */
		private function playNode(container:DisplayObjectContainer):void
		{
			if (!container) {
				return;
			}
			for (var i:int=0, num:int=container.numChildren; i<num; i++) {
				playChild(container.getChildAt(i) as MovieClip);
			}
		}
		
		/**
		 * 播放影片对象
		 * @param child
		 */
		private function playChild(child:MovieClip):void
		{
			if (!child) {
				return;
			}
			if (!Boolean(_playStateDic[child])) {
				var frame:int = 0;
				if (child in _playFrameDic) {
					frame = _playFrameDic[child];
				}
				frame++;
				if (frame > child.totalFrames) {
					frame = 1;
				}
				child.gotoAndStop(frame);
				_playStateDic[child] = true;
				_playFrameDic[child] = frame;
			}
			playNode(child);
		}
	}
}