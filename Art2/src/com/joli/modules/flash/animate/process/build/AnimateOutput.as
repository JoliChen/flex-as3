package com.joli.modules.flash.animate.process.build
{
	import com.joli.art2.console.ILogcat;
	import com.joli.extension.drawswf.animate.parser.IAnimateOutput;
	import com.joli.extension.drawswf.animate.parser.draw.SheetRender;
	import com.joli.extension.drawswf.animate.struct.AnimateData;
	import com.joli.extension.drawswf.animate.struct.SheetData;
	import com.jonlin.utils.ReflectUtil;
	import com.jonlin.utils.FileUtil;
	import com.jonlin.structure.TreeMap;
	import com.joli.modules.flash.animate.affairs.AnimateReq;
	import com.joli.modules.flash.animate.process.build.system.AnimateDisk;
	import com.joli.modules.flash.animate.process.build.system.SpriteSheetPair;
	
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.system.ApplicationDomain;
	
	
	/**
	 * 动画输出器
	 * @author Joli
	 * @date 2018-8-1 下午9:12:58
	 */
	public class AnimateOutput extends AnimateDisk implements IAnimateOutput
	{
		private static const CLS_STAT_POS_POW2:uint = 1;//类名标识索引：自动缩回2的N次幂
		
		private var _newAniamDataSet:Vector.<AnimateData>;
		private var _newSheetNameSet:Vector.<String>;
		private var _newSheetDataMap:TreeMap;
		private var _atlasPacker:AtlasPacker;
		private var _assetsInfo:AnimateAssets;
		private var _request:AnimateReq;
		private var _callbackHandler:Function;
		
		public function AnimateOutput(logcat:ILogcat, destRoot:String, makeRoot:String)
		{
			super(logcat, destRoot, makeRoot);
			_newAniamDataSet = new Vector.<AnimateData>();
			_newSheetNameSet = new Vector.<String>();
			_newSheetDataMap = new TreeMap();
			_atlasPacker = new AtlasPacker(logcat, this);
		}
		
		override public function dispose():void
		{
			super.dispose();
			if (_newAniamDataSet) {
				_newAniamDataSet.length = 0;
				_newAniamDataSet = null;
			}
			if (_newSheetNameSet) {
				_newSheetNameSet.length = 0;
				_newSheetNameSet = null;
			}
			if (_newSheetDataMap) {
				_newSheetDataMap.clear();
				_newSheetDataMap = null;
			}
			if (_atlasPacker) {
				_atlasPacker.dispose();
				_atlasPacker = null;
			}
			_request = null;
			_callbackHandler = null;
		}
		
		public function putAnimate(animateData:AnimateData):void
		{
			const animateId:uint = animateData.animateId;
			const len:uint = _newAniamDataSet.length;
			for (var i:int=len-1; i>-1; --i) {
				if (animateId == _newAniamDataSet[i].animateId) {
					_newAniamDataSet[i] = animateData;
					return;
				}
			}
			_newAniamDataSet[len] = animateData;
		}
		
		public function putSheet(sheetClassName:String):uint
		{
			if (-1 == _newSheetNameSet.lastIndexOf(sheetClassName)) {
				_newSheetNameSet.push(sheetClassName);
			}
			return sheetNameMap.index(sheetClassName);
		}
		
		public function setOptions(request:AnimateReq):void
		{
			_request = request;
			if (_request.slim_images) {
				assetsSlim2.setup();
			}
			_atlasPacker.setTexturePacker(request, fullTempDir("packtexture"));
		}

		public function output(domian:ApplicationDomain, callback:Function):void
		{
			_callbackHandler = callback;
			buildDefaultDirs();
			outputUnpackedSheets(domian);
			rebuildAnimateAssets();
		}
		
		private function outputUnpackedSheets(domian:ApplicationDomain):void
		{
			const sheetRender:SheetRender = new SheetRender();
			var sheetId:uint;
			var sheetData:SheetData;
			var sheetClassName:String;
			var sheetClass:Class;
			var textures:Vector.<BitmapData>;
			for (var i:int=_newSheetNameSet.length-1; i>-1; --i) {
				sheetClassName = _newSheetNameSet[i];
				sheetClass = ReflectUtil.getClass(sheetClassName, domian);
				if (!sheetClass) {
					log.error("序列帧类名未找到:{0}", sheetClassName);
					continue;
				}
				sheetId = sheetNameMap.index(sheetClassName);
				sheetData = new SheetData(sheetId);
				_newSheetDataMap.setValue(sheetId, sheetData);//记录新导出的序列帧数据
				textures = sheetRender.renderder(sheetClass, sheetData);
				if (!textures) {
					log.error("序列帧没有纹理:{0}", sheetClassName);
					continue;
				}
				saveUnpackedSheet(sheetClassName, sheetId, textures);
				saveSheetJson(sheetClassName, sheetData);
				log.debug("output images:{0} - {1}:{2}", i+1, sheetId, sheetClassName);
			}
			sheetNameMap.save();
			sheetRender.dispose();
		}
		
		public function rebuildAnimateAssets():void
		{
			log.debug("分析动画数据中，请稍等...");
			const allAnimateSet:Vector.<AnimateData> = loadAllAnimates();
			_assetsInfo = Helper.calcAssetsInfo(allAnimateSet);
			// 输出新动画数据
			outputAnimateDatas(allAnimateSet, _assetsInfo);
			updateNewSheetDatas();
			// 输出资源概要说明
			if (_request.print_profile) {
				assetsProfile.save(allAnimateSet, _assetsInfo, sheetNameMap);
			}
			// 打包序列帧图集
			_atlasPacker.pack(
				Helper.calcExportSheetAtlas(_newSheetDataMap, _assetsInfo.sheetSet), 
				Helper.calcExportSheetGroup(_newSheetDataMap, _assetsInfo.groupMap),
				onAtlasPackDone);
		}
		
		private function loadAllAnimates():Vector.<AnimateData>
		{
			const len:uint = _newAniamDataSet.length;
			const ignores:Vector.<uint> = new Vector.<uint>(len, true);
			for (var i:int=0; i<len; ++i) {
				ignores[i] = _newAniamDataSet[i].animateId;
			}
			const animateSet:Vector.<AnimateData> = loadAnimateDatas(ignores);
			for (i=0; i<len; ++i) {
				animateSet.push(_newAniamDataSet[i]);
			}
			return animateSet; 
		}
		
		private function outputAnimateDatas(animateSet:Vector.<AnimateData>, assetsInfo:AnimateAssets):void
		{
			for (var i:int=0, len:uint=animateSet.length; i<len; ++i) {
				if (Helper.calcExportAnimateData(animateSet[i], assetsInfo)) {
					continue;
				}
				animateSet.splice(i--, 1); // 剔除没有变更的动画
				len--;
			}
			log.debug("输出动画数据数量:{0}", animateSet.length);
			saveAnimateDatas(animateSet);
			_newAniamDataSet.length = 0;// 不再需要新动画数据了
		}
		
		private function updateNewSheetDatas():void
		{
			sheetPackage.load();
			sheetPackage.update(_newSheetDataMap);
			sheetPackage.filter(_assetsInfo.getAllSheets());
		}

		[inline]
		internal function getSheetName(sheetId:uint):String
		{
			return sheetNameMap.id2name(sheetId);
		}
		
		internal function getGroupItems(group:Vector.<uint>):Vector.<String>
		{
			const size:uint = group.length;
			const buffer:Vector.<String> = new Vector.<String>(size, true);
			for (var j:int=0; j<size; ++j) {
				buffer[j] = getSheetName(group[j]);
			}
			return buffer;
		}
		
		private function copyPackSheetImages(sheetId:uint, tempDir:File):void
		{
			const sheetDir:File = fullSheetImageDir(getSheetName(sheetId));
			const images:Vector.<File> = FileUtil.listFiles(sheetDir, texFilter, false);
			for (var i:int=images.length-1, f:File; i>-1; --i) {
				f = images[i];
				copyDiskFile(f, FileUtil.newFile(f.name, tempDir));
			}
		}
		
		internal function onPackingSheet(sheetId:uint, src:File, dst:SpriteSheetPair):void
		{
			clearDiskDir(src);
			copyPackSheetImages(sheetId, src);
			if (_request.slim_images) {
				assetsSlim2.fullSheetPair(sheetId, dst);
			} else {
				fullSheetPair(sheetId, dst);
			}
			deleteSpritePair(dst);
		}
		internal function onPackingGroup(groupId:uint, group:Vector.<uint>, src:File, dst:SpriteSheetPair):void
		{
			clearDiskDir(src);
			for (var j:int=group.length-1; j>-1; --j) {
				copyPackSheetImages(group[j], src);
			}
			if (_request.slim_images) {
				assetsSlim2.fullGroupPair(groupId, dst);
			} else {
				fullGroupPair(groupId, dst);
			}
			deleteSpritePair(dst);
		}

		private function onAtlasPackDone():void
		{
			_atlasPacker.dumpErrors();
			if (_request.slim_images) {
				assetsSlim2.start(verifyAllAtlas);
			} else {
				verifyAllAtlas();
			}
		}
		
		private function verifyAllAtlas():void
		{
			// 清理无用的序列帧资源
			cleanUnusedAtlas(_assetsInfo);
			// 检查缺失的资源
			const missSheets:Vector.<uint> = new Vector.<uint>();
			const missGroups:TreeMap = new TreeMap();
			checkMissAtlas(missSheets, missGroups);
			// 重新打包缺失的资源
			if (missSheets.length > 0 || missGroups.length > 0) {
				log.warn("重新输出丢失的图片...");
				_atlasPacker.pack(missSheets, missGroups, verifyAtlasDone);
			} else {
				verifyAtlasDone();
			}
		}
		
		private function verifyAtlasDone():void {
			_atlasPacker.dumpErrors();
			// 输出序列帧数据
			saveSheetDataPackage();
			// 回调
			if (null != _callbackHandler) {
				_callbackHandler();
			}
		}
		
		private function checkMissAtlas(missSheets:Vector.<uint>, missGroups:TreeMap):void 
		{
			const sheetPair:SpriteSheetPair = new SpriteSheetPair();
			var sheetId:uint, i:int;
			for (i=_assetsInfo.sheetSet.length-1; i>-1; --i) {
				sheetId = _assetsInfo.sheetSet[i];
				fullSheetPair(sheetId, sheetPair);
				if (!sheetPair.exists) {
					missSheets.push(sheetId);
				}
			}
			for (i=_assetsInfo.groupMap.length-1; i>-1; --i) {
				sheetId = _assetsInfo.groupMap.getKeyAt(i);
				fullGroupPair(sheetId, sheetPair);
				if (!sheetPair.exists) {
					missGroups.pushPair(sheetId, _assetsInfo.groupMap.getValueAt(i));
				}
			}
		}
		
		private function cleanUnusedAtlas(assetsInfo:AnimateAssets):void
		{
			const pair:SpriteSheetPair = new SpriteSheetPair();
			var sheetId:uint, i:int;
			// 清理粒子图集
			const usedSheetSet:Vector.<uint> = assetsInfo.sheetSet;
			const diskSheetSet:Vector.<uint> = listAtlas();
			for (i=diskSheetSet.length-1; i>-1; --i) {
				sheetId = diskSheetSet[i];
				if (usedSheetSet.lastIndexOf(sheetId) == -1) {
					fullSheetPair(sheetId, pair);
					log.debug("删除无用的粒子图集:{0}  {1}", pair.image.name, pair.plist.name);
					deleteSpritePair(pair);// to remove
				}
			}
			// 清理组合图集
			const usedGroupMap:TreeMap = assetsInfo.groupMap;
			const diskGroupSet:Vector.<uint> = listGroups();
			for (i=diskGroupSet.length-1; i>-1; --i) {
				sheetId = diskGroupSet[i];
				if (!usedGroupMap.has(sheetId)) {
					fullGroupPair(sheetId, pair);
					log.debug("删除无用的组合图集:{0}  {1}", pair.image.name, pair.plist.name);
					deleteSpritePair(pair);// to remove
				} 
			}
		}
		
		private function saveSheetDataPackage():void
		{
			//更新缩放系数
			var sid:String, groupId:uint, sheetId:uint, scale:Number, sheetData:SheetData;
			for (sid in _atlasPacker.groupScaleMap) {
				scale = _atlasPacker.groupScaleMap[sid];
				groupId = parseInt(sid);
				for each(sheetId in _assetsInfo.groupMap.getValue(groupId)) {
					sheetData = sheetPackage.getSheetData(sheetId);
					if (sheetData) {
						sheetData.updateScale(scale);
					} else {
						log.error("cannot found sheetData on update scale:{0}", sheetId);
					}
				}
			}
			for (sid in _atlasPacker.sheetScaleMap) {
				scale = _atlasPacker.sheetScaleMap[sid];
				sheetId = parseInt(sid);
				sheetData = sheetPackage.getSheetData(sheetId);
				if (sheetData) {
					sheetData.updateScale(scale);
				} else {
					log.error("cannot found sheetData on update scale:{0}", sheetId);
				}
			}
			//保存到磁盘
			sheetPackage.save();
			_newSheetNameSet.length = 0;//不再需要新序列帧了
		}
		
		/**
		 * 是否允许序列图自动缩回2的N次幂
		 */
		internal function canShrinkPow2Sheet(sheetId:uint):Boolean
		{
			var cls:String = getSheetName(sheetId);
			if (!cls || cls.length <= 0) {
				return false;
			}
			var arr:Array = cls.split("_");
			if (arr.length < 2) {
				return true;
			}
			var mask:uint = 0;
			try {
				mask = parseInt(arr[1]);
			}  catch(error:Error) {
				log.error(error.getStackTrace());
			}
			return (mask & (1 << CLS_STAT_POS_POW2)) != 0;
		}
		
		/**
		 * 是否允许组合图自动缩回2的N次幂
		 */
		internal function canShrinkPow2Group(groupId:uint):Boolean
		{
			for each(var sheetId:uint in _assetsInfo.groupMap.getValue(groupId)) {
				if (!canShrinkPow2Sheet(sheetId)) {
					return false;
				}
			}
			return true;
		}
	}
}