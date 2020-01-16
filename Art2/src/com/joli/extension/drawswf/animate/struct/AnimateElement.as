package com.joli.extension.drawswf.animate.struct
{
	import com.joli.extension.drawswf.motion.MotionSlimData;
	
	import flash.utils.ByteArray;

	/**
	 * 动画子元件，相当于一个手动编辑的粒子。
	 * @author Joli
	 * @date 2018-7-20 下午9:27:52
	 */
	public class AnimateElement extends MotionSlimData
	{
		private var _elementId:uint;
		private var _sheetId:uint;
		private var _birthFrameIndex:uint;
		
		public function AnimateElement(elementId:uint=0, sheetId:uint=0, birthFrameIndex:uint=0)
		{
			super();
			_elementId = elementId;
			_sheetId = sheetId;
			_birthFrameIndex = birthFrameIndex;
		}
		
		/**
		 * 子元件ID
		 */
		public function get elementId():uint
		{
			return _elementId;
		}

		/**
		 * 资源ID
		 */
		public function get sheetId():uint
		{
			return _sheetId;
		}

		/**
		 * 诞生帧索引 
		 */
		public function get birthFrameIndex():uint
		{
			return _birthFrameIndex;
		}
		
		override public function read(bytes:ByteArray):void
		{
			_elementId = bytes.readShort();
			_sheetId = bytes.readUnsignedInt();
			_birthFrameIndex = bytes.readShort();
			super.read(bytes);
		}
		
		override public function write(bytes:ByteArray):void
		{
			bytes.writeShort(_elementId);
			bytes.writeUnsignedInt(_sheetId);
			bytes.writeShort(_birthFrameIndex);
			super.write(bytes);
		}
	}
}