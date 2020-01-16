package com.joli.modules.flash.animate.process.build
{
	import com.joli.extension.drawswf.animate.struct.AnimateData;
	import com.joli.extension.drawswf.animate.struct.AnimateElement;
	import com.jonlin.structure.TreeMap;
	import com.jonlin.utils.MathUtil;
	
	/**
	 * 动画输出辅助
	 * @author Joli
	 * @date 2018-8-3 下午5:23:22
	 */
	internal class Helper
	{
		/**
		 * 计算可以打包的图集
		 * @param animateSet
		 * @return 
		 */		
		internal static function calcAssetsInfo(animateSet:Vector.<AnimateData>):AnimateAssets
		{
			const assetsInfo:AnimateAssets = new AnimateAssets();
			calcSharedSheet(animateSet, assetsInfo);
			
			const sheetShareMap:TreeMap = assetsInfo.sheetShareMap.copy();
			var sheetNums:uint = sheetShareMap.length;
			var sheetGroupSet:Vector.<uint>;
			var shareAniSet:Vector.<uint>;
			var sheetId:uint, isGroup:Boolean;
			const sheetGroupMap:TreeMap = new TreeMap();
			for (var i:int=0, j:int; i<sheetNums; ++i) {
				sheetId = sheetShareMap.getKeyAt(i);
				shareAniSet = sheetShareMap.getValueAt(i);
				isGroup = false;
				for (j=i+1; j<sheetNums; ++j) {
					if (!isEqualSet(sheetShareMap.getValueAt(j), shareAniSet)) {
						continue;
					}
					sheetGroupSet = sheetGroupMap.getValue(sheetId);
					if (!sheetGroupSet) {
						sheetGroupSet = new Vector.<uint>();
						sheetGroupMap.setValue(sheetId, sheetGroupSet);
					}
					sheetGroupSet.push(sheetShareMap.getKeyAt(j));
					sheetShareMap.delPos(j--);
					sheetNums--;
					isGroup = true;
				}
				if (isGroup) {
					sheetShareMap.delPos(i--);
					sheetNums--;
				}
			}
			
			// 剩下没有组合的就是共享的序列帧
			for (i=0; i<sheetNums; ++i) {
				assetsInfo.sheetSet[i] = sheetShareMap.getKeyAt(i);
			}
			// trace("sheets:", "  (", assetsInfo.sheetSet.join(",") , ")");
			
			// 将前面计算的组合扁平化
			var group:Vector.<uint>, groupId:uint, gsize:uint;
			sheetNums = sheetGroupMap.length;
			for (i=0; i<sheetNums; ++i) {
				sheetGroupSet = sheetGroupMap.getValueAt(i);
				gsize = sheetGroupSet.length;
				group = new Vector.<uint>(gsize + 1, true);
				for (j=0; j<gsize; ++j) {
					group[j] = sheetGroupSet[j];
				}
				group[j] = sheetGroupMap.getKeyAt(i);
				group.sort(Array.NUMERIC); // 从小到大排序
				groupId = MathUtil.hashUints(group);
				if (0 == groupId) {
					throw new Error("group hash zero");
				}
				if (assetsInfo.groupMap.has(groupId)) {
					throw new Error("group hash duplicate");
				}
				// trace("group:", groupId, "  (", group.join(",") , ")");
				assetsInfo.groupMap.setPairAt(i, groupId, group);
			}
			return assetsInfo;
		}
		
		/**
		 * 计算序列帧被共用的信息 
		 * @param allAnimates
		 * @param assetsInfo
		 * @return 
		 */			
		private static function calcSharedSheet(animateSet:Vector.<AnimateData>, assetsInfo:AnimateAssets):void
		{
			const sheetShareMap:TreeMap = assetsInfo.sheetShareMap;
			const animateNums:uint = animateSet.length;
			var animateData:AnimateData;
			var aniSheetSet:Vector.<uint>;
			var shareAniSet:Vector.<uint>;
			var animateId:uint, sheetId:uint;
			for (var i:int=0, j:int; i<animateNums; ++i) {
				animateData = animateSet[i];
				aniSheetSet = calcAnimateSheets(animateData);
				animateId = animateData.animateId;
				assetsInfo.animateUseSheetMap[animateId] = aniSheetSet;//记录每个动画所使用的图集
				for (j=aniSheetSet.length-1; j>-1; --j) {
					sheetId = aniSheetSet[j];
					shareAniSet = sheetShareMap.getValue(sheetId);
					if (!shareAniSet) {
						shareAniSet = new Vector.<uint>();
						sheetShareMap.setValue(sheetId, shareAniSet);
					}
					shareAniSet.push(animateId);
				}
			}
		}
		
		/**
		 * 计算动画所使用的序列帧集合
		 * @param animateData
		 * @param sheetSet
		 */		
		private static function calcAnimateSheets(animateData:AnimateData):Vector.<uint>
		{
			const sheetSet:Vector.<uint> = new Vector.<uint>();
			const elements:Vector.<AnimateElement> = animateData.elements;
			for (var i:int=elements.length-1, sheetId:uint; i>-1; --i) {
				sheetId = elements[i].sheetId;
				if (sheetSet.lastIndexOf(sheetId) == -1) {
					sheetSet.push(sheetId);
				}
			}
			return sheetSet;
		}
		
		/**
		 * 判断是否可以组合图集
		 * @param v1
		 * @param v2
		 * @return 
		 */		
		private static function isEqualSet(v1:Vector.<uint>, v2:Vector.<uint>):Boolean 
		{
			const len:uint = v1.length;
			if (len != v2.length) {
				return false;
			}
			for (var i:int=len-1; i>-1; --i) {
				if (v2.lastIndexOf(v1[i]) == -1) {
					return false;
				}
			}
			return true;
		}
		
		/**
		 * 检出变更动画数据
		 * @param animateData
		 * @param assetsInfo
		 * @return 
		 */		
		internal static function calcExportAnimateData(animateData:AnimateData, assetsInfo:AnimateAssets):Boolean
		{
			const sheetAtlas:Vector.<uint> = new Vector.<uint>();
			const usedSheets:Vector.<uint> = assetsInfo.animateUseSheetMap[animateData.animateId];
			var sheetId:uint;
			for (var i:int=usedSheets.length-1; i>-1; --i) {
				sheetId = usedSheets[i];
				if (assetsInfo.sheetSet.indexOf(sheetId) != -1) {
					usedSheets.removeAt(i);
					sheetAtlas.push(sheetId);
				}
			}
			
			var isChanged:Boolean = false;
			if (!isEqualSet(sheetAtlas, animateData.unpackSheets)) {
				isChanged = true;
				animateData.unpackSheets.length = 0;
				for (i=0; i<sheetAtlas.length; ++i) {
					animateData.unpackSheets[i] = sheetAtlas[i];
				}
			}
			
			if (!isEqualSet(usedSheets, animateData.sheetPackage)) {
				isChanged = true;
				animateData.sheetPackage.length = 0;
				if (usedSheets.length > 0) {
					var group:Vector.<uint>, match:Boolean, j:int;
					const allGroupMap:TreeMap = assetsInfo.groupMap;
					for (i=allGroupMap.length-1; i>-1; --i) {
						group = allGroupMap.getValueAt(i);
						match = false;
						for (j=usedSheets.length-1; j>-1; --j) {
							if (group.indexOf(usedSheets[j]) != -1) {
								usedSheets.removeAt(j);
								match = true;
							}
						}
						if (match) {
							animateData.sheetPackage.push(allGroupMap.getKeyAt(i));
						}
					}
					if (usedSheets.length > 0) {
						throw new Error("miss animate sheet group:(" + usedSheets.join(",") + ")");
					}
				}
			}
			return isChanged;
		}
		
		/**
		 * 检出需要输出的序列帧粒子图集
		 * @param newMap
		 * @param allAtlas
		 * @return 
		 */		
	 	internal static function calcExportSheetAtlas(newMap:TreeMap, allAtlas:Vector.<uint>):Vector.<uint>
		{
			const outputSheetSet:Vector.<uint> = new Vector.<uint>();
			for (var i:int=newMap.length-1, sheetId:uint; i>-1; --i) {
				sheetId = newMap.getKeyAt(i);
				if (allAtlas.lastIndexOf(sheetId) != -1) {
					outputSheetSet[outputSheetSet.length] = sheetId;
					newMap.delPos(i); // 已经标记为粒子资源输出
				}
			}
			return outputSheetSet;
		}
		
		/**
		 * 检出需要输出的序列帧组合图集
		 * @param newMap
		 * @param allGroup
		 * @return 
		 */		
		internal static function calcExportSheetGroup(newMap:TreeMap, allGroup:TreeMap):TreeMap
		{
			const outputGroupMap:TreeMap = new TreeMap();
			var group:Vector.<uint>, j:int, i:int = allGroup.length-1;
			for (; i>-1; --i) {
				group = allGroup.getValueAt(i);
				for (j=group.length-1; j>-1; --j) {
					if (newMap.has(group[j])) {
						outputGroupMap.setValue(allGroup.getKeyAt(i), group);
						break;
					}
				}
			}
			return outputGroupMap;
		}
	}
}