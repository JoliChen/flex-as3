package com.joli.extension.drawswf.utils
{
	import com.joli.extension.drawswf.motion.MotionData;
	import com.joli.extension.drawswf.motion.MotionSlimData;

	/**
	 * 动画数据压缩工具
	 * @author Joli
	 * @date 2018-7-23 下午4:19:25
	 */
	public final class MotionCompressUtil
	{
		/**
		 * 压缩动画数据
		 * @param motionLine 动画数据序列
		 * @param motionKeys 动画键序列
		 * @param motionSlim 压缩后的状态信息
		 */			
		public static function slim(motionLine:Vector.<MotionData>, motionKeys:Vector.<int>, motionSlim:MotionSlimData):void
		{
			const changeIndexs:Array = [];
			var attrs1:Vector.<Number>, attrs2:Vector.<Number>;
			var i:int, j:int, len:int, birthd:Boolean = false;
			//遍历出变更的属性位置
			for (i=0, len=motionLine.length; i<len; ++i) {
				attrs1 = motionLine[i].attrValues;
				if (0 == attrs1.length) {
					continue;
				}
				if (!birthd) {
					const copy:Vector.<Number> = attrs1.concat();
					//trace("birth:", copy);
					for (var a:int=0, b:int=copy.length; a<b; ++a) {
						motionSlim.birthAttrs[a] = copy[a];
					}
					attrs1.length = 0;// clear birth attrs.
					attrs1 = copy;//转换引用关系
					birthd = true;
				}
				for (j=i+1; j<len; ++j) {
					attrs2 = motionLine[j].attrValues;
					if (0 == attrs2.length) {
						continue;
					}
					compareChanges(attrs1, attrs2, changeIndexs);
				}
			}
			changeIndexs.sort(Array.NUMERIC);
			//trace("changeIndexs", changeIndexs);
			for (i=0, len=changeIndexs.length; i<len; ++i) {
				motionSlim.changeKeys[i] = motionKeys[changeIndexs[i]];
			}
			removeUnusedValues(motionLine, changeIndexs);
		}
		
		private static function compareChanges(attrs1:Vector.<Number>, attrs2:Vector.<Number>, indexes:Array):void
		{
			for (var i:int=0, n:int=attrs1.length; i<n; ++i) {
				if (attrs1[i] != attrs2[i]) {
					if (-1 == indexes.lastIndexOf(i)) {
						indexes[indexes.length] = i;
					}
				}
			}
		}
		
		private static function removeUnusedValues(motionLine:Vector.<MotionData>, changeIndex:Array):void
		{
			// trace("indexes:", changeIndex);
			for (var i:int=0, len:int=motionLine.length, j:int, attrs:Vector.<Number>; i<len; ++i) {
				attrs = motionLine[i].attrValues;
				for (j=attrs.length-1; j>-1; --j) {
					if (-1 == changeIndex.lastIndexOf(j)) {
						attrs.splice(j, 1);
					}
				}
				// trace("values:", values);
			}
		}
	}
}