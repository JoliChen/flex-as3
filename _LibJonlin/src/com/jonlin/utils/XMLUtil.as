package com.jonlin.utils
{
	/**
	 * 
	 * @author jonlin
	 * @date 2019-8-23 下午7:20:41
	 */
	public final class XMLUtil
	{
		public static function isYes(xml:XML):Boolean
		{
			return "true" == xml.toString();	
		}
	}
}