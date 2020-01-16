package com.jonlin.an.sprite
{
	import com.jonlin.an.geom.AnVec2;
	
	import flash.utils.Dictionary;

	/**
	 * 精灵动画数据
	 * @author jonlin
	 * @date 2019-8-15 上午11:02:48
	 */
	public class SpriteAnima
	{
		private var _origin:AnVec2;
		private var _frames:Vector.<SpriteFrame>;
		private var _evtMap:Dictionary;
		
		public function SpriteAnima()
		{
			_origin = new AnVec2();
			_frames = new Vector.<SpriteFrame>();
		}
		
		public function clear():void
		{
			_origin.x = _origin.y = 0;
			_frames.length = 0;
			_evtMap = null;
		}
		
		public function get origin():AnVec2
		{
			return _origin;
		}
		
		public function get frames():Vector.<SpriteFrame>
		{
			return _frames;
		}
		
		public function get evtMap():Dictionary
		{
			return _evtMap;
		}
		public function set evtMap(d:Dictionary):void
		{
			_evtMap = d;
		}
	}
}