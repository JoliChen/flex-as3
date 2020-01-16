package com.jonlin.structure
{
	/**
	 * 位数组（最大支持32位）
	 * @author Joli
	 * @date 2019-5-21 下午3:06:33
	 */
	public class Bit32Array
	{
		private var _mask:uint;
		
		public function Bit32Array(mask:uint=0)
		{
			_mask = mask;
		}
		
		public function getMask():uint
		{
			return _mask;
		}
		
		public function set1(pos:int):void
		{
			_mask |= 1 << pos;
		}
		
		public function set0(pos:int):void
		{
			_mask &= ~(1 << pos);
		}
		
		public function not0(pos:int):Boolean
		{
			return (_mask & (1 << pos)) != 0;
		}
	}
}