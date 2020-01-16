package com.jonlin.se.user
{
	import com.jonlin.io.LocalStorage;
	
	/**
	 * 用户习惯记录
	 * @author jonlin
	 * @date 2019-8-7 下午3:04:31
	 */
	public class UserHabits extends LocalStorage
	{		
		public static const EDIT_BGCOLOR:String = "editBgColor";
		public static const SHOW_RULER_ABLE:String = "showRulerAble";
		public static const SHOW_BOUND_ABLE:String = "showBoundAble";
		public static const SHOW_FLIPX_ABLE:String = "showFlipXAble";
		public static const PATH_OF_IMPORT_SUITE:String = "pathOfImportSuite";
		public static const PATH_OF_IMPORT_COCOS:String = "pathOfImportCocos";
		public static const PATH_OF_EXPORT_COCOS:String = "pathOfExportCocos";
		
		public function UserHabits(userName:String)
		{
			super(userName + "/habits");
		}
		
		public function get editBgColor():int
		{
			return optValue(EDIT_BGCOLOR, 0x0);
		}
		public function set editBgColor(i:int):void
		{
			put(EDIT_BGCOLOR, i);
		}
		
		public function get showRulerAble():Boolean
		{
			return optValue(SHOW_RULER_ABLE, true);
		}
		public function set showRulerAble(b:Boolean):void
		{
			put(SHOW_RULER_ABLE, b);
		}
		
		public function get showBoundAble():Boolean
		{
			return optValue(SHOW_BOUND_ABLE, true);
		}
		public function set showBoundAble(b:Boolean):void
		{
			put(SHOW_BOUND_ABLE, b);
		}
		
		public function get showFlipXAble():Boolean
		{
			return optValue(SHOW_FLIPX_ABLE, false);
		}
		public function set showFlipXAble(b:Boolean):void
		{
			put(SHOW_FLIPX_ABLE, b);
		}
		
		public function get pathOfImportSuite():String
		{
			return optValue(PATH_OF_IMPORT_SUITE, null);
		}
		public function set pathOfImportSuite(s:String):void
		{
			put(PATH_OF_IMPORT_SUITE, s);
		}
		
		public function get pathOfImportCocos():String
		{
			return optValue(PATH_OF_IMPORT_COCOS, null);
		}
		public function set pathOfImportCocos(s:String):void
		{
			put(PATH_OF_IMPORT_COCOS, s);
		}
		
		public function get pathOfExportCocos():String
		{
			return optValue(PATH_OF_EXPORT_COCOS, null);
		}
		public function set pathOfExportCocos(s:String):void
		{
			put(PATH_OF_EXPORT_COCOS, s);
		}
	}
}