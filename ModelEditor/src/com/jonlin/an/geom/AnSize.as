package com.jonlin.an.geom
{
	/**
	 * 尺寸
	 * @author jonlin
	 * @date 2019-8-10 下午4:33:27
	 */
	public class AnSize 
	{
		private var _width:Number;
		private var _height:Number;
		
		public function AnSize(width:Number=0, height:Number=0)
		{
			_width = width;
			_height = height;
		}
		
		public function set width(n:Number):void
		{
			_width = n;
		}
		
		public function get width():Number
		{
			return _width;
		}
		
		public function set height(n:Number):void
		{
			_height = n;
		}
		
		public function get height():Number
		{
			return _height;
		}
		
		public function isZero():Boolean
		{
			return _width == 0 && _height == 0;
		}
	}
}