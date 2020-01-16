package com.joli.modules.flash.animate.process.build.system
{
	import com.jonlin.core.IDispose;
	import com.jonlin.utils.IOUtil;
	import com.jonlin.utils.MathUtil;
	
	import flash.filesystem.File;
	
	/**
	 * 序列帧索引配置
	 * @author Joli
	 * @date 2018-8-1 下午9:16:40
	 */
	internal class SheetNameMap implements IDispose
	{
		/**
		 * 存储位置 
		 */		
		private var _diskPos:File;
		
		/**
		 * 配置内容
		 */		
		private var _content:Object;
		
		public function SheetNameMap(diskPos:File)
		{
			_diskPos = diskPos;
			load();
		}
		
		public function dispose():void
		{
			_diskPos = null;
			_content = null;
		}
		
		/**
		 * 载入
		 */		
		public final function load():void
		{
			const text:String = IOUtil.readString(_diskPos);
			if (text) {
				_content = JSON.parse(text);
			} else {
				_content = {};
			}
		}
		
		/**
		 * 保存
		 */		
		public final function save():void
		{
			const text:String = JSON.stringify(_content, null, 4);
			IOUtil.writeString(_diskPos, text);
		}
		
		/**
		 * 索引
		 * @param sheetClassName 序列帧链接类名
		 * @return 序列帧ID
		 */		
		public final function index(sheetClassName:String):uint 
		{
			const i:uint = MathUtil.hashText(sheetClassName);
			if (_content[i] == sheetClassName) {
				return i;
			}
			return inset(i, sheetClassName);//插入新元素
		}
		
		/**
		 * 通过序列帧ID查找序列帧名称
		 * @param sheetId 索引
		 * @return 
		 */		
		public final function id2name(sheetId:uint):String
		{
			return _content[sheetId];
		}
		
		/**
		 * 插入新元素
		 * @param sheetId 索引
		 * @param sheetClassName 序列帧链接类名
		 */
		private final function inset(sheetId:uint, sheetClassName:String):uint
		{
			if (sheetId in _content) {
				trace("资源名称hash冲突:", sheetClassName, sheetId);						
				do {
					sheetId++;
				} while(sheetId in _content);
			}
			_content[sheetId] = sheetClassName;
			return sheetId;
		}
	}
}