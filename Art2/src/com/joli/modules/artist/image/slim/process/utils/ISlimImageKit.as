package com.joli.modules.artist.image.slim.process.utils
{
	import com.jonlin.core.IDispose;
	
	
	/**
	 * 图片压缩工具接口
	 * @author Joli
	 * @date 2018-8-30 下午4:25:57
	 */
	public interface ISlimImageKit extends IDispose
	{
		/**
		 * 是否支持
		 * @return boolean
		 */
		function isSupport():Boolean;
		
		/**
		 * 是否闲置
		 * @return boolean
		 */
		function isIdle():Boolean;
		
		/**
		 * 清理
		 */
		function clear():void;
		
		/**
		 * 压缩
		 * @param srcFile 源文件
		 * @param srcFile 输出文件
		 * @param handler 批量任务
		 */
		function slim(srcFile:String, dstFile:String, handler:ISlimImageHandler):void
	}
}