package com.joli.extension.pngqunt
{
	import com.jonlin.utils.FileUtil;
	
	import flash.filesystem.File;

	/**
	 * PNG压缩参数
	 * @author Amumu
	 */
	public class CompressPngInfo
	{
		/**默认品质最小值*/
		public static const QUALITY_MIN:int = 0;
		/**默认品质最大值*/
		public static const QUALITY_MAX:int = 79;
		
		/**[pngquant] 命令*/
		//private static const pngquant_cl:String = "--force --verbose --speed=1 --quality=0-79 --output %dstPath% %srcPath%";
		private static const pngquant_cl:String = "--force --speed=1 --quality=0-79 --output %dstPath% %srcPath%";
		/**[pngoptimizer] 命令*/
		private static const pngoptim_cl:String = "-file:srcPath";
		
		/**[pngquant]命令行程序*/
		private var _pngquantExe:File;
		/**[pngoptimizer]命令行程序*/
		private var _pngoptimExe:File;
		/**[pngquant]参数*/
		private var _pngquantOptions:Vector.<String>;
		/**[pngoptimizer]参数*/
		private var _pngoptimOptions:Vector.<String>;
		
		/**源路径*/
		private var _srcPath:String;
		/**输出路径*/
		private var _dstPath:String;
		/**压缩品质最小值*/
		private var _qualityMin:int;
		/**压缩品质最大值*/
		private var _qualityMax:int;
		
		
		public function CompressPngInfo()
		{
			var appFolder:File = File.applicationDirectory;
			_pngquantExe = FileUtil.newFile("res/cmd/pngquant_v2.7.0.exe", appFolder);
			_pngoptimExe = FileUtil.newFile("res/cmd/PngOptimizerCL_v2.4.exe", appFolder);
			
			var options:Array;
			options = pngquant_cl.split(" ");
			_pngquantOptions = Vector.<String>(options);
			options = pngoptim_cl.split(" ");
			_pngoptimOptions = Vector.<String>(options);
		}
		
		/**设置参数*/
		public function setArgs(srcPath:String, dstPath:String, qualityMax:int = QUALITY_MAX, qualityMin:int = QUALITY_MIN):void
		{
			_srcPath = srcPath;
			_dstPath = dstPath;
			_qualityMax = qualityMax;
			_qualityMin = qualityMin;
			
			_pngquantOptions[2] = "--quality=" + qualityMin + "-" + qualityMax;
			_pngquantOptions[4] = dstPath;
			_pngquantOptions[5] = srcPath;
			
			_pngoptimOptions = new Vector.<String>();
			_pngoptimOptions[0] = '-file:"' + dstPath + '"';
		}
		
		/**[pngquant]命令行程序*/
		public function get pngquant():File
		{
			return _pngquantExe;
		}
		/**[pngoptimizer]命令行程序*/
		public function get pngoptim():File
		{
			return _pngoptimExe;
		}
		/**[pngquant] 命令*/
		public function get pngquantOptions():Vector.<String>
		{
			return _pngquantOptions;
		}
		/**[pngoptimizer]命令*/
		public function get pngoptimOptions():Vector.<String>
		{
			return _pngoptimOptions;
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