package com.extenal.plist
{
	import com.extenal.plist.lib.Plist10;
	import com.jonlin.utils.FileUtil;
	import com.jonlin.utils.IOUtil;
	import com.jonlin.utils.TextUtil;
	
	import flash.filesystem.File;
	
	/**
	 * Local Plist
	 * @author Joli
	 * @date 2019-5-18 下午3:52:34
	 */
	public class LocalPlist extends Plist10
	{
		private var _file:File;
		
		public function LocalPlist(fp:*)
		{
			super();
			_file = FileUtil.asFile(fp, true);
			if (_file.exists) {
				this.parse(IOUtil.readString(_file));
			}
		}
		
		public function get file():File
		{
			return _file;
		}
		
		public function save():void
		{
			IOUtil.writeString(_file, xml.toXMLString());
		}

		public static function parseVec(s:String):Array
		{
			var parts:Array = s.replace(/\{|\}/ig, "").split(",");
			for (var i:int=parts.length-1; i>-1; --i) {
				parts[i] = parseFloat(TextUtil.trim(parts[i]));
			}
			return parts;
		}
	}
}