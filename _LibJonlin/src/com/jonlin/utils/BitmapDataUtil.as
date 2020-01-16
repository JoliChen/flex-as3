package com.jonlin.utils
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	/**
	 * 位图处理工具
	 * @author Adiers
	 */
	public final class BitmapDataUtil
	{
		private static const smoothing:Boolean = true;
		private static const matrix:Matrix = new Matrix();
		private static var width:int, height:int;
		
		static public function drawScale(display:DisplayObject, scale:Number, bounds:Rectangle, transparent:Boolean = true, fillcolor:uint = 0x0):BitmapData
		{
			//尺寸
			width = Math.ceil(bounds.width * scale);
			height = Math.ceil(bounds.height * scale);
			//偏移、缩放。
			matrix.identity();
			matrix.tx = -bounds.x;
			matrix.ty = -bounds.y;
			matrix.scale(scale, scale);
			var src:BitmapData = new BitmapData(width, height, transparent, fillcolor);
			src.draw(display, matrix, null, null, null, smoothing);
			return src;
		}
		
		/**
		 * 绘制整个显示对象
		 * @param display:DisplayObject	显示对象
		 * @param scale:Number 缩放系数
		 * @param rect:Rectangle 绘制的矩形
		 * @param transparent:Boolean 是否透明
		 * @param fillColor:uint 默认填充ARGB值
		 * @return BitmapData 绘制后的位图
		 */
		static public function drawScaleCenter(display:DisplayObject, scale:Number, rect:Rectangle = null, transparent:Boolean = true, fillColor:uint = 0x0):BitmapData
		{
			if(!rect)
			{
				rect = display.getBounds(null);
			}
			
			var tx:Number, ty:Number;
			tx = -rect.x;
			ty = -rect.y;		
			var w:int, h:int, _w:int, _h:int;
			w = Math.ceil(rect.width);
			h = Math.ceil(rect.height);
			_w = Math.ceil(w * scale);
			_h = Math.ceil(h * scale);
			
			//绘制原图（缩放值）
			matrix.identity();
			matrix.tx = tx;
			matrix.ty = ty;
			matrix.scale(scale, scale);
			var src:BitmapData = new BitmapData(_w, _h, transparent, fillColor);
			src.draw(display, matrix, null, null, null, smoothing);
			
			//把原图丢到原尺寸图里
			var dst:BitmapData = new BitmapData(w, h, transparent, fillColor);
			var bytes:ByteArray = src.getPixels(src.rect);
			bytes.position = 0;
			rect.x = Math.round((w - _w) * 0.5);
			rect.y = Math.round((h - _h) * 0.5);
			rect.width = src.width;
			rect.height = src.height;
			dst.setPixels(rect, bytes);
			
			//释放源图
			src.dispose();
			return dst;
		}
		
		/**
		 * 比较两张位图一致
		 * @param b1:BitmapData		位图数据1
		 * @param b2:BitmapData		位图数据2
		 * @return Boolean 是否一致
		 */
		static public function compare(b1:BitmapData, b2:BitmapData):Boolean
		{
			if(!b1 || !b2) {
				return false;
			}
			return b1.compare(b2) == 0;
		}
		
		//水平翻转一个位图
		public static function flipHorizontal(src:BitmapData, transparent:Boolean = true, fillColor:uint = 0):BitmapData
		{
			matrix.identity();
			matrix.a = -1;
			matrix.tx = src.width;
			const dst:BitmapData = new BitmapData(src.width, src.height, transparent, fillColor);
			dst.draw(src, matrix, null, null, null, smoothing);
			return dst;
		}
		
		//垂直翻转一个位图
		public static function flipVertical(src:BitmapData, transparent:Boolean = true, fillColor:uint = 0):BitmapData
		{
			matrix.identity();
			matrix.d = -1;
			matrix.ty = src.height;
			const dst:BitmapData = new BitmapData(src.width, src.height, transparent, fillColor);
			dst.draw(src, matrix, null, null, null, smoothing);
			return dst;
		}
		
		//缩放位图
		public static function scale(src:BitmapData, scaleX:Number, scaleY:Number, dst:BitmapData=null):BitmapData
		{
			if (null == dst) {
				width = scaleX * src.width;
				height = scaleY * src.height;
				dst = new BitmapData(width, height, true, 0);
			}
			matrix.identity();
			matrix.scale(scaleX, scaleY);
			dst.draw(src, matrix, null, null, null, smoothing);
			return dst;
		}
		
		public static function rotateLeft(src:BitmapData):BitmapData
		{
			matrix.identity();
			matrix.rotate(-Math.PI/2);
			matrix.translate(0, src.width);
			var dst:BitmapData = new BitmapData(src.height, src.width, true, 0);
			dst.draw(src, matrix, null, null, null, smoothing);
			return dst;
		}
		
		public static function rotateRight(src:BitmapData):BitmapData{
			matrix.identity();
			matrix.rotate(Math.PI/2);
			matrix.translate(src.height, 0);
			var dst:BitmapData = new BitmapData(src.height, src.width, true, 0);
			dst.draw(src, matrix, null, null, null, smoothing);
			return dst;
		}
	}
}