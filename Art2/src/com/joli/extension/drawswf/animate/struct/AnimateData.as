package com.joli.extension.drawswf.animate.struct
{
	import com.jonlin.io.IReadable;
	import com.jonlin.io.IWriteable;
	
	import flash.utils.ByteArray;

	/**
	 * 动画数据
	 * @author Joli
	 * @date 2018-7-19 下午2:21:32
	 */
	public class AnimateData implements IReadable, IWriteable
	{
		private var _animateId:uint;
		private var _sequence:Vector.<AnimateFrame>;
		private var _elements:Vector.<AnimateElement>;
		private var _colorFilters:Vector.<Array>;
		private var _sheetPackage:Vector.<uint>;
		private var _unpackSheets:Vector.<uint>;
		
		public function AnimateData(animateId:uint=0)
		{
			_animateId = animateId;
			_sequence = new Vector.<AnimateFrame>();
			_elements = new Vector.<AnimateElement>();
			_colorFilters = new Vector.<Array>();
			_sheetPackage = new Vector.<uint>();
			_unpackSheets = new Vector.<uint>();
		}
		
		/**
		 * 动画ID 
		 */
		public function get animateId():uint
		{
			return _animateId;
		}
		
		/**
		 * 动画序列帧
		 */
		public function get sequence():Vector.<AnimateFrame>
		{
			return _sequence;
		}

		/**
		 * 子元件表
		 */
		public function get elements():Vector.<AnimateElement>
		{
			return _elements;
		}
		
		/**
		 * 颜色滤镜表
		 */		
		public function get colorFilters():Vector.<Array>
		{
			return _colorFilters;
		}
		
		/**
		 * 散装序列帧
		 */
		public function get unpackSheets():Vector.<uint>
		{
			return _unpackSheets;
		}
		
		/**
		 * 打包序列帧
		 */
		public function get sheetPackage():Vector.<uint>
		{
			return _sheetPackage;
		}
		
		public function read(bytes:ByteArray):void
		{
			_animateId = bytes.readUnsignedInt();
			
			var animFrame:AnimateFrame;
			var len:uint = bytes.readShort();
			for (var i:int=0; i<len; ++i) {
				animFrame = new AnimateFrame();
				animFrame.read(bytes);
				_sequence[i] = animFrame;
			}
			
			var animElem:AnimateElement;
			len = bytes.readShort();
			for (i=0; i<len; ++i) {
				animElem = new AnimateElement();
				animElem.read(bytes);
				_elements[i] = animElem;
			}
			
			var mtrx:Array, size:uint, j:int;
			len = bytes.readShort();
			for (i=0; i<len; ++i) {
				mtrx = [];
				size = bytes.readByte();
				for (j=0; j<size; ++j) {
					mtrx[j] = bytes.readFloat();
				}
				_colorFilters[i] = mtrx;
			}
			
			len = bytes.readByte();
			for (i=0; i<len; ++i) {
				_sheetPackage[i] = bytes.readUnsignedInt();
			}
			
			len = bytes.readByte();
			for (i=0; i<len; ++i) {
				_unpackSheets[i] = bytes.readUnsignedInt();
			}
		}
		
		public function write(bytes:ByteArray):void
		{
			bytes.writeUnsignedInt(_animateId);
			
			var len:uint = _sequence.length;
			bytes.writeShort(len);
			for (var i:int=0; i<len; ++i) {
				_sequence[i].write(bytes);
			}
			
			len = _elements.length;
			bytes.writeShort(len);
			for (i=0; i<len; ++i) {
				_elements[i].write(bytes);
			}
			
			len = _colorFilters.length;
			bytes.writeShort(len);
			var mtrx:Array, size:uint, j:int;
			for (i=0; i<len; ++i) {
				mtrx = _colorFilters[i];
				size = mtrx.length;
				bytes.writeByte(size);
				for (j=0; j<size; ++j) {
					bytes.writeFloat(mtrx[j]);
				}
			}
			
			len = _sheetPackage.length;
			bytes.writeByte(len);
			for (i=0; i<len; ++i) {
				bytes.writeUnsignedInt(_sheetPackage[i]);
			}
			
			len = _unpackSheets.length;
			bytes.writeByte(len);
			for (i=0; i<len; ++i) {
				bytes.writeUnsignedInt(_unpackSheets[i]);
			}
		}
	}
}