package com.joli.extension.drawswf.motion
{
	import com.jonlin.io.IReadable;
	import com.jonlin.io.IWriteable;
	
	import flash.utils.ByteArray;
	
	/**
	 * 动画压缩数据
	 * @author Joli
	 * @date 2018-7-23 下午4:26:30
	 */
	public class MotionSlimData implements IReadable, IWriteable
	{
		private var _changeKeys:Vector.<uint>;
		private var _birthAttrs:Vector.<Number>;
		
		public function MotionSlimData()
		{
			_changeKeys = new Vector.<uint>();
			_birthAttrs = new Vector.<Number>();
		}

		/**
		 * 运动参数键表
		 */
		public function get changeKeys():Vector.<uint>
		{
			return _changeKeys;
		}

		/**
		 * 首帧运动参数
		 */
		public function get birthAttrs():Vector.<Number>
		{
			return _birthAttrs;
		}
		
		public function read(bytes:ByteArray):void
		{
			var len:uint = bytes.readByte();
			for (var i:int=0; i<len; ++i) {
				_changeKeys[i] = bytes.readByte();
			}
			
			len = bytes.readByte();
			for (i=0; i<len; ++i) {
				_birthAttrs[i] = bytes.readFloat();
			}
		}
		
		public function write(bytes:ByteArray):void
		{
			var len:uint = _changeKeys.length;
			bytes.writeByte(len);
			for (var i:int=0; i<len; ++i) {
				bytes.writeByte(_changeKeys[i]);
			}
			
			len = _birthAttrs.length;
			bytes.writeByte(len);
			for (i=0; i<len; ++i) {
				bytes.writeFloat(_birthAttrs[i]);
			}
		}
	}
}