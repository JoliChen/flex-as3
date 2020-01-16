package com.jonlin.se.support
{
	import com.jonlin.an.geom.AnVec2;
	import com.jonlin.core.IDispose;
	
	import flash.display.BitmapData;

	/**
	 * 图片
	 * @author jonlin
	 * @date 2019-8-19 下午3:21:24
	 */
	public class EditImage implements IDispose
	{
		private var _name:String;
		private var _data:BitmapData;
		private var _orig:AnVec2;
		
		public function EditImage()
		{
		}
		
		public function dispose():void
		{
			_name = null;
			_orig = null;
			if (_data) {
				_data.dispose();
				_data = null;
			}
		}
		
		public function get name():String
		{
			return _name;
		}
		public function set name(s:String):void
		{
			_name = s;
		}
		
		public function get data():BitmapData
		{
			return _data;
		}
		public function set data(o:BitmapData):void
		{
			_data = o;
		}
		
		public function get orig():AnVec2
		{
			return _orig;
		}
		public function set orig(o:AnVec2):void
		{
			_orig = o;
		}
	}
}