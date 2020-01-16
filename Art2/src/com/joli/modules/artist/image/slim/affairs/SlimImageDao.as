package com.joli.modules.artist.image.slim.affairs
{
	import com.joli.art2.affairs.IAffairsDAO;
	import com.jonlin.io.LocalStorage;
	
	
	/**
	 * 压缩图片习惯记录
	 * @author Joli
	 * @date 2018-8-30 下午2:44:02
	 */
	public class SlimImageDao extends LocalStorage implements IAffairsDAO
	{
		private static const k_src_dir:String = "src_dir";
		private static const k_dst_dir:String = "dst_dir";
		private static const k_recursion:String = "recursion";
		
		public function SlimImageDao(daoName:String)
		{
			super(daoName);
		}
		
		public function get src_dir():String
		{
			return optValue(k_src_dir, "");
		}
		public function set src_dir(dir:String):void
		{
			put(k_src_dir, dir);
		}
		
		public function get dst_dir():String
		{
			return optValue(k_dst_dir, "");
		}
		public function set dst_dir(dir:String):void
		{
			put(k_dst_dir, dir);
		}
		
		public function get recursion():Boolean
		{
			return optValue(k_recursion, true);
		}
		public function set recursion(can:Boolean):void
		{
			put(k_recursion, can);
		}
	}
}