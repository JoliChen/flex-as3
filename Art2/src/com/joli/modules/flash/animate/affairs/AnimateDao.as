package com.joli.modules.flash.animate.affairs
{
	import com.joli.art2.affairs.IAffairsDAO;
	import com.joli.extension.drawswf.constans.AnimateOut;
	import com.joli.extension.drawswf.constans.MotionFormat;
	import com.jonlin.io.LocalStorage;
	
	/**
	 * 动画导出习惯记录
	 * @author Joli
	 * @date 2018-7-17 下午10:40:13
	 */
	public class AnimateDao extends LocalStorage implements IAffairsDAO
	{
		private static const k_src_files:String = "src_files";
		private static const k_dest_dir:String = "dest_dir";
		private static const k_make_dir:String = "make_dir";
		private static const k_tp_exec:String = "texturepacker";
		private static const k_tp_maxsize:String = "tp_maxsize";
		private static const k_tp_scale:String = "tp_scale";
		private static const k_tp_premultiplyAlpha:String = "tp_premultiplyAlpha";
		private static const k_slimImages:String = "slim_images";
		private static const k_animate_source:String = "animate_source";
		private static const k_animate_format:String = "animate_format";
		private static const k_print_mc_warns:String = "print_mc_warns";
		private static const k_print_profile:String = "print_profile";
		private static const k_animate_id_set:String = "animate_id_set";
		private static const k_auto_pow2_limit:String = "auto_pow2_limit";
		
		public function AnimateDao(daoName:String)
		{
			super(daoName);
		}
		
		public function get src_root():String
		{
			return (0 == src_files.length) ? null : src_files[0];
		}
		
		public function get src_files():Array
		{
			return getValue(k_src_files) || [];
		}
		public function set src_files(paths:Array):void
		{
			put(k_src_files, paths);
		}
		
		public function get dest_dir():String
		{
			return optValue(k_dest_dir, "");
		}
		public function set dest_dir(dir:String):void
		{
			put(k_dest_dir, dir);
		}
		
		public function get make_dir():String
		{
			return optValue(k_make_dir, "");
		}
		public function set make_dir(dir:String):void
		{
			put(k_make_dir, dir);
		}
		
		public function get texturepacker():String
		{
			return optValue(k_tp_exec, "");
		}
		public function set texturepacker(tp:String):void
		{
			put(k_tp_exec, tp);
		}
		
		public function get tp_maxsize():int
		{
			return optValue(k_tp_maxsize, 1024);
		}
		public function set tp_maxsize(maxsize:int):void
		{
			put(k_tp_maxsize, maxsize);
		}
		
		public function get tp_scale():Number
		{
			return optValue(k_tp_scale, 1);
		}
		public function set tp_scale(scale:Number):void
		{
			put(k_tp_scale, scale);
		}
		
		public function get tp_premultiplyAlpha():Boolean
		{
			return optValue(k_tp_premultiplyAlpha, false);
		}
		public function set tp_premultiplyAlpha(enabled:Boolean):void
		{
			put(k_tp_premultiplyAlpha, enabled);
		}
		
		public function get auto_pow2_limit():Number
		{
			return optValue(k_auto_pow2_limit, 0.83);
		}
		
		public function set auto_pow2_limit(limitScale:Number):void
		{
			put(k_auto_pow2_limit, limitScale);
		}
		
		public function get slimImages():Boolean
		{
			return optValue(k_slimImages, false);
		}
		public function set slimImages(enabled:Boolean):void
		{
			put(k_slimImages, enabled);
		}
		
		public function get animate_source():String
		{
			return optValue(k_animate_source, AnimateOut.multiple);
		}
		public function set animate_source(s:String):void
		{
			put(k_animate_source, s);
		}
		
		public function get animate_format():String
		{
			return optValue(k_animate_format, MotionFormat.cocos2d);
		}
		public function set animate_format(s:String):void
		{
			put(k_animate_format, s);
		}
		
		public function get animate_id_set():String
		{
			return optValue(k_animate_id_set, "");
		}
		public function set animate_id_set(s:String):void
		{
			put(k_animate_id_set, s);
		}
		
		public function get print_mc_warns():Boolean
		{
			return optValue(k_print_mc_warns, false);
		}
		public function set print_mc_warns(b:Boolean):void
		{
			put(k_print_mc_warns, b);
		}
		
		public function get print_profile():Boolean
		{
			return optValue(k_print_profile, true);
		}
		public function set print_profile(enabled:Boolean):void
		{
			put(k_print_profile, enabled);
		}
	}
}