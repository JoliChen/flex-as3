package com.joli.extension.lua
{
	import com.jonlin.utils.FileUtil;
	
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import luaAlchemy.LuaAlchemy;

	/**
	 * 将LUA数据转化为AS3数据
	 */
	public final class Lua2AS
	{
		public static function serialize(lua:String):Object
		{
			return table2Object(lua.replace(/^(return\s+)/, ""));
		}
		
		public static function table2Object(table:String):Object
		{
			var luaAlckemy:LuaAlchemy = new LuaAlchemy();
			var bytes:ByteArray = FileUtil.readFile("script/lua/json/json.lua", File.applicationDirectory);
			var jsonLua:String = bytes.readMultiByte(bytes.length, "utf-8");
			var results:Array = luaAlckemy.doString(jsonLua);
			if(!results[0])
			{
				luaAlckemy.close();//关闭临时的lua解释器
				trace("执行json for lua 失败！");
				return null;
			}
			results = luaAlckemy.doString("return json.encode(" + table + ")");
			if(!results[0])
			{
				luaAlckemy.close();//关闭临时的lua解释器
				trace("lua 对象 json解析失败！");
				return null;
			}
			try
			{
				luaAlckemy.close();//关闭临时的lua解释器
				return JSON.parse(results[1]);
			}
			catch(e:Error)
			{
				trace("JSON解码异常", e.getStackTrace());
			}
			luaAlckemy.close();//关闭临时的lua解释器
			return null;
		}
	}
}