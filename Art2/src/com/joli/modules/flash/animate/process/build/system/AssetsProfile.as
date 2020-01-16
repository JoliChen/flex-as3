package com.joli.modules.flash.animate.process.build.system
{
	import com.joli.extension.drawswf.animate.struct.AnimateData;
	import com.jonlin.utils.FileUtil;
	import com.jonlin.utils.IOUtil;
	import com.joli.modules.flash.animate.process.build.AnimateAssets;
	
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * 动画概要说明
	 * @author Joli
	 * @date 2019-3-29 下午6:47:25
	 */
	internal class AssetsProfile
	{
		private static const nl:String = "\r\n";
		private var _rootDir:File;
		
		public function AssetsProfile(rootDir:File)
		{
			_rootDir = rootDir;
			if (!rootDir.exists) {
				rootDir.createDirectory();
			}
		}
		
		public function save(animateSet:Vector.<AnimateData>, assetsInfo:AnimateAssets, sheetNameMap:SheetNameMap):void {
			saveNameMap(assetsInfo, sheetNameMap);
			saveSheetShare(assetsInfo, sheetNameMap);
			saveAnimateAssets(animateSet, assetsInfo, sheetNameMap);
		}
		
		private function saveNameMap(assetsInfo:AnimateAssets, sheetNameMap:SheetNameMap):void {
			var buff:ByteArray = new ByteArray();
			buff.writeUTFBytes("------------------ sheet name mapping ------------------" + nl);
			var sheetSet:Vector.<uint> = assetsInfo.sheetSet.concat();//排序不影响原数组
			sheetSet.sort(Array.NUMERIC|Array.DESCENDING);
			for (var i:int=sheetSet.length-1, sheetId:uint; i>-1; --i) {
				sheetId = sheetSet[i];
				buff.writeUTFBytes(sheetId + ":\t" + sheetNameMap.id2name(sheetId) + nl);
			}
			
			buff.writeUTFBytes(nl + nl);
			buff.writeUTFBytes("------------------ group name mapping ------------------" + nl);
			var keys:Array, groupId:uint, sb:String, j:int;
			keys = assetsInfo.groupMap.keys();
			keys.sort(Array.NUMERIC|Array.DESCENDING);
			for (i=keys.length-1; i>-1; --i) {
				groupId  = keys[i];
				sheetSet = assetsInfo.groupMap.getValue(groupId);
				sb = "";
				for (j=sheetSet.length-1; j>-1; --j) {
					sb += sheetNameMap.id2name(sheetSet[j]) + ", ";
				}
				buff.writeUTFBytes(groupId + ":\t(" + sb.substr(0, sb.length-2) + ")" + nl);
			}
			IOUtil.writeFile(FileUtil.newFile("图集名称表.txt", _rootDir), buff);
		}
		
		private function saveSheetShare(assetsInfo:AnimateAssets, sheetNameMap:SheetNameMap):void {
			var buff:ByteArray = new ByteArray();
			var keys:Array, uintIds:Vector.<uint>, sheetId:uint, groupId:uint;
			keys = assetsInfo.sheetShareMap.keys();
			keys.sort(Array.NUMERIC|Array.DESCENDING);
			buff.writeUTFBytes("------------------ sheet share list ------------------" + nl);
			for (var i:int=keys.length-1; i>-1; --i) {
				sheetId = keys[i];
				uintIds = assetsInfo.sheetShareMap.getValue(sheetId);
				buff.writeUTFBytes(sheetId + ":\t(" + uintIds.join(", ") + ")" + nl);
			}
			
			buff.writeUTFBytes(nl + nl);
			buff.writeUTFBytes("------------------ group share list ------------------" + nl);
			keys = assetsInfo.groupMap.keys();
			keys.sort(Array.NUMERIC|Array.DESCENDING);
			for (i=keys.length-1; i>-1; --i) {
				groupId = keys[i];
				uintIds = assetsInfo.groupMap.getValue(groupId);
				uintIds = assetsInfo.sheetShareMap.getValue(uintIds[0]);
				buff.writeUTFBytes(groupId + ":\t(" + uintIds.join(", ") + ")" + nl);
			}
			IOUtil.writeFile(FileUtil.newFile("图集共享表.txt", _rootDir), buff);
		}
		
		private function saveAnimateAssets(animateSet:Vector.<AnimateData>, assetsInfo:AnimateAssets, sheetNameMap:SheetNameMap):void {
			var buff:ByteArray = new ByteArray();
			var animData:AnimateData, animIds:Array = [], animMap:Dictionary = new Dictionary();
			for (var i:int=animateSet.length-1, animId:uint; i>-1; --i) {
				animData = animateSet[i];
				animId = animData.animateId;
				animIds.push(animId);
				animMap[animId] = animData;
			}
			animIds.sort(Array.NUMERIC|Array.DESCENDING);
			var sheets:Vector.<uint>, groups:Vector.<uint>, groudId:uint, j:int, n:int, sb:String;
			for (i=animIds.length-1; i>-1; --i) {
				animId = animIds[i];
				animData = animMap[animId.toString()];
				buff.writeUTFBytes("----------------------------------" + nl);
				buff.writeUTFBytes("animate:" + animId + nl);
				sheets = animData.unpackSheets;
				if (sheets && sheets.length > 0) {
					sb = "";
					for (j=sheets.length-1; j>-1; --j) {
						sb += sheetNameMap.id2name(sheets[j]) + ", ";
					}
					buff.writeUTFBytes("sheets:(" + sb.substr(0, sb.length-2) + ")" + nl);
				}
				sheets = animData.sheetPackage;
				if (sheets && sheets.length > 0) {
					for (j=sheets.length-1; j>-1; --j) {
						groudId = sheets[j];
						groups = assetsInfo.groupMap.getValue(groudId);
						sb = "";
						for (n=groups.length-1; n>-1; --n) {
							sb += sheetNameMap.id2name(groups[n]) + ", ";
						}
						buff.writeUTFBytes("group" + (sheets.length-j) + ":(" + sb.substr(0, sb.length-2) + ")" + nl);
					}
				}
				buff.writeUTFBytes(nl);
			}
			IOUtil.writeFile(FileUtil.newFile("动画资源表.txt", _rootDir), buff);
		}
	}
}