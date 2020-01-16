package com.joli.modules.artist.image.slim
{
	import com.joli.art2.Art;
	import com.joli.art2.ArtFactory;
	import com.joli.art2.affairs.IAffairsDAO;
	import com.joli.art2.affairs.task.TaskHost;
	import com.joli.art2.features.ArtModuleBase;
	import com.joli.art2.features.IModuleGUI;
	import com.joli.modules.artist.image.slim.affairs.SlimImageDao;
	import com.joli.modules.artist.image.slim.affairs.SlimImageReq;
	import com.joli.modules.artist.image.slim.affairs.SlimImageRet;
	import com.joli.modules.artist.image.slim.gui.SlimImageUI;
	
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	
	/**
	 * 图片压缩模块
	 * @author Joli
	 * @date 2018-7-18 上午10:23:25
	 */
	public class SlimImageModule extends ArtModuleBase
	{
		private const worker:String = "SlimImageWorker";
		private var _isBusy:Boolean;
		private var _session:TaskHost;
		
		private var _dao:SlimImageDao;
		private var _gui:SlimImageUI;
		
		public function SlimImageModule(id:uint, name:String)
		{
			super(id, name);
			_isBusy = false;
			_dao = new SlimImageDao(ArtFactory.DAO_ImageSlim);
		}
		
//		override public function get gui():IModuleGUI 
//		{
//			var bytes:ByteArray = SyncIOUtil.read("/Users/joli/Desktop/Default-736h@3x.png");
//			
//			var base64:Base64Encoder = new Base64Encoder();
//			base64.insertNewLines = false;
//			base64.encode("XiMcRQp1B7Ene95weLQtSU3vvkvPli11");
//			var auth:String = "Basic " + base64.toString();
//			base64.drain();
//			
//			var req:URLRequest = new URLRequest("https://api.tinify.com/shrink");
//			req.method = URLRequestMethod.POST;
//			req.data = bytes;
//			req.contentType = "application/octet-stream";
//			req.requestHeaders = [
//				new URLRequestHeader("Authorization", auth),
//				new URLRequestHeader("Accept", "application/json")
//			];
//			
//			var loader:URLLoader = new URLLoader();
//			loader.dataFormat = URLLoaderDataFormat.BINARY;
//			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
//				trace(e.target.data);
//			});
//			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
//				trace(e.text);
//			});
//			loader.load(req);
//			return null;
//		}
		
		public override function get gui():IModuleGUI
		{
			if (!_gui) {
				_gui = new SlimImageUI(this, _dao);
			}
			return _gui;
		}
		
		public function get dao():IAffairsDAO
		{
			return _dao;
		}
		
		public function resume():void
		{
			if (_isBusy) {
				Alert.show("压缩程序正忙");
				return;
			}
			
			const req:SlimImageReq = SlimImageReq.create(_dao);
			_isBusy = true;
			
			Art.singleton.clearConsole();
			if (!_session) {
				_session = new TaskHost(worker);
			}
			_session.start(req, onTaskExit);
		}
		
		private function onTaskExit(bytes:ByteArray):void
		{
			const ret:SlimImageRet = new SlimImageRet();
			ret.read(bytes);
			trace(worker, "exit:", ret.exitCode);
			_isBusy = false;
		}
	}
}