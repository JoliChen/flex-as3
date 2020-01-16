package com.joli.extension.drawswf.motion
{
	import com.jonlin.io.IReadable;
	import com.jonlin.io.IWriteable;
	
	import flash.utils.ByteArray;
	
	/**
	 * 动画数据
	 * @author Joli
	 * @date 2018-7-23 下午4:23:24
	 */
	public class MotionData implements IWriteable, IReadable
	{
		private var _attrValues:Vector.<Number>;
		
		public function MotionData()
		{
			_attrValues = new Vector.<Number>();
		}
		
		/**
		 * 运动参数值表
		 */
		public function get attrValues():Vector.<Number>
		{
			return _attrValues;
		}
		
		public function read(bytes:ByteArray):void
		{
			var len:uint = bytes.readByte();
			for (var i:int = 0; i<len; ++i) {
				_attrValues[i] = bytes.readFloat();
			}
		}
		
		public function write(bytes:ByteArray):void
		{
			var len:uint = _attrValues.length;
			bytes.writeByte(len);
			for (var i:int = 0; i<len; ++i) {
//				trace("attr=", _attrValues[i]);
				bytes.writeFloat(_attrValues[i]);
			}
		}
	}
}