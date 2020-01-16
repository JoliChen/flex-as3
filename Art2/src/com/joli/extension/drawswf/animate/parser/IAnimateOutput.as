package com.joli.extension.drawswf.animate.parser
{
	import com.joli.extension.drawswf.animate.struct.AnimateData;
	
	/**
	 * 动画资源输出
	 * @author Joli
	 * @date 2018-8-1 下午8:57:13
	 */
	public interface IAnimateOutput
	{
		/**
		 * 输出动画
		 * @param animateData
		 */		
		function putAnimate(animateData:AnimateData):void;
			
		/**
		 * 输出序列帧
		 * @param sheetClassName 序列帧链接类名
		 * @return 序列帧ID
		 */			
		function putSheet(sheetClassName:String):uint
	}
}