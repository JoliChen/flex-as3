package com.joli.modules.flash.animate.process.build.system
{
	import com.joli.extension.drawswf.animate.struct.SheetData;
	import com.jonlin.core.IDispose;
	import com.jonlin.structure.TreeMap;
	import com.jonlin.utils.IOUtil;
	
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	/**
	 * 序列帧数据包
	 * @author Joli
	 * @date 2018-8-7 下午9:03:57
	 */
	internal class SheetPackage implements IDispose
	{
		/**
		 * 存储位置 
		 */		
		private var _diskPos:File;
		
		/**
		 * 数据包 
		 */		
		private var _package:TreeMap;
		
		public function SheetPackage(diskPos:File)
		{
			_diskPos = diskPos;
		}
		
		public function dispose():void
		{
			if (_package) {
				_package.clear();
				_package = null;
			}
			_diskPos = null;
		}
		
		public function load():void
		{
			_package = new TreeMap();
			const bytes:ByteArray = AnimateDisk.newByteArray();
			IOUtil.readFile(_diskPos, bytes);
			if (bytes.length > 0) {
				const count:uint = bytes.readUnsignedInt();
				for (var i:uint=0, sheetData:SheetData; i<count; ++i) {
					sheetData = new SheetData();
					sheetData.read(bytes);
					_package.setPairAt(i, sheetData.sheetId, sheetData);
				}
			}
		}
		
		public function save():void
		{
			const bytes:ByteArray = AnimateDisk.newByteArray();
			const count:uint = _package.length;
			bytes.writeUnsignedInt(count);
			for (var i:int=0, sheetData:SheetData; i<count; ++i) {
				sheetData = _package.getValueAt(i);
				sheetData.write(bytes);
			}
			IOUtil.writeFile(_diskPos, bytes);
		}
		
		/**
		 * 更新 
		 * @param newSheetMap
		 */		
		public function update(newSheetMap:TreeMap):void
		{
			for (var i:int=newSheetMap.length-1; i>-1; --i) {
				_package.setValue(newSheetMap.getKeyAt(i), newSheetMap.getValueAt(i));
			}
		}
		
		/**
		 * 过滤无用的序列帧数据
		 * @param usedSheetSet 全部使用序列帧ID集合
		 */		
		public function filter(usedSheetSet:Vector.<uint>):void
		{
			for (var i:int=_package.length-1, sheetId:uint; i>-1; --i) {
				sheetId = _package.getKeyAt(i);
				if (usedSheetSet.lastIndexOf(sheetId) == -1) {
					_package.delPos(i);
				}
			}
		}
		
		public function getSheetData(sheetId:uint):SheetData
		{
			return _package.getValue(sheetId);
		}
	}
}