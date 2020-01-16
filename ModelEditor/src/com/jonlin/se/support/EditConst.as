package com.jonlin.se.support
{
	import flash.net.FileFilter;

	/**
	 * 
	 * @author jonlin
	 * @date 2019-8-7 下午6:35:49
	 */
	public final class EditConst
	{
		public static const TEX_TYPE:String = "png";
		public static const TEX_FILTER:Vector.<String> = Vector.<String>([EditConst.TEX_TYPE]);
		public static const TEX_INFO_FILTER:FileFilter = new FileFilter("图集配置", "*.plist;*.json");
		
		public static const SFJ:String = "spriteframes.json";
	}
}