package com.jonlin.utils
{
	public final class MathUtil
	{
		/**
		 * 精确浮点数
		 * @param value
		 * @param preceision 精确小数位数
		 * @return 
		 */		
		static public function fixed(value:Number, preceision:int):Number
		{
			var b:Number = Math.pow(10, preceision);
			return Math.round(value * b) / b;
		}
		
		/**
		 * 整数N的后一个2次幂数
		 */
		static public function nextPow2(n:int):int
		{
			n -= 1;
			n |= n >> 1;
			n |= n >> 2;
			n |= n >> 4;
			n |= n >> 8;
			n |= n >> 16;
			return n < 0 ? 1 : n + 1;
		}
		
		/**
		 * 整数N的前一个2次幂数
		 */
		static public function prevPow2(n:int):int
		{
			n = nextPow2(n);
			return n >> 1;
		}
		
		static public function hashUints(list:Vector.<uint>):uint
		{
			const seed:uint = 131; // 31 131 1313 13131 131313 etc..
			var hash:uint = 0;
			for (var i:int=0, len:int=list.length; i<len; ++i) {
				hash = hash * seed + list[i];
			}
			//return hash & 0x7FFFFFFF;//return hash & int.MAX_VALUE;
			return hash & 0xFFFFFFFF;//return hash & uint.MAX_VALUE;
		}
		
		static public function hashText(text:String):uint
		{
			const len:uint = text.length;
			const list:Vector.<uint> = new Vector.<uint>(len, true);
			for (var i:int=0; i<len; ++i) {
				list[i] = text.charCodeAt(i);
			}
			return hashUints(list);
		}
	}
}