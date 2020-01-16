package com.jonlin.se.uix
{
	import com.adobe.utils.StringUtil;
	import com.jonlin.cross.Platform;
	import com.jonlin.se.MEMain;
	import com.jonlin.se.user.UserTPConf;
	import com.jonlin.utils.FileUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.events.FlexEvent;

	/**
	 * TexturePacker 设置框
	 * @author jonlin
	 * @date 2019-8-7 下午2:55:24
	 */
	public class SettingTPDialog extends SettingTPUIX
	{
		private var _tpConf:UserTPConf;
		
		public function SettingTPDialog()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreate, false, 0, true);
			super();
		}
		
		private function onCreate(event:FlexEvent):void
		{
			_tpConf = MEMain.singleton.userTPConf;
			tpText.text = _tpConf.texpacker;
			trimNameText.selected = _tpConf.trimNameExt;
			maxsizeText.text = _tpConf.maxSize.toString();
			scaleText.text = _tpConf.scale.toString();
			
			tpSelectBtn.addEventListener(MouseEvent.CLICK, onClickTPSelectBtn, false, 0, true);
			trimNameText.addEventListener(Event.CHANGE, onSelectChange);
			
			maxsizeText.addEventListener(FlexEvent.ENTER, onPressEnter, false, 0, true);
			scaleText.addEventListener(FlexEvent.ENTER, onPressEnter, false, 0, true);
		}
		
		private function onClickTPSelectBtn(event:MouseEvent):void
		{
			var filter:FileFilter = null;
			if (!Platform.isMacOSX()) {
				filter = new FileFilter("TexturePacker命令行", "TexturePacker.exe");
			}
			FileUtil.openFile(function(file:File):void {
				var path:String = file.nativePath;
				if (Platform.isMacOSX() && StringUtil.endsWith(path, ".app")) {
					path += "/Contents/MacOS/TexturePacker";
				}
				tpText.text = path;
				_tpConf.texpacker = path;
			}, "选择TexturePacker命令行程序", filter, _tpConf.texpacker);
		}
		
		private function onSelectChange(event:Event):void
		{
			_tpConf.trimNameExt = trimNameText.selected;
		}
		
		private function onPressEnter(event:FlexEvent):void
		{
			switch(event.currentTarget)
			{
				case maxsizeText: {
					_tpConf.maxSize = parseInt(maxsizeText.text);
					break;
				}
				case scaleText: {
					_tpConf.scale = parseFloat(scaleText.text);
					break;
				}
			}
		}
	}
}