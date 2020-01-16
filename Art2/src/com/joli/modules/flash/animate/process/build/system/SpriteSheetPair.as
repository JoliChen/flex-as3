package com.joli.modules.flash.animate.process.build.system
{
	import com.jonlin.utils.FileUtil;
	
	import flash.filesystem.File;
	
	/**
	 * 纹理文件对
	 * @author Joli
	 * @date 2018-8-10 下午5:52:58
	 */
	public class SpriteSheetPair
	{
		private var _image:File;
		private var _plist:File;
		
		public function SpriteSheetPair()
		{
		}
		
		public function setPair(sheetName:String, dir:File):void
		{
			_image = FileUtil.newFile(sheetName + AnimateDisk.textureFormat, dir);
			_plist = FileUtil.newFile(sheetName + AnimateDisk.texDataFormat, dir);
		}
		
		public function get exists():Boolean
		{
			return _image.exists && _plist.exists;
		}
		
		public function get image():File
		{
			return _image;
		}
		
		public function get plist():File
		{
			return _plist;
		}
	}
}