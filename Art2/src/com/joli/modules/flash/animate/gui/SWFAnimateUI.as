package com.joli.modules.flash.animate.gui
{
	import com.joli.art2.features.IModuleGUI;
	import com.jonlin.utils.FileUtil;
	import com.jonlin.cross.Platform;
	import com.jonlin.utils.TextUtil;
	import com.joli.modules.flash.animate.SWFAnimateModule;
	import com.joli.modules.flash.animate.affairs.AnimateDao;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	
	/**
	 * SWF动画导出操作UI
	 * @author Joli
	 */
	public class SWFAnimateUI extends SWFAnimateUIX implements IModuleGUI
	{
		private const SEP:String = "\n--------------------------\n";
		private var _mod:SWFAnimateModule;
		private var _dao:AnimateDao;
		
		public function SWFAnimateUI(mod:SWFAnimateModule, dao:AnimateDao)
		{
			_mod = mod;
			_dao = dao;
			addEventListener(FlexEvent.CREATION_COMPLETE, onLoaded, false, 0, true);
			super();
		}
		
		public function dispose():void
		{
			_mod = null;
			_dao = null;
		}
		
		private function onLoaded(event:FlexEvent):void
		{
			srcText.text = _dao.src_files.join(SEP);
			destDirText.text = _dao.dest_dir;
			makeDirText.text = _dao.make_dir;
			execTPText.text  = _dao.texturepacker;
			execTPMaxSizeText.text = _dao.tp_maxsize.toString();
			execTPScaleText.text = _dao.tp_scale.toString();
			selPremultiplyAlpha.selected = _dao.tp_premultiplyAlpha;
			selSlimImages.selected = _dao.slimImages;
			selPrintProfile.selected = _dao.print_profile;
			selPrintParseWarn.selected = _dao.print_mc_warns;
			selAnimateFormat.selectedValue = _dao.animate_format;
			selSWFOutContent.selectedValue = _dao.animate_source;
			animateSetText.text = _dao.animate_id_set;
			pow2limitText.text = _dao.auto_pow2_limit.toString();
			
			if (Platform.isMacOSX()) {
				execTPText.editable = true;
			}
		}
				
		override protected function clickHandler(event:MouseEvent):void
		{
			switch(event.currentTarget)
			{
				case selSrcButton:
					selectSrcFiles();
					break;
				case selDestButton:
					selectDestDir();
					break;
				case selMakeButton:
					selectMakeDir();
					break;
				case selTPButton:
					selectTexturepacker();
					break;
				case exportButton:
					exportAnimate();
					break;
			}
		}
		
		private function selectSrcFiles():void
		{
			FileUtil.openMultiFile(function(files:Array):void {
				if (!files || 0 == files.length) {
					return;
				}
				var paths:Array = [];
				for (var i:int=0, len:int=files.length; i<len; ++i) {
					var file:File = files[i];
					paths.push(file.nativePath);
				} 
				srcText.text = paths.join(SEP);
			}, "选择SWF文件", new FileFilter("SWF文件", "*.swf"),  _dao.src_root);
		}
		
		private function selectDestDir():void
		{
			FileUtil.selectDir(function(dir:File):void {
				destDirText.text = dir.nativePath;
			}, "选择动画输出目录", _dao.dest_dir);
		}
		
		private function selectMakeDir():void
		{
			FileUtil.selectDir(function(dir:File):void {
				makeDirText.text = dir.nativePath;
			}, "选择动画构建目录", _dao.make_dir);
		}
		
		private function selectTexturepacker():void
		{
			var filter:FileFilter = null;
			if (Platform.isMacOSX()) {
				filter = new FileFilter("TexturePacker命令行", "*.exe");
			} else {
				filter = new FileFilter("TexturePacker命令行", "TexturePacker.exe");
			}
			FileUtil.openFile(function(file:File):void {
				execTPText.text = file.nativePath;
			}, "选择TexturePacker命令行程序", filter, _dao.texturepacker);
		}
		
		private function exportAnimate():void
		{
			const src_paths:String = TextUtil.trim(srcText.text);
			if (0 == src_paths.length) {
				Alert.show("请选择要导出的SWF文件");
				return;
			}
			const dest_dir:String = TextUtil.trim(destDirText.text);
			if (0 == dest_dir.length) {
				Alert.show("请选择动画输出目录");
				return;
			}
			const make_dir:String = TextUtil.trim(makeDirText.text);
			if (0 == make_dir.length) {
				Alert.show("请选择动画构建目录");
				return;
			}
			const texturepacker:String = TextUtil.trim(execTPText.text);
			if (0 == texturepacker.length) {
				Alert.show("请选择TexturePacker命令行程序");
				return;
			}
			_dao.src_files = src_paths.split(SEP);
			_dao.dest_dir = dest_dir;
			_dao.make_dir = make_dir;
			_dao.texturepacker = texturepacker;
			_dao.tp_maxsize = parseInt(TextUtil.trim(execTPMaxSizeText.text));
			_dao.tp_scale = parseFloat(TextUtil.trim(execTPScaleText.text));
			_dao.tp_premultiplyAlpha = selPremultiplyAlpha.selected;
			_dao.slimImages = selSlimImages.selected;
			_dao.print_profile = selPrintProfile.selected;
			_dao.print_mc_warns = selPrintParseWarn.selected;
			_dao.animate_format = selAnimateFormat.selectedValue as String;
			_dao.animate_source = selSWFOutContent.selectedValue as String;
			_dao.animate_id_set = TextUtil.trim(animateSetText.text);
			_dao.auto_pow2_limit = parseFloat(TextUtil.trim(pow2limitText.text));
			_mod.resume();
		}
	}
}