package com.extenal.texturepacker
{
	import com.jonlin.shell.IShellCommand;
	
	/**
	 * TexturePacker命令行参数
	 * @author Joli
	 * @date 2018-7-17 上午11:44:34
	 */
	public class TPCommand implements IShellCommand
	{
		private var _executable:String;
		
		private var _maxSize:int;
		private var _sizeConstraints:String;//尺寸约束
		private var _shapePadding:int;//小图间隙
		private var _borderPadding:int;//图集边框
		private var _scale:Number;
		private var _scaleMode:String;
		private var _trimMode:String;
		private var _opt:String;
		private var _format:String;
		private var _textureFormat:String;
		private var _enableRotation:Boolean;
		private var _premultiplyAlpha:Boolean;
		private var _sheet:String;
		private var _data:String;
		private var _source:String;
		
		private var _replace:String;
		private var _trimExt:Boolean;

		public function TPCommand()
		{
			_maxSize = 1024;
			_sizeConstraints = "AnySize";
			_shapePadding = 1;
			_borderPadding = 1;
			_scale = 1;
			_scaleMode = "Smooth";
			_trimMode = "Trim";
			_opt = "RGBA8888";
			_format = "cocos2d";
			_textureFormat = "png";
			_enableRotation = true;
			_premultiplyAlpha = false;
		}
		
		public function get executable():String
		{
			return _executable;
		}
		
		/**
		 --max-size 1024 
		 --scale 1 
		 --shape-padding 0 
		 --border-padding 0 
		 --size-constraints AnySize 
		 --scale-mode Smooth
		 --trim-mode Trim 
		 --opt RGBA8888 
		 --format cocos2d 
		 --texture-format png 
		 --sheet /Users/joli/Desktop/outputs/texturepacker/test.png 
		 --data /Users/joli/Desktop/outputs/texturepacker/test.plist 
		 --enable-rotation 
		 --premultiply-alpha 
		 /Users/joli/Desktop/outputs/texturepacker/src 
		 */
		public function get arguments():Vector.<String>
		{
			var args:Array = [
				"--max-size", _maxSize,
				"--size-constraints", _sizeConstraints,
				"--scale", _scale,
				"--scale-mode", _scaleMode,
				"--shape-padding", _shapePadding,
				"--border-padding", _borderPadding,
				"--trim-mode", _trimMode,
				"--opt", _opt,
				"--format", _format,
				"--texture-format", _textureFormat,
				"--data", _data,
				"--sheet", _sheet
			];
			if (_replace) {
				args.push("--replace");
				args.push(_replace);
			}
			if (_enableRotation) {
				args.push("--enable-rotation");
			}
			if (_premultiplyAlpha) {
				args.push("--premultiply-alpha");
			}
			if (_trimExt) {
				args.push("--trim-sprite-names");
			}
			args.push(_source);
			return Vector.<String>(args);
		}
		
		public function set executable(path:String):void
		{
			_executable = path;
		}
		
		public function set replace(s:String):void
		{
			_replace = s;
		}
		public function get replace():String
		{
			return _replace;
		}
		
		public function set trimExt(b:Boolean):void
		{
			_trimExt = b;
		}
		public function get trimExt():Boolean
		{
			return _trimExt;
		}

		public function set scale(s:Number):void
		{
			_scale = s;
		}
		public function get scale():Number
		{
			return _scale;
		}
		
		public function set maxSize(size:int):void
		{
			_maxSize = size;
		}
		public function get maxSize():int
		{
			return _maxSize;
		}
		
		public function set sourceDir(path:String):void
		{
			_source = path;
		}
		public function get sourceDir():String
		{
			return _source;
		}
		
		public function set dataPath(path:String):void
		{
			_data = path;
		}
		public function get dataPath():String
		{
			return _data;
		}
		
		public function set sheetPath(path:String):void
		{
			_sheet = path;
		}
		public function get sheetPath():String
		{
			return _sheet;
		}
		
		public function set premultiplyAlpha(allow:Boolean):void
		{
			_premultiplyAlpha = allow;
		}
		public function get premultiplyAlpha():Boolean
		{
			return _premultiplyAlpha;
		}
	}
}