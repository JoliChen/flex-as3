package com.joli.modules.flash.animate.process.build
{
	import com.jonlin.structure.TreeMap;
	
	import flash.utils.Dictionary;
	
	/**
	 * 动画资源信息
	 * @author Joli
	 * @date 2018-8-7 下午2:29:04
	 */
	public class AnimateAssets
	{
		private var _sheetSet:Vector.<uint>
		private var _groupMap:TreeMap;
		private var _sheetShareMap:TreeMap;
		private var _animateUseSheetMap:Dictionary;
		
		public function AnimateAssets()
		{
			_sheetSet = new Vector.<uint>();
			_groupMap = new TreeMap();
			_sheetShareMap = new TreeMap();
			_animateUseSheetMap = new Dictionary();
		}
		
		/**
		 * 动画图集表 (动画独享的图集，不参与组合共享。)
		 * @return 
		 */		
		public function get sheetSet():Vector.<uint>
		{
			return _sheetSet;
		}
		
		/**
		 * 图集组合表
		 * @return 
		 */		
		public function get groupMap():TreeMap
		{
			return _groupMap;
		}
		
		/**
		 * 图集共享表
		 */
		public function get sheetShareMap():TreeMap
		{
			return _sheetShareMap;
		}
		
		/**
		 * 动画使用的图集记录
		 */		
		public function get animateUseSheetMap():Dictionary
		{
			return _animateUseSheetMap;
		}		
		
		/**
		 * 获取所有使用的图集
		 * @return 
		 */		
		public function getAllSheets():Vector.<uint>
		{
			const sheets:Vector.<uint> = new Vector.<uint>();
			var group:Vector.<uint>, i:int, j:int;
			for (i=_sheetSet.length-1; i>-1; --i) {
				sheets[sheets.length] = _sheetSet[i];
			}
			for (i=_groupMap.length-1; i>-1; --i) {
				group = _groupMap.getValueAt(i);
				for (j=group.length-1; j>-1; --j) {
					sheets[sheets.length] = group[j];
				}
			}
			return sheets;
		}
	}
}