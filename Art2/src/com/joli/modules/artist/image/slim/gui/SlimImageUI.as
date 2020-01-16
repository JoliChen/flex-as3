package com.joli.modules.artist.image.slim.gui
{
	import com.joli.art2.features.IModuleGUI;
	import com.jonlin.utils.FileUtil;
	import com.jonlin.utils.TextUtil;
	import com.joli.modules.artist.image.slim.SlimImageModule;
	import com.joli.modules.artist.image.slim.affairs.SlimImageDao;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	
	/**
	 * 图片压缩操作视图
	 * @author Joli
	 * @date 2018-8-30 下午2:08:30
	 */
	public class SlimImageUI extends SlimImageUIX implements IModuleGUI
	{
		private var _mod:SlimImageModule;
		private var _dao:SlimImageDao;
		
		public function SlimImageUI(mod:SlimImageModule, dao:SlimImageDao)
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
			srcText.text = _dao.src_dir;
			dstText.text = _dao.dst_dir;
			recursionBox.selected = _dao.recursion;
		}
		
		override protected function clickHandler(event:MouseEvent):void
		{
			switch(event.currentTarget)
			{
				case selSrcButton:
					selectSrcDir();
					break;
				case selDstButton:
					selectDstDir();
					break;
				case slimButton:
					slim();
					break;
			}
		}
		
		private function selectSrcDir():void
		{
			FileUtil.selectDir(function(dir:File):void {
				srcText.text = dir.nativePath;
			}, "选择图片目录", _dao.src_dir);
		}
		
		private function selectDstDir():void
		{
			FileUtil.selectDir(function(dir:File):void {
				dstText.text = dir.nativePath;
			}, "选择保存目录", _dao.dst_dir);
		}
		
		private function slim():void
		{
			const src_dir:String = TextUtil.trim(srcText.text);
			if (0 == src_dir.length) {
				Alert.show("请选择图片目录");
				return;
			}
			const dst_dir:String = TextUtil.trim(dstText.text);
			if (0 == dst_dir.length) {
				Alert.show("请选择保存目录");
				return;
			}
			_dao.src_dir = src_dir;
			_dao.dst_dir = dst_dir;
			_dao.recursion = recursionBox.selected;
			_mod.resume();
		}
	}
}