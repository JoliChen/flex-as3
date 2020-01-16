package com.jonlin.se.io
{
	import com.extenal.plist.LocalPlist;
	import com.extenal.texturepacker.TPCommand;
	import com.jonlin.core.IDispose;
	import com.jonlin.se.MEMain;
	import com.jonlin.se.support.EditConst;
	import com.jonlin.se.support.EditData;
	import com.jonlin.se.user.UserTPConf;
	import com.jonlin.shell.ShellSession;
	import com.jonlin.shell.events.ShellEvent;
	import com.jonlin.utils.FileUtil;
	import com.jonlin.utils.IOUtil;
	
	import flash.filesystem.File;
	
	/**
	 * Cocos Writer
	 * @author jonlin
	 * @date 2019-8-20 下午6:35:06
	 */
	public class CocosWriter implements IDispose
	{
		private var _shell:ShellSession;
		
		private var _editData:EditData;
		private var _editInfo:Object;
		private var _callback:Function;
		private var _distFile:File;
		
		public function CocosWriter()
		{
		}
		
		public function dispose():void
		{
			this.clear();
			if (_shell) {
				_shell.dispose();
				_shell = null;
			}
		}
		
		public function clear():void
		{
			_editData = null;
			_editInfo = null;
			_callback = null;
			_distFile = null;
		}
		
		public function publish(distFile:File, data:EditData, callback:Function):void
		{
			_distFile = distFile;
			_editData = data;
			_editInfo = data.makeConfig();
			_callback = callback;
			switch(data.type)
			{
				case EditData.TYPE_SUITE: {
					this.writeSuite();
					break;
				}
				case EditData.TYPE_COCOS: {
					this.writePlist(_editData.source.nativePath);
					break;
				}
			}
		}
		
		private function writeSuite():void
		{
			var srcFile:File = _editData.source;
			var config:String = JSON.stringify(_editInfo);
			if (config) {
				var sfjFile:File = FileUtil.newFile(EditConst.SFJ, srcFile);
				IOUtil.writeString(sfjFile, config);
			}
			
			var tpConf:UserTPConf = MEMain.singleton.userTPConf;
			
			var tag:String = srcFile.name;
			var dataPath:String = FileUtil.join(_distFile.nativePath, tag + ".plist");
			var cmd:TPCommand = new TPCommand();
			cmd.executable = tpConf.texpacker;
			cmd.sourceDir = srcFile.nativePath;
			cmd.sheetPath = FileUtil.join(_distFile.nativePath, tag + ".png");
			cmd.dataPath = dataPath;
			cmd.maxSize = tpConf.maxSize;
			cmd.scale = tpConf.scale;
			tag += "_";
			cmd.replace = "^=" + tag;
			cmd.trimExt = tpConf.trimNameExt;
			
			if (!_shell) {
				_shell = new ShellSession();
				_shell.addEventListener(ShellEvent.EXIT, onShellExit, false, 0, true);
			}
			_shell.execute(cmd, [dataPath, tag]);
		}
		
		private function onShellExit(event:ShellEvent):void
		{
			if (0 != event.code) {
				trace("shell exit code", event.code);
				return;
			}
			var attachment:Array = event.data;
			this.writePlist(attachment[0], attachment[1]);
		}
		
		private function writePlist(path:String, tag:String=null):void
		{
			var plist:LocalPlist = new LocalPlist(path);
			var modeldata:XML = null;
			var metadata:XML = plist.xml.dict[0].dict[1];
			var metaitem:XMLList = metadata.children();
			for (var i:int=0, n:int=metaitem.length(); i<n; i++) {
				var item:XML = metaitem[i];
				if (item == "modeldata") {
					modeldata = metaitem[++i];
					break;
				}
			}
			if (!modeldata) {
				modeldata = <dict>
								<key>frames</key>
								<string>1_2_3</string>
								<key>anchor</key>
								<string>{0,0}</string>
								<key>tag</key>
								<string>tag</string>
							</dict>;
				metadata.appendChild(<key>modeldata</key>);
				metadata.appendChild(modeldata);
			}
			modeldata.string[0] = _editData.buildPublishText();
			modeldata.string[1] = "{" + _editData.anchor.x + "," + _editData.anchor.y + "}";
			if (tag) {
				modeldata.string[2] = tag;
			}
			plist.save();
			
			var callback:Function = _callback;
			this.clear();
			if (null != callback) {
				callback();
			}
		}
	}
}