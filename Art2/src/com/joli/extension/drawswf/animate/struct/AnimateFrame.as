package com.joli.extension.drawswf.animate.struct
{
	import com.jonlin.io.IReadable;
	import com.jonlin.io.IWriteable;
	
	import flash.utils.ByteArray;

	/**
	 * 动画帧
	 * @author Joli
	 * @date 2018-7-19 下午3:27:43
	 */
	public class AnimateFrame implements IWriteable, IReadable
	{
		private var _motions:Vector.<AnimateMotion>;
		
		public function AnimateFrame()
		{
			_motions = new Vector.<AnimateMotion>();
		}
		
		/**
		 * 子元件运动参数列表
		 */		
		public function get motions():Vector.<AnimateMotion>
		{
			return _motions;
		}
		
		public function read(bytes:ByteArray):void
		{
			var animMotion:AnimateMotion;
			var len:uint = bytes.readShort();
			for (var i:int=0; i<len; ++i) {
				animMotion = new AnimateMotion();
				animMotion.read(bytes);
				_motions[i] = animMotion;
			}
		}
		
		public function write(bytes:ByteArray):void
		{
			var len:uint = _motions.length;
			bytes.writeShort(len);
			for (var i:int=0; i<len; ++i) {
				_motions[i].write(bytes);
			}
		}
	}
}