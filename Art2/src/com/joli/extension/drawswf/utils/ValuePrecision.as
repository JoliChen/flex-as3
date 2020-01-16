package com.joli.extension.drawswf.utils
{
	import com.jonlin.utils.MathUtil;

	/**
	 * 数字精确
	 * @author Joli
	 * @date 2018-7-24 下午3:46:38
	 */
	public class ValuePrecision
	{
		/**
		 * 浮点数精确位数 
		 */		
		private var _preceision:uint;
		
		public function ValuePrecision(preceision:uint=6)
		{
			_preceision = preceision;
		}
		
		/**
		 * 获取精确后浮点数
		 * @param value
		 * @return 
		 */		
		[inline]
		protected final function fixed(value:Number):Number
		{
			return MathUtil.fixed(value, _preceision);
		}
	}
}