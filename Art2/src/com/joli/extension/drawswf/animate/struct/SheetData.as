package com.joli.extension.drawswf.animate.struct
{
	import com.jonlin.io.IReadable;
	import com.jonlin.io.IWriteable;
	
	import flash.utils.ByteArray;

	/**
	 * 序列帧数据
	 * @author Joli
	 * @date 2018-7-20 上午11:18:48
	 */
	public class SheetData implements IReadable, IWriteable
	{	
		private var _sheetId:uint;
		private var _scale:Number;
		private var _frames:Vector.<SheetFrame>
		
		public function SheetData(sheetId:uint=0, scale:Number=1.0)
		{
			_sheetId = sheetId;
			_scale = scale;
			_frames = new Vector.<SheetFrame>();
		}
		
		/**
		 * 更新缩放系数
		 */
		public function updateScale(scale:Number):void
		{
			_scale = scale;
		}

		/**
		 * 资源ID
		 */
		public function get sheetId():uint
		{
			return _sheetId;
		}
		
		/**
		 * 缩放系数
		 */
		public function get scale():Number
		{
			return _scale;
		}

		/**
		 * 序列帧
		 */
		public function get frames():Vector.<SheetFrame>
		{
			return _frames;
		}
		
		
		public function read(bytes:ByteArray):void
		{
			_sheetId = bytes.readUnsignedInt();
			_scale = bytes.readFloat();
			
			const len:uint = bytes.readShort();
			for (var i:int=0, frame:SheetFrame; i<len; ++i) {
				frame = new SheetFrame();
				frame.read(bytes);
				_frames[i] = frame;
			}
		}
		
		public function write(bytes:ByteArray):void
		{
			bytes.writeUnsignedInt(_sheetId);
			bytes.writeFloat(_scale);
			
			const len:uint = _frames.length;
			bytes.writeShort(len);
			for (var i:int=0, frame:SheetFrame; i<len; ++i) {
				frame = _frames[i];
				frame.write(bytes);
			}
		}
	}
}