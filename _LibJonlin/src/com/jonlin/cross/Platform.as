package com.jonlin.cross
{
	import flash.system.Capabilities;
	
	/**
	 * 跨平台
	 * @author Joli
	 * @date 2018-7-18 下午4:26:16
	 */
	public final class Platform
	{
		/**
		 * 苹果系统
		 */
		public static function isMacOSX():Boolean
		{
			return Capabilities.os.indexOf("Mac") > -1;
		}
		
		/**
		 * windwos系统
		 */
		public static function isWindows():Boolean
		{
			return -1 != Capabilities.os.indexOf("Windows") > -1;
		}
	}
}