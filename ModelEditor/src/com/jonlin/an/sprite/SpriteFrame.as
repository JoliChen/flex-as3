package com.jonlin.an.sprite
{
	import com.jonlin.an.geom.AnVec2;
	
	import flash.display.BitmapData;

	/**
	 * 动画精灵帧数据
	 * @author jonlin
	 * @date 2019-8-10 上午11:54:51
	 */
	public class SpriteFrame
	{
		private var _texture:BitmapData;
		private var _origin:AnVec2;
		
		public function SpriteFrame()
		{
			_origin = new AnVec2();
		}
		
		public function get texture():BitmapData
		{
			return _texture;
		}
		public function set texture(o:BitmapData):void
		{
			_texture = o;
		}
		
		public function get origin():AnVec2
		{
			return _origin;
		}
	}
}