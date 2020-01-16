package com.jonlin.se.user
{
	import com.jonlin.io.LocalStorage;

	/**
	 * 
	 * @author jonlin
	 * @date 2019-8-10 下午6:31:34
	 */
	public class UserTPConf extends LocalStorage
	{
		public static const TEX_PACKER:String = "TEX_PACKER";
		public static const TRIM_NAME_EXT:String = "TRIM_NAME_EXT";
		public static const MAX_SIZE:String = "MAX_SIZE";
		public static const SCALE:String = "SCALE";
		
		
		public function UserTPConf(userName:String)
		{
			super(userName + "/tpconf");
		}
		
		public function get texpacker():String
		{
			return optValue(TEX_PACKER);
		}
		public function set texpacker(s:String):void
		{
			put(TEX_PACKER, s);
		}
		
		public function get trimNameExt():Boolean
		{
			return optValue(TRIM_NAME_EXT, true);
		}
		public function set trimNameExt(b:Boolean):void
		{
			put(TRIM_NAME_EXT, b);
		}
		
		public function get maxSize():int
		{
			return optValue(MAX_SIZE, 1024);
		}
		public function set maxSize(i:int):void
		{
			put(MAX_SIZE, i);
		}
		
		public function get scale():Number
		{
			return optValue(SCALE, 1.0);
		}
		public function set scale(i:Number):void
		{
			put(SCALE, i);
		}
	}
}