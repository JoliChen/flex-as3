package com.joli.modules.flash.animate.process.build.system
{
	import com.joli.art2.console.ILogcat;
	import com.joli.extension.drawswf.animate.struct.AnimateData;
	import com.joli.extension.drawswf.animate.struct.SheetData;
	import com.joli.extension.drawswf.animate.struct.SheetFrame;
	import com.jonlin.Globals;
	import com.jonlin.core.IDispose;
	import com.jonlin.utils.FileUtil;
	import com.jonlin.utils.IOUtil;
	import com.jonlin.utils.Regular;
	
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * 动画文件系统
	 * @author Joli
	 * @date 2018-7-30 下午8:50:02
	 */
	public class AnimateDisk implements IDispose
	{
		public static const sheetImageTag:String = "animate";
		public static const sheetdatFormt:String = ".json";
		public static const aniDataFormat:String = ".ani";
		public static const textureFormat:String = ".png";
		public static const texDataFormat:String = ".plist";
		
		protected const texFilter:Vector.<String> = Vector.<String>([textureFormat.replace(".", "")]);
		protected const aniFilter:Vector.<String> = Vector.<String>([aniDataFormat.replace(".", "")]);

		private var _makeRoot:File;
		private var _makeBasicDir:File;
		private var _makeSheetDir:File;
		private var _makeFrameDir:File;
		private var _tempDriveDir:File;

		private var _destRoot:File;
		private var _destSheetDir:File;
		private var _destGroupDir:File;
		private var _destDatasDir:File;
		
		private var _log:ILogcat;
		private var _assetProfile:AssetsProfile;
		private var _sheetNameMap:SheetNameMap;
		private var _sheetPackage:SheetPackage;
		
		private var _pngEncoderOptions:PNGEncoderOptions = new PNGEncoderOptions();
		private var _assetsSlim:AssetsSlim;
		
		public static function newByteArray():ByteArray
		{
			const b:ByteArray = new ByteArray();
			b.endian = Endian.LITTLE_ENDIAN;
			return b;
		}
		
		public function AnimateDisk(logcat:ILogcat, destRoot:String, makeRoot:String)
		{
			_log = logcat;
			_makeRoot = FileUtil.newFile(makeRoot);
			_destRoot = FileUtil.newFile(destRoot);
			
			_makeBasicDir = FileUtil.newFile("basic", _makeRoot);
			_makeSheetDir = FileUtil.newFile("sheet", _makeBasicDir);
			_makeFrameDir = FileUtil.newFile("frame", _makeBasicDir);
			_tempDriveDir = FileUtil.newFile("drive", _makeRoot);
			
			_destSheetDir = FileUtil.newFile("sheet", _destRoot);
			_destGroupDir = FileUtil.newFile("group", _destRoot);
			_destDatasDir = FileUtil.newFile("datas", _destRoot);
			_assetsSlim = new AssetsSlim(logcat, fullTempDir("unslim"), _destSheetDir, _destGroupDir);
			
			_assetProfile = new AssetsProfile(FileUtil.newFile("profile", _makeRoot));
			_sheetPackage = new SheetPackage(FileUtil.newFile("SheetPackage.fbf", _destRoot));
			_sheetNameMap = new SheetNameMap(FileUtil.newFile("SheetStore.json",  _makeBasicDir));
		}
		
		public function dispose():void
		{
			_log = null;
			texFilter.length = 0;
			aniFilter.length = 0;
			if (_sheetNameMap) {
				_sheetNameMap.dispose();
				_sheetNameMap = null;
			}
			if (_sheetPackage) {
				_sheetPackage.dispose();
				_sheetPackage = null;
			}
			if (_assetsSlim) {
				_assetsSlim.dispose();
				_assetsSlim = null;
			}
		}
		
		protected final function get log():ILogcat
		{
			return _log;
		}
		
		protected final function get sheetPackage():SheetPackage
		{
			return _sheetPackage;
		}
		
		protected final function get sheetNameMap():SheetNameMap
		{
			return _sheetNameMap;
		}
		
		protected final function get assetsProfile():AssetsProfile
		{
			return _assetProfile;	
		}
		
		protected final function get assetsSlim2():AssetsSlim
		{
			return _assetsSlim;
		}
		
		/**
		 * 构建文件系统
		 * @param refactoring 重构，删除所有文件重新构建。
		 */		
		protected final function buildDefaultDirs(refactoring:Boolean=false):void
		{			
			if (refactoring) {
				if (_makeRoot.exists) {
					_makeRoot.deleteDirectory(true);
				}
				if (_destRoot.exists) {
					_destRoot.deleteDirectory(true);
				}
			}
			// build make dirs
			_makeRoot.createDirectory();
			_makeBasicDir.createDirectory();
			_makeSheetDir.createDirectory();
			_makeFrameDir.createDirectory();
			_tempDriveDir.createDirectory();
			// build dest dirs
			_destRoot.createDirectory();
			_destSheetDir.createDirectory();
			_destGroupDir.createDirectory();
			_destDatasDir.createDirectory();
		}
		
		/**
		 * 补全临时
		 * @param dirName
		 * @return 
		 */		
		protected final function fullTempDir(dirName:String):File
		{
			return FileUtil.newFile(dirName, _tempDriveDir);
		}
		
		/**
		 * 序列帧散图文件夹
		 * @param sheetName
		 * @return 
		 */		
		protected final function fullSheetImageDir(sheetName:String):File
		{
			return FileUtil.newFile(sheetName, _makeSheetDir);
		}
		
		/**
		 * 命名序列帧散图
		 * @param sheetId
		 * @param index
		 * @return 
		 */		
		private function nameSheetImage(sheetId:uint, index:uint):String {
			return [sheetImageTag, "_", sheetId, "_", index, textureFormat].join("");
		}
		
		/**
		 * 保存序列帧散图
		 * @param sheetName
		 * @param sheetData
		 * @param textures
		 */		
		protected final function saveUnpackedSheet(sheetName:String, sheetId:uint, textures:Vector.<BitmapData>):void {
			const sheetDir:File = fullSheetImageDir(sheetName);
			clearDiskDir(sheetDir);
			
			var bytes:ByteArray;
			var name:String;
			var bmd:BitmapData;
			for (var i:int=0, len:int=textures.length; i<len; ++i) {
				bmd = textures[i];
				if (!bmd) {
					continue;
				}
				name = nameSheetImage(sheetId, i);
				bytes = bmd.encode(bmd.rect, _pngEncoderOptions);
				bmd.dispose(); // 销毁位图数据
				IOUtil.writeFile(FileUtil.newFile(name, sheetDir), bytes);
			}
		}

		/**
		 * 保存序列帧配置 
		 * @param sheetName
		 * @param sheetData
		 */		
		protected final function saveSheetJson(sheetName:String, sheetData:SheetData):void
		{
			const dataFile:File = FileUtil.newFile(sheetName + sheetdatFormt, _makeFrameDir);
			const sheetJson:Object = {"sheetId":sheetData.sheetId, "scale":sheetData.scale, "frames":[]};
			for (var i:int=0, len:int=sheetData.frames.length, frame:SheetFrame; i<len; ++i) {
				frame = sheetData.frames[i];
				sheetJson["frames"][i] = {"frameType":frame.frameType, "offsetX":frame.offsetX, "offsetY":frame.offsetY};
			}
			const text:String = JSON.stringify(sheetJson, null, 4);
			IOUtil.writeString(dataFile, text);
		}
		
		/**
		 * 载入序列帧配置
		 * @param sheetName
		 * @return
		 */		
		protected final function loadSheetJson(sheetName:String):SheetData 
		{
			const dataFile:File = FileUtil.newFile(sheetName + sheetdatFormt, _makeFrameDir);
			const text:String = IOUtil.readString(dataFile);
			const sheetJson:Object = JSON.parse(text);
			const sheetData:SheetData = new SheetData(sheetJson["sheetId"], sheetJson["scale"]);
			const frames:Array = sheetJson["frames"];
			for (var i:int=0, len:int=frames.length, frame:Object, sheetFrame:SheetFrame; i<len; ++i) {
				frame = frames[i];
				sheetFrame = new SheetFrame(frame["frameType"], frame["offsetX"], frame["offsetY"]);
				sheetData.frames[i] = sheetFrame;
			}
			return sheetData;
		}
		
		/**
		 * 载入动画数据
		 * @param ignores 忽略载入的动画
		 * @return
		 */		
		protected final function loadAnimateDatas(ignores:Vector.<uint>=null):Vector.<AnimateData>
		{
			const animSet:Vector.<AnimateData> = new Vector.<AnimateData>();
			const files:Vector.<File> = FileUtil.listFiles(_destDatasDir, aniFilter, false);
			const count:uint = files.length;
			const bytes:ByteArray = newByteArray();
			var animateFile:File, animateName:String, animateData:AnimateData, animateId:uint;
			for (var i:int=0; i<count; ++i) {
				animateFile = files[i];
				animateName = FileUtil.getFilename(animateFile);
				if (!Regular.isInteger(animateName)) {
					_log.warn("非法动画数据:{0}", animateFile.nativePath);
					continue;
				}
				animateId = uint(animateName);
				if (!ignores || (ignores.lastIndexOf(animateId) == -1)) {
					bytes.clear();
					IOUtil.readFile(animateFile, bytes);
					if (bytes.length > 0) {
						animateData = new AnimateData();
						animateData.read(bytes);
						animSet[animSet.length] = animateData;
					}
				}
			}
			return animSet;
		}
		
		/**
		 * 保存动画数据
		 * @param animateDatas
		 */		
		protected final function saveAnimateDatas(animateDatas:Vector.<AnimateData>):void
		{
			const bytes:ByteArray = newByteArray();
			var animateData:AnimateData, animateName:String, animateFile:File;
			for (var i:int=animateDatas.length-1; i>-1; --i) {
				bytes.clear();
				animateData = animateDatas[i];
				animateName = animateData.animateId + aniDataFormat;
				animateFile = FileUtil.newFile(animateName, _destDatasDir);
				animateData.write(bytes);
				IOUtil.writeFile(animateFile, bytes);
			}
		}
		
		/**
		 * 列出所有序列帧粒子图集
		 * @return 
		 */		
		protected final function listAtlas():Vector.<uint>
		{
			const sheetSet:Vector.<uint> = new Vector.<uint>();
			const files:Vector.<File> = FileUtil.listFiles(_destSheetDir, texFilter, false);
			const count:uint = files.length;
			for (var i:int=0, name:String, sheetId:Number; i<count; ++i) {
				name = FileUtil.getFilename(files[i]);
				if (!Regular.isInteger(name)) {
					_log.error("非法粒子图集:{0}", name);
					continue;
				}
				sheetSet[sheetSet.length] = uint(name);
			}
			return sheetSet;
		}
		
		/**
		 * 列出所有序列帧组合图集
		 * @return 
		 */		
		protected final function listGroups():Vector.<uint>
		{
			const groupSet:Vector.<uint> = new Vector.<uint>();
			const files:Vector.<File> = FileUtil.listFiles(_destGroupDir, texFilter, false);
			const count:uint = files.length;
			for (var i:int=0, name:String; i<count; ++i) {
				name = FileUtil.getFilename(files[i]);
				if (!Regular.isInteger(name)) {
					_log.error("非法组合图集:{0}", name);
					continue;
				}
				groupSet[groupSet.length] = uint(name);
			}
			return groupSet;
		}
		
		/**
		 * 序列帧粒子图集路径 
		 * @param sheetId
		 */			
		protected final function fullSheetPair(sheetId:uint, pair:SpriteSheetPair):void
		{
			pair.setPair(sheetId.toString(), _destSheetDir);
		}
		
		/**
		 * 序列帧组合图集路径 
		 * @param groupId
		 */			
		protected final function fullGroupPair(groupId:uint, pair:SpriteSheetPair):void
		{
			pair.setPair(groupId.toString(), _destGroupDir);
		}
		
		/**
		 * 删除图集
		 * @param sheetPair
		 */		
		protected final function deleteSpritePair(sheetPair:SpriteSheetPair):void
		{
			deleteDiskFile(sheetPair.image);
			deleteDiskFile(sheetPair.plist);
		}
		
		/**
		 * 拷贝文件 
		 * @param src
		 * @param dst
		 * @param overwrite
		 * @return 
		 * 
		 */				
		protected final function copyDiskFile(src:File, dst:File, overwrite:Boolean=true):Boolean
		{
			if (!src.exists) {
				return false;
			}
			try {
				src.copyTo(dst, overwrite);
				return true;
			} catch(error:Error) {
				_log.error(error.getStackTrace());
			}
			return false;
		}
		
		/**
		 * 删除磁盘的文件
		 * @param file
		 * @return 
		 */		
		protected final function deleteDiskFile(file:File):Boolean
		{
			if (!file.exists) {
				return true;
			}
			try {
				file.deleteFile();
				return true;
			} catch(error:Error) {
				_log.error(error.getStackTrace());
			}
			return false;
		}
		
		/**
		 * 清空磁盘文件夹
		 * @param dir
		 */		
		protected final function clearDiskDir(dir:File):void
		{
			if (dir.exists) {
				try {
					dir.deleteDirectory(true);
				} catch(error:Error) {
					_log.error(error.getStackTrace());
				}
			}
			dir.createDirectory();
		}
	}
}