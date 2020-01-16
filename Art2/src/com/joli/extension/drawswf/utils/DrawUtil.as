package com.joli.extension.drawswf.utils
{
	import com.jonlin.utils.BitmapDataUtil;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientBevelFilter;
	import flash.filters.GradientGlowFilter;
	import flash.geom.Rectangle;
	
	/**
	 * 显示对象绘制辅助工具，解决滤镜外光晕绘制不完全的问题。
	 * @author Joli
	 * @date 2018-7-19 下午8:32:20
	 */
	public final class DrawUtil
	{		
		private static function optFilterArea(base:BitmapFilter, area:Array):void
		{
			var blurX:Number = 0, blurY:Number = 0;
			if (null == base) {
				// do no thing
			} else if (base is BevelFilter) {
				const f1:BevelFilter = base as BevelFilter;
				blurX = f1.blurX;
				blurY = f1.blurY;
			} else if (base is BlurFilter) {
				const f2:BlurFilter = base as BlurFilter;
				blurX = f2.blurX;
				blurY = f2.blurY;
			} else if (base is DropShadowFilter) {
				const f3:DropShadowFilter = base as DropShadowFilter;
				if (!f3.inner) {
					blurX = f3.blurX;
					blurY = f3.blurY;
				}
			} else if (base is GlowFilter) {
				const f4:GlowFilter = base as GlowFilter;
				if (!f4.inner) {
					blurX = f4.blurX;
					blurY = f4.blurY;
				}
			} else if (base is GradientBevelFilter) {
				const f5:GradientBevelFilter = base as GradientBevelFilter;
				blurX = f5.blurX;
				blurY = f5.blurY;
			} else if (base is GradientGlowFilter) {
				const f6:GradientGlowFilter = base as GradientGlowFilter;
				blurX = f6.blurX;
				blurY = f6.blurY;
			}
			area[0] = blurX;
			area[1] = blurY;
		}
		
		private static function optHaloRect(filters:Array, rect:Rectangle, safeFactor:Number=1.25):void
		{
			var dx:Number = 0, dy:Number = 0;
			const tempArea:Array = [];
			for (var i:int=0, e:int=filters.length; i<e; ++i) {
				optFilterArea(filters[i], tempArea);
				if (tempArea[0] > dx) {
					dx = tempArea[0];
				}
				if (tempArea[1] > dy) {
					dy = tempArea[1];
				}
			}
			rect.inflate(dx, dy);
		}
		
		private static function unionHalos(display:DisplayObject, space:DisplayObject, orgRect:Rectangle):void {
			if (!display) {
				return;//shape will be none
			}
			const filters:Array = display.filters;
			if (filters && filters.length > 0) {
				const rect:Rectangle = display.getBounds(space);
				if (!rect.isEmpty()) {
					optHaloRect(filters, rect);
					const temp:Rectangle = orgRect.union(rect);
					orgRect.setTo(temp.x, temp.y, temp.width, temp.height);
				} else {
					// trace("empty child:", rect);
				}
			}
			if (display is DisplayObjectContainer) {
				const node: DisplayObjectContainer = display as DisplayObjectContainer;
				for (var i: int = 0, e: int = node.numChildren; i < e; ++i) {
					unionHalos(node.getChildAt(i), space, orgRect)
				}
			}
		}
			
		public static function drawDisplay(display:DisplayObject, scale:Number, rect:Rectangle):BitmapData {
			unionHalos(display, display, rect);
			return BitmapDataUtil.drawScale(display, scale, rect);
		}
	}
}