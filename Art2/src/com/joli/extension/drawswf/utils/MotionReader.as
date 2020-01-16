package com.joli.extension.drawswf.utils
{
	import com.adobe.utils.ArrayUtil;
	import com.joli.extension.drawswf.constans.BlendType;
	import com.joli.extension.drawswf.constans.MotionFormat;
	import com.joli.extension.drawswf.constans.MotionKey;
	import com.jonlin.core.IDispose;
	import com.jonlin.utils.MatrixUtil;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.Dictionary;

	/**
	 * 动画数据读取工具
	 * @author Joli
	 * @date 2018-7-23 下午7:00:36
	 */
	public final class MotionReader extends ValuePrecision implements IDispose
	{
		private var _motionKeySet:Vector.<int>;
		private var _blendMapping:Dictionary;
		private var _colorFilterPool:Vector.<Array>;
		private var _readFormat:String;
		
		public function MotionReader(precision:int=6)
		{
			super(precision);
			_motionKeySet = new <int> [
				MotionKey.x,
				MotionKey.y,
				MotionKey.scaleX,
				MotionKey.scaleY,
				MotionKey.rotationX,
				MotionKey.rotationY,
				MotionKey.redMultiplier,
				MotionKey.greenMultiplier,
				MotionKey.blueMultiplier,
				MotionKey.alphaMultiplier,
				MotionKey.blendMode,
				MotionKey.colorFitler
			];
			_blendMapping = new Dictionary(true);
			_blendMapping[BlendMode.NORMAL] 	= BlendType.NORMAL;
			_blendMapping[BlendMode.ADD] 		= BlendType.ADD;
			_blendMapping[BlendMode.ALPHA] 		= BlendType.ALPHA;
			_blendMapping[BlendMode.DARKEN] 	= BlendType.DARKEN;
			_blendMapping[BlendMode.DIFFERENCE] = BlendType.DIFFERENCE;
			_blendMapping[BlendMode.ERASE] 		= BlendType.ERASE;
			_blendMapping[BlendMode.HARDLIGHT] 	= BlendType.HARDLIGHT;
			_blendMapping[BlendMode.INVERT] 	= BlendType.INVERT;
			_blendMapping[BlendMode.LAYER] 		= BlendType.LAYER;
			_blendMapping[BlendMode.LIGHTEN] 	= BlendType.LIGHTEN;
			_blendMapping[BlendMode.MULTIPLY] 	= BlendType.MULTIPLY;
			_blendMapping[BlendMode.OVERLAY] 	= BlendType.OVERLAY;
			_blendMapping[BlendMode.SCREEN] 	= BlendType.SCREEN;
			_blendMapping[BlendMode.SHADER] 	= BlendType.SHADER;
			_blendMapping[BlendMode.SUBTRACT] 	= BlendType.SUBTRACT;
		}
		
		public function dispose():void
		{
			_motionKeySet = null;
			_blendMapping = null;
			_colorFilterPool = null;
		}
		
		/**
		 * 动画属性序列
		 * @return 
		 */		
		public function get motionKeySet():Vector.<int>
		{
			return _motionKeySet;
		}
		
		/**
		 * 开始
		 * @param readFormat 数据读取格式
		 * @param colorFilterPool 颜色滤镜参数池
		 */		
		public function begin(readFormat:String, colorFilterPool:Vector.<Array>):void
		{
			_readFormat = readFormat;
			_colorFilterPool = colorFilterPool;
		}
		
		/**
		 * 结束
		 */		
		public function end():void
		{
			_colorFilterPool = null;
		}
		
		/**
		 * 按顺序读取动画属性
		 * @param display
		 * @param motionValues
		 */		
		public function read(display:DisplayObject, motionValues:Vector.<Number>):void
		{
			var key:int, value:Number;
			for (var i:int=0, len:int=_motionKeySet.length; i<len; ++i) {
				key = _motionKeySet[i];
				value = getAttr(display, key);
				// trace("read attr:", key, value);
				motionValues[i] = fixed(value);
			}
		}
		
		private function getAttr(display:DisplayObject, key:int):Number
		{
			var value:Number = 0;
			switch(key) {
				case MotionKey.x:
					value = display.x;
					break;
				case MotionKey.y:
					value = display.y
					break;
				case MotionKey.scaleX:
					value = display.scaleX;
					break;
				case MotionKey.scaleY:
					value = display.scaleY;
					break;
				case MotionKey.rotationX:
					value = MatrixUtil.getSkewX(display.transform.matrix);
					break;
				case MotionKey.rotationY:
					value = MatrixUtil.getSkewY(display.transform.matrix);
					break;
				case MotionKey.redMultiplier:
					value = display.transform.colorTransform.redMultiplier;
					break;
				case MotionKey.greenMultiplier:
					value = display.transform.colorTransform.greenMultiplier;
					break;
				case MotionKey.blueMultiplier:
					value = display.transform.colorTransform.blueMultiplier;
					break;
				case MotionKey.alphaMultiplier:
					value = display.transform.colorTransform.alphaMultiplier;
					break;
				case MotionKey.blendMode:
					value = genBlendMode(display.blendMode);
					break;
				case MotionKey.colorFitler:
					value = genColorFilterUID(display);
					break;
			}
			return value;
		}
		
		private function genBlendMode(mode:String):int
		{
			return _blendMapping[mode];
		}
		
		private function genColorFilterUID(display:DisplayObject):int
		{
			const matrix:Array = readColorFilter(display);
			if (null == matrix) {
				return -1;
			}
			for (var i:int=_colorFilterPool.length-1; i>-1; --i) {
				if (ArrayUtil.arraysAreEqual(_colorFilterPool[i], matrix)) {
					return i;
				}
			}
			i = _colorFilterPool.length;
			_colorFilterPool[i] = matrix;
			return i;
		}
		
		private function readColorFilter(display:DisplayObject):Array
		{
			const filters:Array = display.filters;
			for (var i:int=0, len:int=filters.length, f:*; i<len; ++i) {
				f = filters[i];
				if (f is ColorMatrixFilter) {
					return transColorMatrix((f as ColorMatrixFilter).matrix);
				}
			}
			return null;
		}
		
		private function transColorMatrix(filter:Array):Array
		{
			const mtx:Array = [];
			for (var j:int=0, size:int=filter.length; j<size; ++j) {
				mtx[j] = fixed(filter[j]);
			}
			if (MotionFormat.cocos2d == _readFormat) {
				return toMatrix4(mtx);
			}
			return mtx;
		}
		
		private function toMatrix4(mt5:Array):Array
		{
			const mt4:Array = [];
			mt4[0]  = mt5[0];
			mt4[1]  = mt5[5];
			mt4[2]  = mt5[10];
			mt4[3]  = mt5[15];
			mt4[4]  = mt5[1];
			mt4[5]  = mt5[6];
			mt4[6]  = mt5[11];
			mt4[7]  = mt5[16];
			mt4[8]  = mt5[2];
			mt4[9]  = mt5[7];
			mt4[10] = mt5[12];
			mt4[11] = mt5[17];
			mt4[12] = mt5[3];
			mt4[13] = mt5[8];
			mt4[14] = mt5[13];
			mt4[15] = mt5[18];
			return mt4;
		}
	}
}