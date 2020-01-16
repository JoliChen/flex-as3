package com.joli.extension.lua
{
	import com.jonlin.utils.Regular;

	/**
	 * 转化Lua工具
	 * @author Adiers
	 */
	public final class AS2Lua
	{
		/**
		 * 生成Lua脚本
		 * @param table:*					as3对象(Object、Array)
		 * @param format:Boolean	是否格式化
		 */
		public static function toLua(ins:*, format:Boolean = false):String
		{
			if(ins is Array)
			{
				return "return " + array2table(ins, 1, format);
			}
			return "return " + obj2table(ins, 1, format);
		}
		
		/**
		 * 对象转表
		 */
		public static function obj2table(obj:Object, nest:int = 1, format:Boolean = false):String
		{
			var nestIndent:String = format ? getNestIndent(nest) : "";
			var indent:String = format ? "\t" : "";
			var wrap:String = format ? "\n" : "";
			var body:String = "";
			for(var key:String in obj)
			{
				body += nestIndent + indent + (Regular.isDouble(key) ? "[" + key + "]" : key) + "=";
				body += getValString(obj[key], nest, format);
				body += "," + wrap;
			}
			body = body.replace(/(,\s{0,})$/, "");
			return "{" + wrap + body + wrap + nestIndent + "}";
		}
		
		/**
		 * 数组转表
		 */
		private static function array2table(array:Array, nest:int = 1, format:Boolean = false):String
		{
			var nestIndent:String = format ? getNestIndent(nest) : "";
			var indent:String = format ? "\t" : "";
			var wrap:String = format ? "\n" : "";
			var body:String = "";
			for(var i:int = 0; i < array.length; i++)
			{
				body += nestIndent + indent + getValString(array[i], nest, format);
				body += "," + wrap;
			}
			body = body.replace(/(,\s{0,})$/, "");
			return "{" + wrap + body + wrap + nestIndent + "}";
		}
		
		private static function getNestIndent(nest:int):String
		{
			var i:String = "";
			while(--nest)
			{
				i += "\t";
			}
			return i;
		}
		
		private static function getValString(val:*, nest:int, format:Boolean):String
		{
			if(val is Boolean)
			{
				return String(val);
			}
			if(val is String)
			{
				return "\"" + val + "\"";
			}
			if(val is Number)
			{
				if(val is uint || val is int)
				{
					return String(val);
				}
				if(isNaN(val))
				{
					return "0";
				}
				return String(val);
			}
			if(val is Array)
			{
				return array2table(val, nest + 1, format);
			}
			if(val is Object)
			{
				return obj2table(val, nest + 1, format);
			}
			if(val == null)
			{
				return "nil";
			}
			return "";
		}
	}
}