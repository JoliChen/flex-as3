package com.joli.modules.artist.image.slim.process.utils
{
	
	/**
	 * 
	 * @author Joli
	 * @date 2019-3-29 下午4:36:53
	 */
	public interface ISlimGroupHandler
	{
		/**
		 * 压缩结束
		 * @param errorCode 错误码
		 */
		function onSlimComplete(errorCode:int):void
	}
}