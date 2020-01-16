package com.jonlin.se.support
{
	import com.adobe.utils.StringUtil;
	import com.jonlin.core.IDispose;
	import com.jonlin.structure.Bit32Array;

	/**
	 * 帧段
	 * @author jonlin
	 * @date 2019-8-16 下午4:12:56
	 */
	public class EditProce implements IDispose
	{
		private static const IS_EMPTY:int = 0;
		private static const IS_COMMENT:int = 1;
		
		private var _flag:Bit32Array;
		private var _name:String;
		private var _time:int;
		private var _event:String;
		
		public function EditProce()
		{
			_flag = new Bit32Array();
			_name = "";
			_time = 0;
			_event = null;
		}
		
		public function dispose():void
		{
			_flag = null;
			_name = null;
			_time = 0;
			_event = null;
		}
		
		public function get isEmpty():Boolean
		{
			return _flag.not0(IS_EMPTY);
		}
		public function set isEmpty(b:Boolean):void
		{
			b ? _flag.set1(IS_EMPTY) : _flag.set0(IS_EMPTY);
		}
		
		public function get isComment():Boolean
		{
			return _flag.not0(IS_COMMENT);
		}
		public function set isComment(b:Boolean):void
		{
			b ? _flag.set1(IS_COMMENT) : _flag.set0(IS_COMMENT);
		}
		
		public function get name():String
		{
			return _name;
		}
		public function set name(s:String):void
		{
			_name = s;
			this.isEmpty = ("." == s);
		}
		
		public function get time():int
		{
			return _time;
		}
		public function set time(i:int):void
		{
			_time = i;
		}
		
		public function get event():String
		{
			return _event;
		}
		public function set event(s:String):void
		{
			_event = s;	
		}
		
		public function encode(sep:String):String
		{
			var list:Array = [this.name, this.time];
			if (this.event) {
				list.push(this.event);
			}
			var text:String = list.join(sep);
			return this.isComment ? "#" + text : text;
		}
		public function decode(text:String, sep:String):void
		{
			if (StringUtil.beginsWith(text, "#")) {
				this.isComment = true;
				text = text.substring(1);
			}
			var list:Array = text.split(sep);
			if (list.length > 0) {
				this.name = list[0];
			}
			if (list.length > 1) {
				this.time = int(list[1]);
			}
			if (list.length > 2) {
				this.event = list[2];
			}
		}
	}
}