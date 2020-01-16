package com.joli.art2
{
	import com.joli.art2.features.ArtModuleBase;
	import com.joli.modules.artist.image.slim.SlimImageModule;
	import com.joli.modules.flash.animate.SWFAnimateModule;

	/**
	 * 模块构造工厂
	 * @author Joli
	 * @date 2018-7-16 下午8:30:16
	 */
	public final class ArtFactory
	{
		/**
		 * 挂载扩展根目录 
		 */		
		public static const MOUNT_ROOT:String = "mount";
		/**
		 * 图片压缩DAO
		 */		
		public static const DAO_ImageSlim:String = "SlimImageDAO";
		/**
		 * 动画导出DAO
		 */		
		public static const DAO_FlashAnimate:String = "FlashAnimateDAO";
		
		/**
		 * 载入所有模块
		 * @return 
		 */		
		public static function load():Vector.<ArtModuleBase>
		{
			return Vector.<ArtModuleBase>([
				new SlimImageModule(1, 	"图片压缩"),
				// new SWFActionModule(2, 	"SWF动作"),
				new SWFAnimateModule(3,	"SWF动画")
			]);
		}
	}
}