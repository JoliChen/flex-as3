package com.joli.modules.flash.animate.process.build
{
	import com.extenal.texturepacker.TPCommand;
	import com.joli.art2.console.ILogcat;
	import com.joli.modules.flash.animate.affairs.AnimateReq;
	import com.joli.modules.flash.animate.process.build.system.SpriteSheetPair;
	import com.jonlin.core.IDispose;
	import com.jonlin.shell.ShellSession;
	import com.jonlin.shell.events.ShellEvent;
	import com.jonlin.structure.TreeMap;
	import com.jonlin.utils.MathUtil;
	
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	/**
	 * 图集打包
	 * @author Joli
	 * @date 2018-8-10 下午4:49:57
	 */
	internal class AtlasPacker implements IDispose
	{
		private var _log:ILogcat;
		private var _output:AnimateOutput;
		private var _callbk:Function;
		
		private var _shell:ShellSession;
		private var _tpCmd:TPCommand;
		private var _autoPow2:AtlasAutoPow2;
		private var _tempPackDir:File;
		private var _sheetPair:SpriteSheetPair;
		
		private var _globalScale:Number;//全局缩放系数
		private var _sheetScaleMap:Dictionary;
		private var _groupScaleMap:Dictionary;
		private var _sheetErrorMap:TreeMap;
		private var _groupErrorMap:TreeMap;
		private var _sheetPackList:Vector.<uint>;
		private var _groupPackList:TreeMap;
		
		public function AtlasPacker(log:ILogcat, output:AnimateOutput)
		{
			_log = log;
			_output = output;
			_shell = new ShellSession();
			_tpCmd = new TPCommand();
			_autoPow2 = new AtlasAutoPow2();
			_sheetPair = new SpriteSheetPair();
		}
		
		public function dispose():void
		{
			if (_shell) {
				_shell.dispose();
				_shell = null;
			}
			if (_autoPow2) {
				_autoPow2.dispose();
				_autoPow2 = null;
			}
			if (_sheetPackList) {
				_sheetPackList.length = 0;
				_sheetPackList = null;
			}
			if (_groupPackList) {
				_groupPackList.clear();
				_groupPackList = null;
			}
			if (_sheetErrorMap) {
				_sheetErrorMap.clear();
				_sheetErrorMap = null;
			}
			if (_groupErrorMap) {
				_groupErrorMap.clear();
				_groupErrorMap = null;
			}
			_tpCmd = null;
			_log = null;
			_output = null;
			_callbk = null;
			_sheetPair = null;
			_tempPackDir = null;
			_sheetScaleMap = null;
			_groupScaleMap = null;
		}
		
		public function get sheetScaleMap():Dictionary
		{
			return _sheetScaleMap;
		}
		
		public function get groupScaleMap():Dictionary
		{
			return _groupScaleMap;
		}
				
		internal function setTexturePacker(request:AnimateReq, packDir:File):void
		{
			_tempPackDir = packDir;
			_globalScale = request.tp_scale;
			_autoPow2.autoPow2Limit = request.auto_pow2_limit;
			_tpCmd.executable = request.texturepacker;
			_tpCmd.maxSize = request.tp_maxsize;
			_tpCmd.scale = _globalScale;
			_tpCmd.premultiplyAlpha = request.tp_premultiplyAlpha;
		}
		
		internal function pack(sheetSet:Vector.<uint>, groupMap:TreeMap, callback:Function):void
		{
			_callbk = callback;
			_sheetPackList = sheetSet;
			_groupPackList = groupMap;
			_sheetErrorMap = new TreeMap();
			_groupErrorMap = new TreeMap();
			_sheetScaleMap = new Dictionary();
			_groupScaleMap = new Dictionary();
			
			_shell.addEventListener(ShellEvent.EXIT, onPackSheetDone);
			packNextSheet();
		}
		
		private function packNextSheet():void
		{	
			const nums:uint = _sheetPackList.length;
			if (nums < 1) {
				onPackSheetPhaseDone();
				return;
			}
			const sheetId:uint = _sheetPackList.pop();
			const sheetName:String = _output.getSheetName(sheetId);
			
			_log.debug("pack texture:{0} - {1}:{2}", nums, sheetId, sheetName);
			_output.onPackingSheet(sheetId, _tempPackDir, _sheetPair);
			
			_tpCmd.sourceDir = _tempPackDir.nativePath;
			_tpCmd.sheetPath = _sheetPair.image.nativePath;
			_tpCmd.dataPath = _sheetPair.plist.nativePath;
			_shell.execute(_tpCmd, [sheetId, sheetName]);
		}

		private function onPackSheetDone(event:ShellEvent):void
		{
			const errorCode:int = event.code;
			const sheetInfo:Array = event.data;
			const sheetId:uint = sheetInfo[0];
			if (0 != errorCode) {
				_sheetErrorMap.pushPair(sheetInfo, errorCode);
			}
			if (!_output.canShrinkPow2Sheet(sheetId)) {
				_sheetScaleMap[sheetId] = calcRecoveryScale();
				packNextSheet();
				return;
			}
			_autoPow2.shrink(_sheetPair.image, _sheetPair.plist, function(scale:Number):void {
				_sheetScaleMap[sheetId] = calcRecoveryScale(scale);
				packNextSheet();
			});
		}
		
		private function onPackSheetPhaseDone():void
		{
			_shell.removeEventListener(ShellEvent.EXIT, onPackSheetDone);
			_shell.addEventListener(ShellEvent.EXIT, onPackGroupDone);
			packNextGroup();
		}
		
		private function packNextGroup():void
		{
			const nums:uint = _groupPackList.length;
			if (nums < 1) {
				onPackGroupPhaseDone();
				return;
			}
			const groupId:uint = _groupPackList.getKeyAt(0);
			const group:Vector.<uint> = _groupPackList.getValueAt(0);
			_groupPackList.delPos(0);
			
			_log.debug("pack group texture:{0} - {1}", nums, groupId);
			_output.onPackingGroup(groupId, group, _tempPackDir, _sheetPair);
			
			_tpCmd.sourceDir = _tempPackDir.nativePath;
			_tpCmd.sheetPath = _sheetPair.image.nativePath;
			_tpCmd.dataPath  = _sheetPair.plist.nativePath;
			_shell.execute(_tpCmd, [groupId, group]);
		}
		
		private function onPackGroupDone(event:ShellEvent):void
		{
			const errorCode:int = event.code;
			const groupInfo:Array = event.data;
			const groupId:uint = groupInfo[0]; 
			if (0 != errorCode) {
				_groupErrorMap.pushPair(groupInfo, errorCode);
			}
			if (!_output.canShrinkPow2Group(groupId)) {
				_groupScaleMap[groupId] = calcRecoveryScale();
				packNextGroup();
				return;
			}
			_autoPow2.shrink(_sheetPair.image, _sheetPair.plist, function(scale:Number):void {
				_groupScaleMap[groupId] = calcRecoveryScale(scale);
				packNextGroup();
			});
		}

		private function onPackGroupPhaseDone():void
		{
			_shell.removeEventListener(ShellEvent.EXIT, onPackGroupDone);
			if (null != _callbk) {
				_callbk();
			}
		}
		
		public function dumpErrors():void
		{
			var sheetInfo:Array, groupInfo:Array, errorCode:Number;
			for (var i:int=0, len:uint=_sheetErrorMap.length; i<len; ++i) {
				sheetInfo = _sheetErrorMap.getKeyAt(i);
				errorCode = _sheetErrorMap.getValueAt(i);
				_log.error("序列图集打包失败:{0} [err:{1}] {2}:{3}", i+1, errorCode, sheetInfo[0], sheetInfo[1]);
			}
			_sheetErrorMap.clear();
			
			for (i=0, len=_groupErrorMap.length; i<len; ++i) {
				groupInfo = _groupErrorMap.getKeyAt(i);
				errorCode = _groupErrorMap.getValueAt(i);
				_log.error("组合图集打包失败:{0} [err:{1}] {2}:[{3}]", i+1, errorCode, groupInfo[0], _output.getGroupItems(groupInfo[1]).join(","));
			}
			_groupErrorMap.clear();
		}

		/**
		 * 计算还原缩放系数
		 * @param shrink 自动缩回2的N次幂的等比缩放值
		 */
		private function calcRecoveryScale(shrink:Number=1.0):Number {
			return MathUtil.fixed(1 / (_globalScale * shrink), 6);
		}
	}
}