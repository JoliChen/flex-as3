package com.jonlin.utils
{

	/**
	 * 正则验证类
	 * @author Adiers
	 */
	final public class Regular
	{
		/**
		 * 检测字符串是否为Email地址 
		 * @param char 需要检测的Email字符串
		 * @return 返回是Email格式：true
		 */
		public static function isEmail(char:String):Boolean 
		{
			return / (\w | [_.\ - ]) + @((\w |- ) + \.) + \w{2 , 4}+/.exec(TextUtil.trim(char)) != null;
		}
		
		/**
		 * 检测字符串是否为Double型数据 
		 * @param char 需要检测的Double型数据字符串
		 * @return 返回是Double型：true
		 */
		public static function isDouble(char:String):Boolean 
		{
			return /^[-\+]?\d+(\.\d+)?$/.exec(TextUtil.trim(char)) != null;
		}
		
		/**
		 * 检测字符串是否为Integer型数据 
		 * @param char 需要检测的Integer型数据字符串
		 * @return 返回是Integer型：true
		 */
		public static function isInteger(char:String):Boolean 
		{
			return /^[-\+]?\d+$/.exec(TextUtil.trim(char)) != null;
		}
		
		/**
		 * 检测字符串是否为英文 
		 * @param char 需要检测的字符串
		 * @return 返回是英文：true
		 */
		public static function isEnglish(char:String):Boolean 
		{
			return /^[A-Za-z]+$/.exec(TextUtil.trim(char)) != null;
		}
		
		/**
		 * 检测字符串是否为中文 
		 * @param char 需要检测的字符串
		 * @return 返回是中文：true
		 */
		public static function isChinese(char:String):Boolean 
		{
			return /^[\u0391-\uFFE5]+$/.exec(TextUtil.trim(char)) != null;
		}
		
		/**
		 * 检测字符串是否为双字节 
		 * @param char 需要检测的字符串
		 * @return 返回是双字节：true
		 */
		public static function isDoubleChar(char:String):Boolean 
		{
			return /^[^\x00-\xff]+$/.exec(TextUtil.trim(char)) != null;
		}
		
		/**
		 * 检测字符串是否含有中文字符 
		 * @param char 需要检测的字符串
		 * @return 返回含有中文字符：true
		 */
		public static function hasChineseChar(char:String):Boolean 
		{
			return /[^\x00-\xff]/.exec(TextUtil.trim(char)) != null;
		}
		
		/**
		 * 检测字符串是否符合URL地址 
		 * @param char 需要检测的字符串
		 * @return 返回符合URL地址标准：true
		 */
		public static function isURL(char:String):Boolean 
		{
			return /^http:\/\/[A-Za-z0-9]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\':+!]*([^<>\"\"])*$/.exec(TextUtil.trim(char).toLowerCase()) != null;
		}
		
		/**
		 * 检测字符串是否为空白
		 * @param char 需要检测的字符串
		 * @return 返回是空白：true
		 */
		public static function isWhitespace(char:String):Boolean 
		{
			switch (char) 
			{
				case " ":
				case "\t":
				case "\r":
				case "\n":
				case "\f":
					return true;
				default :
					return false;
			}
		}
	}
}