package com.joli.modules.artist.image.slim.process.utils
{
	/**
	 * 批量压缩任务
	 * @author Joli
	 * @date 2018-8-31 下午1:34:56
	 */
	public interface ISlimImageHandler
	{
		
		/**
		 * 压缩错误
		 * @param srcImage 压缩源图片路径
		 * @param errorMsg 错误信息
		 */
		function onSlimError(srcImage:String, errorMsg:String):void;
		
		/**
		 * 压缩工具退出
		 * @param kit 压缩工具
		 */
		function onSlimExit(kit:ISlimImageKit):void
	}
}