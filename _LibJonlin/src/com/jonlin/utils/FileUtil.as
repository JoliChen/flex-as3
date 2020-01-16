package com.jonlin.utils
{
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;

	/**
	 * 文件处理工具
	 * @author Joli
	 */
	final public class FileUtil
	{
		/**
		 * 创建文件对象
		 * @param path:String 路径，如：C:/resource/images/001.pmg。
		 * @param parentFp:* 父级目录文件
		 * @return 
		 */
		public static function newFile(path:String, parentFp:*=undefined):File
		{
			var file:File = asFile(parentFp, true);
			if (path && path.length > 0) {
				file = file.resolvePath(path);
			}
			return file;
		}
		
		/**
		 * 将FP参数转成File对象
		 * @param fp:* 可以是File对象，也可以是String路径。
		 * @param notnone:Boolean 不允许返回空对象
		 * @return
		 */
		public static function asFile(fp:*, notnone:Boolean=false):File
		{
			if (fp) {
				if (fp is File) {
					return fp;
				}
				if (fp is String) {
					return new File(fp);
				}
			}
			return notnone ? new File() : null;
		}
		
		/**
		 * 获取父级目录文件对象
		 */
		public static function getParent(fp:*):File
		{
			return asFile(fp).parent;
		}
		
		/**
		 * 创建父级目录文件对象
		 */
		public static function createParent(path:String):File
		{
			try {
				var parent:File = getParent(path);
				parent.createDirectory();
				return parent;
			} catch(error:Error) {
				trace(error);
			}
			return null;
		}
		
		/**
		 * 创建文件夹
		 */
		public static function mkdirs(path:String):File
		{
			try {
				var dir:File = new File(path);
				dir.createDirectory();
				return dir;
			} catch(error:Error) {
				trace(error);
			}
			return null;
		}
		
		/**
		 * 从文件对象中读取文件名 (不包括后缀名)
		 */
		public static function getFilename(fp:*):String
		{
			var file:File = asFile(fp);
			if (file.isDirectory) {
				return file.name;
			}
			var fn:String = file.name;
			return fn.substring(0, fn.lastIndexOf("."));
		}
		
		/**
		 * 判断路径对应的文件是否存在
		 */
		public static function exists(path:String):Boolean
		{
			return (new File(path)).exists;
		}
		
		/**
		 * 拼接路径
		 */
		public static function join(...parts):String
		{
			return parts.join(File.separator);
		}

		/**
		 * 拷贝文件
		 */
		public static function copy(srcFp:*, dstFp:*, overwrite:Boolean=true):Boolean
		{
			const src:File = asFile(srcFp);
			if (!src.exists) {
				return false;
			}
			const dst:File = asFile(dstFp);
			if (!overwrite && dst.exists) {
				return false;
			}
			try {
				src.copyTo(dst, overwrite);
				return true;
			} catch(error:Error) {
				trace(error);
			}
			return false;
		}
		
		/**
		 * 移动文件
		 */
		public static function move(srcFp:*, dstFp:*, overwrite:Boolean=true):Boolean
		{
			const src:File = asFile(srcFp);
			if (!src.exists) {
				return false;
			}
			const dst:File = asFile(dstFp);
			if (!overwrite && dst.exists) {
				return false;
			}
			try {
				src.moveTo(dst, overwrite);
				return true;
			} catch(error:Error) {
				trace(error);
			}
			return false;
		}
		
		/**
		 * 移动文件到文件夹下
		 */
		public static function moveToDir(srcFp:*, dirFp:*, overwrite:Boolean=true):Boolean
		{
			const src:File = asFile(srcFp);
			if (!src.exists) {
				return false;
			}
			const dst:File = newFile(src.name, dirFp);
			if (!overwrite && dst.exists) {
				return false;
			}
			try {
				src.moveTo(dst, overwrite);
				return true;
			} catch(error:Error) {
				trace(error);
			}
			return false;
		}
		
		/**
		 * 删除文件
		 * @param fp 
		 * @param recursive 是否删除文件夹下的所有内容
		 * @return true-成功, false-失败
		 */
		public static function remove(fp:*, recursive:Boolean=true):Boolean
		{
			const file:File = asFile(fp);
			if (!file.exists) {
				return true;
			}
			try {
				if (file.isDirectory) {
					file.deleteDirectory(recursive);
				} else {
					file.deleteFile();
				}
				return true;
			} catch(error:Error) {
				trace(error);
			}
			return false;
		}
		
//		/**
//		 * 删除所有空目录
//		 * @param parent:File 父级目录
//		 * @param print:Array 删除日志
//		 */
//		public static function deleteEmptyDirs(parent:File, print:Array=null):void
//		{
//			if (!parent.isDirectory) {
//				return;
//			}
//			const dicts:Array = parent.getDirectoryListing();
//			const len:uint = dicts.length;
//			if (0 == len) {
//				if (print) {
//					print[print.length] = parent.nativePath;
//				}
//				parent.deleteDirectory();
//				return;
//			}
//			// 删除子目录
//			for (var i:int=0, file:File; i<len; i++) {
//				file = dicts[i];
//				if (file.isDirectory) {
//					deleteEmptyDirs(file, print);
//				}
//			}
//			// 检查文件夹是否全部删除
//			if (parent.getDirectoryListing().length > 0) {
//				return;
//			}
//			if (print) {
//				print[print.length] = parent.nativePath;
//			}
//			parent.deleteDirectory();
//		}
		
		/**
		 * 清理文件夹
		 * @param fp
		 * @return true-成功, false-失败
		 */
		public static function clearDir(fp:*):Boolean
		{
			try {
				var dir:File = asFile(fp);
				if (dir.exists) {
					dir.deleteDirectory(true);
				}
				dir.createDirectory();
				return true;
			}  catch(error:Error) {
				trace(error);
			}
			return false;
		}
		
		/**
		 * 获取目录下文件列表
		 * @param fp 文件夹
		 * @param filters 文件类型筛选数组。如：[swf, png, jpg, ...]
		 * @param recursive 是否包含子目录
		 */
		public static function listFiles(fp:*, filters:Vector.<String>=null, recursive:Boolean=true):Vector.<File>
		{
			var files:Vector.<File> = new Vector.<File>();
			fillFiles(files, asFile(fp), filters, recursive);
			return files;
		}
		
		/**
		 * 遍历文件列表
		 * @param files 文件列表
		 * @param dirFile 文件夹
		 * @param filters 文件类型筛选数组。如：[swf, png, jpg, ...]
		 * @param recursive 是否包含子目录
		 */
		public static function fillFiles(files:Vector.<File>, dirFile:File, filters:Vector.<String>=null, recursive:Boolean=true):void
		{
			const childs:Array = dirFile.getDirectoryListing();
			for (var i:int=0, n:int=childs.length, f:File; i<n; ++i) {
				f = childs[i];
				if (recursive && f.isDirectory) {
					fillFiles(files, f, filters, true);
					continue;	
				}
				if (!filters || filters.indexOf(f.extension) != -1) {
					files[files.length] = f;
				}
			}
		}
		
		/**
		 * 获取目录下文件夹列表
		 * @param fp 文件夹
		 * @param recursive 是否包含子目录
		 */
		public static function listDirs(fp:*, recursive:Boolean=true):Vector.<File>
		{
			var dirs:Vector.<File> = new Vector.<File>();
			fillDirs(dirs, asFile(fp), recursive);
			return dirs;
		}
		
		/**
		 * 获取目录下子目录列表
		 * @param dirs 数组
		 * @param dirFile 文件夹
		 * @param recursive:Boolean 是否包含子目录
		 */
		public static function fillDirs(dirs:Vector.<File>, dirFile:File, recursive:Boolean=true):void
		{
			const childs:Array = dirFile.getDirectoryListing();
			for (var i:int=0, len:int=childs.length, f:File; i<len; i++) {
				f = childs[i];
				if (recursive && f.isDirectory) {
					fillDirs(dirs, f, true);
				}
			}
		}
		
		/**
		 * 显示一个目录选择器对话框，用户可从中选择一个目录。当用户选择该目录时，将调度 select 事件。select 事件的 target 属性是指向所选目录的 File 对象。 
		 * @param callback:Function	callback(dir:File)
		 * @param title:String 对话框标题
		 * @param fp:* 预期目标地址
		 */
		public static function selectDir(callback:Function, title:String, fp:*=undefined):void
		{
			var file:File = asFile(fp, true);
			file.addEventListener(Event.SELECT, function(event:Event):void {
				file.removeEventListener(Event.SELECT, arguments.callee);
				callback(event.target as File);
			});
			file.browseForDirectory(title);
		}
		
		/**
		 * 显示选择文件对话框
		 */
		public static function selectFile(callback:Function, filter:FileFilter=null, fp:*=undefined):void
		{
			var file:File = asFile(fp, true);
			file.addEventListener(Event.SELECT, function(event:Event):void {
				file.removeEventListener(Event.SELECT, arguments.callee);
				callback(event.target as File);
			});
			file.browse(filter ? [filter] : null);
		}
		
		/**
		 * 显示“保存文件”对话框，用户可从中选择一个文件目标。当用户选择该文件时，将调度 select 事件。select 事件的 target 属性是指向所选保存目标的 File 对象。
		 * @param callback:Function callback(file:File)
		 * @param title:String 对话框标题
		 * @param fp:* 预期目标地址
		 */
		public static function selectSaveFile(callback:Function, title:String, fp:*=undefined):void
		{
			var file:File = asFile(fp, true);
			file.addEventListener(Event.SELECT, function(event:Event):void {
				file.removeEventListener(Event.SELECT, arguments.callee);
				callback(event.target as File);
			});
			file.browseForSave(title);
		}
		
		/**
		 * 显示“打开文件”对话框，用户可从中选择要打开的文件。 当用户选择该文件时，将调度 select 事件。select 事件的 target 属性是指向所选文件的 File 对象。
		 * @param callback:Function callback(file:File)
		 * @param title:String 对话框标题
		 * @param filter:FileFilter 文件类型筛选器
		 * @param fp:* 预期目标地址
		 */
		public static function openFile(callback:Function, title:String, filter:FileFilter=null, fp:*=undefined):void
		{
			var file:File = asFile(fp, true);
			file.addEventListener(Event.SELECT, function(event:Event):void {
				file.removeEventListener(Event.SELECT, arguments.callee);
				callback(event.target as File);
			});
			file.browseForOpen(title, filter ? [filter] : null);
		}
		
		/**
		 * 显示“打开文件”对话框，用户可从中选择一个或多个要打开的文件。 
		 * @param callback:Function callback(files:Array)
		 * @param title:String 对话框标题
		 * @param filter:FileFilter 文件类型筛选器
		 * @param fp:* 预期目标地址
		 */
		public static function openMultiFile(callback:Function, title:String, filter:FileFilter=null, fp:*=undefined):void
		{
			var file:File = asFile(fp, true);
			file.addEventListener(FileListEvent.SELECT_MULTIPLE, function(event:FileListEvent):void {
				file.removeEventListener(FileListEvent.SELECT_MULTIPLE, arguments.callee);
				callback(event.files);
			});
			file.browseForOpenMultiple(title, filter ? [filter] : null);
		}
	}
}