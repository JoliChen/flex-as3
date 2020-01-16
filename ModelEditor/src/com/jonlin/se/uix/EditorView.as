package com.jonlin.se.uix
{
	import com.adobe.utils.StringUtil;
	import com.jonlin.an.geom.AnVec2;
	import com.jonlin.io.events.StorageEvent;
	import com.jonlin.se.MEMain;
	import com.jonlin.se.io.CocosLoader;
	import com.jonlin.se.io.CocosWriter;
	import com.jonlin.se.io.SuiteLoader;
	import com.jonlin.se.support.EditConst;
	import com.jonlin.se.support.EditData;
	import com.jonlin.se.unit.EditAvatar;
	import com.jonlin.se.user.UserHabits;
	import com.jonlin.se.user.UserPrefer;
	import com.jonlin.utils.FileUtil;
	import com.jonlin.utils.TextUtil;
	import com.jonlin.utils.XMLUtil;
	
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.events.ResizeEvent;
	import mx.managers.PopUpManager;

	public class EditorView extends EditorViewUIX
	{
		private var _uHabits:UserHabits;
		private var _uPrefer:UserPrefer;
		
		private var _suiteLoader:SuiteLoader;
		private var _cocosLoader:CocosLoader;
		private var _cocosWriter:CocosWriter;
		
		private var _center:EditorNode;
		private var _avatar:EditAvatar;
		
		public function EditorView()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreate, false, 0, true);
			super();
		}
		
		private function onCreate(event:FlexEvent):void
		{
			_uHabits = MEMain.singleton.userHabits;
			_uPrefer = MEMain.singleton.userPrefer;
			_uHabits.addEventListener(StorageEvent.STORAGE_CHANGE, onChangeHabits, false, 0, true);
			_uPrefer.addEventListener(StorageEvent.STORAGE_CHANGE, onChangePrefer, false, 0, true);
			
			_center = new EditorNode();
			_avatar = _center.avatar;
			_avatar.setListeners(onAvatarFramesChange, onAvatarAnchorChange);
			seatEditNode();
			editArea.addElement(_center);
			editArea.addEventListener(ResizeEvent.RESIZE, onResizeEditArea, false, 0, true);
			
			editBgCP.selectedColor = _uHabits.editBgColor;
			editBgCP.addEventListener(ColorPickerEvent.CHANGE, onChangeBgColor, false, 0, true);

			tlText.addEventListener(FlexEvent.ENTER, onInputSegment, false, 0, true);
			fpsText.text = _uPrefer.fps.toString();
			fpsText.addEventListener(FlexEvent.ENTER, onInputFps, false, 0, true);
			
			anchorXText.text = _uPrefer.anchorX.toString();
			anchorXText.addEventListener(FlexEvent.ENTER, onInputAnchorX, false, 0, true);
			anchorYText.text = _uPrefer.anchorY.toString();
			anchorYText.addEventListener(FlexEvent.ENTER, onInputAnchorY, false, 0, true);
			
			playBtn.addEventListener(MouseEvent.CLICK, onClickCtrlBtn, false, 0, true);
			stopBtn.addEventListener(MouseEvent.CLICK, onClickCtrlBtn, false, 0, true);
			pauseBtn.addEventListener(MouseEvent.CLICK, onClickCtrlBtn, false, 0, true);
			
			menuBarModel.source[1].menuitem.@toggled[0] = _uHabits.showRulerAble;
			menuBarModel.source[1].menuitem.@toggled[1] = _uHabits.showBoundAble;
			menuBarModel.source[1].menuitem.@toggled[2] = _uHabits.showFlipXAble;
			menuBar.addEventListener(MenuEvent.ITEM_CLICK, onClickMenuItem, false, 0, true);
		}
		
		private function onAvatarFramesChange(currentFrame:int, totalFrames:int):void
		{
			frameNumsText.text = totalFrames.toString();
			frameStepText.text = currentFrame.toString();
		}
		
		private function onAvatarAnchorChange(anchor:AnVec2):void
		{
			anchorXText.text = anchor.x.toString();
			anchorYText.text = anchor.y.toString();
		}
		
		private function onResizeEditArea(event:ResizeEvent):void
		{
			seatEditNode();
		}
		
		private function onChangeBgColor(event:ColorPickerEvent):void
		{	
			_uHabits.editBgColor = event.color;
		}
		
		private function onInputFps(evnet:FlexEvent):void
		{
			_uPrefer.fps = parseInt(fpsText.text);
		}
		
		private function onInputSegment(event:FlexEvent):void
		{
			_avatar.updateFrames(StringUtil.trim(tlText.text));
		}
		
		private function onInputAnchorX(evnet:FlexEvent):void
		{
			_avatar.anchorX = Number(TextUtil.trim(anchorXText.text));
		}
		
		private function onInputAnchorY(evnet:FlexEvent):void
		{
			_avatar.anchorY = Number(TextUtil.trim(anchorYText.text));
		}
		
		private function onChangeHabits(event:StorageEvent):void
		{
			switch(event.filedKey)
			{
				case UserHabits.EDIT_BGCOLOR:
				case UserHabits.SHOW_RULER_ABLE: {
					drawEditorGuide();
					break;
				}
			}
		}
		
		private function onChangePrefer(event:StorageEvent):void
		{
			switch(event.filedKey)
			{
				case UserPrefer.SEAT_X:
				case UserPrefer.SEAT_Y:{
					seatEditNode();
					break;
				}
			}
		}
		
		private function onClickCtrlBtn(event:MouseEvent):void
		{
			this.setFocus();
			switch(event.currentTarget)
			{
				case playBtn: {
					_avatar.play();
					break;
				}
				case stopBtn: {
					_avatar.gotoAndStop(0);
					break;
				}
				case pauseBtn: {
					_avatar.pause();
					break;
				}
			}
		}
		
		private function onClickMenuItem(event:MenuEvent):void
		{
			var action:String = event.item.@data;
			switch(action)
			{
				case "importSuite": {
					FileUtil.selectDir(onImportSuite, "打开精灵序列图", _uHabits.pathOfImportSuite);
					break;
				}
				case "importCocos": {
					FileUtil.openFile(onImportCocos, "打开TP图集", EditConst.TEX_INFO_FILTER, _uHabits.pathOfImportCocos);
					break;
				}
				case "exportCocos": {
					if (_avatar.editData) {
						FileUtil.selectDir(onExportCocos, "保存TP图集", _uHabits.pathOfExportCocos);
					}
					break;
				}
				case "createWidget": {
					
				}
				case "ctrlRuler": {
					_uHabits.showRulerAble = XMLUtil.isYes(event.item.@toggled[0]);
					break;
				}
				case "ctrlBound": {
					_uHabits.showBoundAble = XMLUtil.isYes(event.item.@toggled[0]);
					break;
				}
				case "ctrlFlip": {
					_uHabits.showFlipXAble = XMLUtil.isYes(event.item.@toggled[0]);
					break;
				}
				case "ctrlTimeline": {
					_center.ctrlTimeline(XMLUtil.isYes(event.item.@toggled[0]));
					break;
				}
				case "openDefaultConfig": {
					openSettingDefDialog();
					break;
				}
				case "openTexturePacker": {
					openSettingTPDialog();
					break;
				}
				default: {
					trace("unspport menu action", action);
					break;
				}
			}
		}
		
		private function openSettingDefDialog():void
		{
			var dialog:SettingPreferDialog = new SettingPreferDialog();
			dialog.open(this, true);
			PopUpManager.centerPopUp(dialog);
		}
		
		private function openSettingTPDialog():void
		{
			var dialog:SettingTPDialog = new SettingTPDialog();
			dialog.open(this, true);
			PopUpManager.centerPopUp(dialog);
		}
		
		private function onImportSuite(dirFile:File):void
		{
			_uHabits.pathOfImportSuite = dirFile.nativePath;
			importText.text = _uHabits.pathOfImportSuite;
			if (!_suiteLoader) {
				_suiteLoader = new SuiteLoader();
			}
			_suiteLoader.load(dirFile, this.updateAvatarData);
		}
		
		private function onImportCocos(file:File):void
		{
			_uHabits.pathOfImportCocos = file.nativePath;
			importText.text = _uHabits.pathOfImportCocos;
			if (!_cocosLoader) {
				_cocosLoader = new CocosLoader();
			}
			_cocosLoader.load(file, this.updateAvatarData);
		}
		
		private function onExportCocos(dirFile:File):void
		{
			_uHabits.pathOfExportCocos = dirFile.nativePath;
			if (!_cocosWriter) {
				_cocosWriter = new CocosWriter();
			}
			
			var dialog:ProgressDialog = new ProgressDialog();
			dialog.open(this, true);
			PopUpManager.centerPopUp(dialog);
			
			_cocosWriter.publish(dirFile, _avatar.editData, function():void {
				trace("atlas write complete");
				dialog.close();
			});
		}
		
		private function seatEditNode():void
		{
			_center.x = editArea.width * _uPrefer.seatX;
			_center.y = editArea.height * (1 - _uPrefer.seatY);
			drawEditorGuide();
		}

		private function drawEditorGuide():void
		{	
			var pen:Graphics = editArea.graphics;
			pen.clear();
			pen.beginFill(_uHabits.editBgColor);
			pen.drawRoundRect(0, 0, editArea.width, editArea.height, 12);
			pen.endFill();
			if (_uHabits.showRulerAble) {
				pen.lineStyle(1, 0xFF0000);
				pen.moveTo(_center.x, 0);
				pen.lineTo(_center.x, editArea.height);
				pen.moveTo(0, _center.y);
				pen.lineTo(editArea.width, _center.y);
			}
		}

		private function updateAvatarData(data:EditData):void
		{
			if (data) {
				tlText.text = data.buildLineText();
				spriteWText.text = data.size.width.toString();
				spriteHText.text = data.size.height.toString();
				_avatar.updateEdit(data);
			} else {
				tlText.text = "";
				spriteWText.text = "0";
				spriteHText.text = "0";
				_avatar.clear();
			}
		}
	}
}