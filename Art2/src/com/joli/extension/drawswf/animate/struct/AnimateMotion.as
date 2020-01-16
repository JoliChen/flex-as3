package com.joli.extension.drawswf.animate.struct
{
	import com.joli.extension.drawswf.motion.MotionData;
	
	import flash.utils.ByteArray;

	/**
	 * 动画运动参数
	 * @author Joli
	 * @date 2018-7-19 下午2:44:32
	 */
	public class AnimateMotion extends MotionData
	{
		private var _elementId:uint;
		
		public function AnimateMotion(elementId:uint=0)
		{
			super();
			_elementId = elementId;
		}
		
		/**
		 * 子元件ID
		 */
		public function get elementId():uint
		{
			return _elementId;
		}
		
		override public function read(bytes:ByteArray):void
		{
			_elementId = bytes.readShort();
			super.read(bytes);
		}
		
		override public function write(bytes:ByteArray):void
		{
			bytes.writeShort(_elementId);
			super.write(bytes);
		}
	}
}