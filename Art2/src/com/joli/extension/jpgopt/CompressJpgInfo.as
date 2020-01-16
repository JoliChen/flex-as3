package com.joli.extension.jpgopt
{
	import com.jonlin.utils.FileUtil;
	
	import flash.filesystem.File;
	
	/**
	 * JPG压缩参数
	 * @author Amumu
	 */
	public class CompressJpgInfo
	{
		/**默认品质最小值*/
		public static const QUALITY_MIN:int = 0;
		/**默认品质最大值*/
		public static const QUALITY_MAX:int = 75;
		/**[jpgoptimizer] 命令*/
		//private static const jpgoptim_cl:String = "--force --verbose --quiet --strip-all --overwrite --max=75 --dest %dstFolder% %srcPath%";
		private static const jpgoptim_cl:String = "--force --strip-all --quiet --overwrite --max=75 --dest %dstFolder% %srcPath%";
		
		/**[jpgoptim]命令行程序*/
		private var _jpgoptimExe:File;
		/**[jpgoptim]参数*/
		private var _jpgoptimOptions:Vector.<String>;
		
		/**源路径*/
		private var _srcPath:String;
		/**输出路径*/
		private var _dstPath:String;
		/**压缩品质最小值*/
		private var _qualityMin:int;
		/**压缩品质最大值*/
		private var _qualityMax:int;
		
		
		public function CompressJpgInfo()
		{
			var appFolder:File = File.applicationDirectory;
			_jpgoptimExe = FileUtil.newFile("res/cmd/jpegoptim_v1.4.4beta.exe", appFolder);
			
			var options:Array;
			options = jpgoptim_cl.split(" ");
			_jpgoptimOptions = Vector.<String>(options);
		}
		
		/**设置参数*/
		public function setArgs(srcPath:String, dstPath:String, qualityMax:int = QUALITY_MAX, qualityMin:int = QUALITY_MIN):void
		{
			_srcPath = srcPath;
			_dstPath = dstPath;
			_qualityMax = qualityMax;
			_qualityMin = qualityMin;
	
			var dstParent:File = FileUtil.newFile(dstPath).parent;
			
			_jpgoptimOptions[4] = "--max=" + qualityMax;
			_jpgoptimOptions[6] = dstParent.nativePath;
			_jpgoptimOptions[7] = srcPath;
		}
		
		/**[jpgoptim]命令行程序*/
		public function get jpgoptim():File
		{
			return _jpgoptimExe;
		}
		/**[jpgoptim] 命令*/
		public function get jpgoptimOptions():Vector.<String>
		{
			return _jpgoptimOptions;
		}
		
		/**源路径*/
		public function get srcPath():String
		{
			return _srcPath;
		}
		/**输出路径*/
		public function get dstPath():String
		{
			return _dstPath;
		}
		/**压缩品质最小值*/
		public function get qualityMin():int
		{
			return _qualityMin;
		}
		/**压缩品质最大值*/
		public function get qualityMax():int
		{
			return _qualityMax;
		}
	}
}