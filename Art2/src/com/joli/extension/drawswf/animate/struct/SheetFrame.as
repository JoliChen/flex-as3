package com.joli.extension.drawswf.animate.struct
{
	import com.jonlin.io.IReadable;
	import com.jonlin.io.IWriteable;
	
	import flash.utils.ByteArray;

	/**
	 * 序列帧
	 * @author Joli
	 * @date 2018-7-20 下午5:15:31
	 */
	public class SheetFrame implements IReadable, IWriteable
	{
		private var _frameType:uint;
		private var _offsetX:Number;
		private var _offsetY:Number;
		
		public function SheetFrame(frameType:uint=0, offsetX:Number=0.0, offsetY:Number=0.0)
		{
			_frameType = frameType;
			_offsetX = offsetX;
			_offsetY = offsetY;
		}
		
		/**
		 * 帧类型 
		 */
		public function get frameType():uint
		{
			return _frameType;
		}

		/**
		 * 纹理X偏移 
		 */
		public function get offsetX():Number
		{
			return _offsetX;
		}

		/**
		 * 纹理Y偏移 
		 */
		public function get offsetY():Number
		{
			return _offsetY;
		}
		
		public function read(bytes:ByteArray):void
		{
			_frameType = bytes.readByte();
			_offsetX = bytes.readFloat();
			_offsetY = bytes.readFloat();
		}
		
		public function write(bytes:ByteArray):void
		{
			bytes.writeByte(_frameType);
			bytes.writeFloat(_offsetX);
			bytes.writeFloat(_offsetY);
		}
	}
}