package com.joli.extension.drawswf.animate.parser.draw
{
	import com.joli.extension.drawswf.animate.struct.SheetData;
	import com.joli.extension.drawswf.animate.struct.SheetFrame;
	import com.joli.extension.drawswf.constans.FrameType;
	import com.joli.extension.drawswf.utils.DrawUtil;
	import com.joli.extension.drawswf.utils.ValuePrecision;
	import com.jonlin.core.IDispose;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	/**
	 * 序列帧动画渲染
	 * @author Joli
	 * @date 2018-7-24 下午3:21:52
	 */
	public class SheetRender extends ValuePrecision implements IDispose
	{
		// 影片剪辑跳帧控制器
		private var _movieSteper:MovieClipSteper;
		// 空白纹理帧单例
		private var _blankSheetFrame:SheetFrame;
		
		public function SheetRender(precision:int=6)
		{
			super(precision);
			_movieSteper = new MovieClipSteper();
			_blankSheetFrame = new SheetFrame(FrameType.blank);
		}
		
		public function dispose():void
		{
			if (_movieSteper) {
				_movieSteper.dispose();
				_movieSteper = null;
			}
			_blankSheetFrame = null;
		}
		
		public function renderder(sheetClass:Class, sheetData:SheetData, scale:Number=1):Vector.<BitmapData>
		{
			const sheetMovie:MovieClip = new sheetClass();
			const totalFrames:int = sheetMovie.totalFrames;
			if (totalFrames < 0) {
				return null;
			}
			const textures:Vector.<BitmapData> = new Vector.<BitmapData>(totalFrames, true);
			var prevBmd:BitmapData;
			var currBmd:BitmapData;
			_movieSteper.init(sheetMovie);
			for (var i:int=0; i<totalFrames; ++i) {
				_movieSteper.next(i+1);
				currBmd = draw(sheetMovie, sheetData, prevBmd, scale);
				if (currBmd) {
					prevBmd = currBmd;
				}
				textures[i] = currBmd;
			}
			return textures;
		}
		
		private function draw(sheetMovie:MovieClip, sheetData:SheetData, prevBmd:BitmapData, scale:Number):BitmapData
		{
			const bounds:Rectangle = sheetMovie.getBounds(null);
			// ------------------------空白帧----------------------
			if (bounds.isEmpty()) {
				sheetData.frames.push(_blankSheetFrame);
				return null;
			}
			
			const currTex:BitmapData = DrawUtil.drawDisplay(sheetMovie, scale, bounds);
			if (bounds.isEmpty()) {
				currTex.dispose();
				sheetData.frames.push(_blankSheetFrame);
				return null;
			}
			
			const offsetX:Number = fixed(bounds.x);
			const offsetY:Number = fixed(bounds.y);
			var sheetFrame:SheetFrame;
			// ------------------------复刻帧----------------------
			if (prevBmd && 0 == currTex.compare(prevBmd)) {
				currTex.dispose();
				sheetFrame = new SheetFrame(FrameType.last, offsetX, offsetY);
				sheetData.frames.push(sheetFrame);
				return null;
			}
			// ------------------------关键帧----------------------
			sheetFrame = new SheetFrame(FrameType.key, offsetX, offsetY);
			sheetData.frames.push(sheetFrame);
			return currTex;
		}
	}
}