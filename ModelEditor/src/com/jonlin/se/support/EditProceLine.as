package com.jonlin.se.support
{
	import com.jonlin.core.IDispose;

	/**
	 * 帧段轴
	 * @author jonlin
	 * @date 2019-8-19 下午3:51:03
	 */
	public class EditProceLine implements IDispose
	{
		private var _list:Vector.<EditProce>;
		
		public function EditProceLine()
		{
			_list = new Vector.<EditProce>();
		}
		
		public function dispose():void
		{
			this.clear();
		}
		
		public function clear():void
		{
			for each(var ef:EditProce in _list) {
				ef.dispose();
			}
			_list.length = 0;
		}
		
		public function init(images:Vector.<EditImage>, time:int):void
		{
			this.clear();
			for (var i:int=0, n:int=images.length, ef:EditProce; i<n; ++i) {
				ef = new EditProce();
				ef.name = images[i].name;
				ef.time = time;
				_list.push(ef);
			}
		}

		public function decode(text:String, sep1:String, sep2:String):void
		{
			this.clear();
			var list:Array = text.split(sep1);
			for (var i:int=0, n:int=list.length, ef:EditProce; i<n; ++i) {
				ef = new EditProce();
				ef.decode(list[i], sep2);
				_list.push(ef);
			}
		}
		
		public function encode(sep1:String, sep2:String):String
		{
			var list:Array = [];
			for (var i:int=0, n:int=_list.length; i<n; ++i) {
				list[i] = _list[i].encode(sep2);
			}
			return list.join(sep1);
		}
		
		public function buildPublish(sep1:String, sep2:String):String
		{
			var list:Array = [];
			for (var i:int=0, n:int=_list.length, prc:EditProce; i<n; ++i) {
				prc = _list[i];
				if (prc.isComment) {
					continue;
				}
				list[i] = prc.encode(sep2);
			}
			return list.join(sep1);
		}
		
		public function get length():int
		{
			return _list.length;
		}
		
		public function getProce(i:int):EditProce
		{
			return _list[i];
		}
	}
}