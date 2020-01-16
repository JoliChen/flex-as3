package com.jonlin.utils
{
	/**
	 * 字串处理工具类
	 * @author Adiers
	 */	
	public class TextUtil
	{
		/**
		 * 格式化数字，在前边不足位补零
		 * 类似 7 => 07
		 * @param n 要格式化的数字。
		 * @param count 要显示几位。
		 * @return 
		 */		
		public static function formatNumberWithZero(n:Number, count:int):String
		{
			if ( String(n).length>=count )
				return String(n);
			
			var str:String = "";
			for ( var i:int=count; i>0; i-- )
			{
				str += "0";
			}
			str += n;
			return str.substr(str.length-count);
		}
		
		/**
		 * 将数字按千位格式化(按千位划分用逗号隔开)
		 */
		public static function toThousands(n:Number):String
		{
			var nStr:String = String(n);
			var arr:Array = nStr.split(".");
			//小数点前边
			var leftArr:Array = String(arr[0]).split("");
			var firstLeft:int = leftArr.length%3==0?3:leftArr.length%3;
			var leftStr:String = String(arr[0]).substr(0, firstLeft);
			var i:int;
			var len:int = leftArr.length;
			for ( i=firstLeft; i<len; i+=3 )
			{
				leftStr += ","+leftArr[i]+leftArr[i+1]+leftArr[i+2];
			}
			//小数点后边
			if ( arr.length>=2 )
			{
				var rightArr:Array = String(arr[1]).split("");
				var rightStr:String = "";
				len = rightArr.length;
				for ( i=0; i<len; i+=3 )
				{
					if ( i!=0 )
						rightStr += ",";
					rightStr += rightArr[i];
					if ( i+1<len )
						rightStr += rightArr[i+1];
					if ( i+2<len )
						rightStr += rightArr[i+2];
				}
				return leftStr+"."+rightStr;
			}
			return leftStr;
		}
		
		/**
		 * 用指定的字符替换#1,#2,#3...<br/>
		 * 用##代替#号
		 * @param str
		 * @param arg
		 * @return 
		 */		
		public static function replaceWidthPoundSign(input:String,...arg):String
		{
			if ( !input )
				return "";
			var arr:Array = input.split("#");
			var str:String = String(arr[0]);
			var matchArr:Array;
			var i:int;
			var len:int = arr.length;
			for ( i=1; i<len; i++ )
			{
				//如果#号后没有字符了，此#号不转义
				if ( i>=len )
				{
					str += "#";
					break;
				}
				//如果#号后是#号，转义为#
				if ( arr[i]=="" )
				{
					str += "#"+arr[i+1];
					i++;
					continue;
				}
				
				matchArr = String(arr[i]).match(/^(\d*)/);
				//#号后没有数字，此#号不转义
				if ( !matchArr )
				{
					str += "#"+arr[i];
					continue;
				}
				var numStr:String = String(matchArr[1]);
				while ( Number(numStr)>arg.length )
				{
					numStr = numStr.substr(0,numStr.length-1);
				}
				str += arg[Number(numStr)-1] + String(arr[i]).substr(numStr.length);
			}
			return str;
		}
		
		/**
		 * 删除字串里的HTML代码。
		 * @param str
		 * @return 
		 */		
		public static function removeHTML(str:String):String
		{
			return str.replace(/\<[^\>]{1,}\>/gi,"");
		}
		
		/**
		 * 设置文本为html文本。 
		 * @param str   要设置html的文本
		 * @param color 颜色
		 * @return 返回Html文本
		 */
		public static function setHtml(str:String , color:uint, url:String = ""):String
		{
			var htmlStr:String = url != "" ? "<a href='event:" + url + "'>" + str + "</a>" : str;			
			return "<font color='#"+color.toString(16)+"'>"+htmlStr+"</font>";
		}
		
		/**
		 * 去左右空格
		 * @param char 去除左右空格的字符串
		 * @return 返回去除后的字符串
		 */	
		public static function trim(char:String):String 
		{
			return rtrim(ltrim(char));
		}
		
		/**
		 * 去左空格
		 * @param char 去除左空格的字符串
		 * @return 返回去除后的字符串
		 */	
		public static function ltrim(char:String):String 
		{
			return char.replace(/^\s*/ , "");
		}
		
		/**
		 * 去右空格
		 * @param char 去除右空格的字符串
		 * @return 返回去除后的字符串
		 */	
		public static function rtrim(char:String):String 
		{
			return char.replace(/\s*$/ , "");
		}
		
		/**
		 * 哈希化的字符串
		 * @param char
		 * @return 
		 */		
		public static function hashBKDR(char:String):uint
		{
			const seed:uint = 131; // 31 131 1313 13131 131313 etc..
			var hash:uint = 0;
			for (var i:int=0, len:int=char.length; i<len; ++i) {
				hash = hash * seed + char.charCodeAt(i);
			}
			// return hash & 0x7FFFFFFF;
			return hash & uint.MAX_VALUE;
		}
	}
}