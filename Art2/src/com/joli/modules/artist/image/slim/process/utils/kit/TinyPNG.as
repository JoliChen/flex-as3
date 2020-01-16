package com.joli.modules.artist.image.slim.process.utils.kit
{
	import com.joli.art2.console.ILogcat;
	import com.jonlin.utils.IOUtil;
	import com.jonlin.utils.MathUtil;
	import com.joli.modules.artist.image.slim.process.utils.ISlimImageHandler;
	import com.joli.modules.artist.image.slim.process.utils.ISlimImageKit;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Encoder;
	
	/**
	 * TinyPNG压缩
	 * @author Joli
	 * @date 2018-8-30 下午4:15:41
	 */
	public final class TinyPNG implements ISlimImageKit
	{
		private var _tploader:URLLoader;
		private var _step:int;
		private var _apiKey:String;
		private var _imgLog:String;
		private var _imgUrl:String;
		
		private var _srcFile:String;
		private var _dstFile:String;
		private var _handler:ISlimImageHandler;
		private var _log:ILogcat;
		
		public function TinyPNG(log:ILogcat)
		{
			super();
			_log = log;
			_step = -1;
			_tploader = new URLLoader();
			_tploader.addEventListener(Event.COMPLETE, onLoadComplete);
			_tploader.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
		}
		
		public function dispose():void
		{
			if (_tploader) {
				_tploader.removeEventListener(Event.COMPLETE, onLoadComplete);
				_tploader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
				_tploader = null;
			}
			_log = null;
			clear();
		}
		
		public function clear():void
		{
			_apiKey = _imgUrl = _imgLog = _srcFile = _dstFile = null;
			_handler = null;
			_step = -1;
		}
		
		public function isSupport():Boolean
		{
			return TinyKeystore.size > 0;
		}
		
		public function isIdle():Boolean
		{
			return -1 == _step;
		}
		
		public function slim(srcFile:String, dstFile:String, handler:ISlimImageHandler):void
		{
			_step = 0;
			_srcFile = srcFile;
			_dstFile = dstFile;
			_handler = handler;
			
			upload(srcFile);
		}
		
		private function handleErr(errMsg:String):void
		{
			_handler.onSlimError(_srcFile, errMsg);
			exit();
		}
		
		private function exit():void
		{
			const handler:ISlimImageHandler = _handler;
			const srcImage:String = _srcFile;
			clear();
			if (null != handler) {
				_handler = null;
				handler.onSlimExit(this);
			}
		}

		private function upload(file:String):void
		{
			const bytes:ByteArray = IOUtil.read(file);
			if (!bytes || 0 == bytes.length) {
				handleErr("source image is empty.");
				return;
			}
			const apiKey:String = TinyKeystore.popApiKey();
			if (!apiKey) {
				handleErr("there is no available API key.");
				return;
			}
			
			_step = 1;
			_apiKey = apiKey;
			const auth:String = getAuthInfo(apiKey);
			const req:URLRequest = new URLRequest("https://api.tinify.com/shrink");
			req.method = URLRequestMethod.POST;
			req.data = bytes;
			req.contentType = "application/octet-stream";
			req.requestHeaders = [
				new URLRequestHeader("Authorization", auth),
				new URLRequestHeader("Accept", "application/json")
			];
			_tploader.dataFormat = URLLoaderDataFormat.TEXT;
			_tploader.load(req);
		}
		
		private function download(url:String):void
		{
			_step = 2;
			_imgUrl = url;
			const req:URLRequest = new URLRequest(url);
			req.method = URLRequestMethod.GET;
			_tploader.dataFormat = URLLoaderDataFormat.BINARY;
			_tploader.load(req);
		}
		
		private function getAuthInfo(key:String):String
		{
			const base64:Base64Encoder = new Base64Encoder();
			base64.insertNewLines = false;
			base64.encode(key);
			return "Basic " + base64.toString();
		}
		
		private function onLoadComplete(e:Event):void
		{
			const data:* = _tploader.data;
			_tploader.close();
			switch (_step) {
				case 1:
					onUploadResp(data);
					break;
				case 2:
					onDownloadResp(data);
					break;
			}
		}
		
		private function onLoadIOError(e:IOErrorEvent):void
		{
			_tploader.close();
			switch (_step) {
				case 1:
					toDeleteApiKey(e.target as URLLoader);
					if (_srcFile) {
						upload(_srcFile);
					} else {
						handleErr("unknown error");
					}
					break;
				case 2:
					if (_imgUrl) {
						download(_imgUrl);
					} else {
						handleErr("unknown error");
					}
					break;
			}
		}
		
		private function onUploadResp(ret:String):void
		{
			if (!ret) {
				handleErr("upload response result is empty.");
				return;
			}
			const report:Object = JSON.parse(ret);
			if (!report) {
				handleErr("upload response result parsing error.");
				return;
			}
			const outInfo:Object = report["output"];
			if (!outInfo) {
				handleErr("no output information was returned.");
				return;
			}
			const slimRatio:Number = outInfo["ratio"];
			if (!isNaN(slimRatio) && slimRatio >= 1) {
				exit();
				return;
			}
			const imageUrl:String = outInfo["url"];
			if (!imageUrl) {
				handleErr("no download url was returned.");
				return;
			}
			_imgLog = genSlimLogger(report["input"], outInfo, slimRatio);
			download(imageUrl);
		}
		
		private function onDownloadResp(img:ByteArray):void
		{
			_imgUrl = null;
			if (!img) {
				handleErr("the compressed image is empty.");
				return;
			}
			if (!IOUtil.write(_dstFile, img)) {
				handleErr("the compressed image writing error.");
				return;
			}
			// slim successful
			_log.debug(_imgLog);
			exit();
		}
		
		private function genSlimLogger(input:Object, output:Object, slimRatio:Number):String
		{
			var inputBytes:Number = 0;
			if (input) {
				inputBytes = MathUtil.fixed(input["size"] / 1024, 2);
			}
			var outputBytes:Number = 0;
			var outputSize:String = "0*0";
			if (output) {
				outputBytes = MathUtil.fixed(output["size"] / 1024, 2);
				outputSize = output["width"] + "*" + output["height"];
			}
			return _srcFile + "\n" + 
				"输入:" + inputBytes  + "kb, " + 
				"输出:" + outputBytes + "kb, " +
				"比率:" + MathUtil.fixed(slimRatio * 100, 2) + "%, " + 
				"尺寸:" + outputSize;
		}
		
		private function toDeleteApiKey(loader:URLLoader):void
		{
			if (!loader || !_apiKey) {
				return;
			}
			const jsonRet:String = loader.data as String;
			if (!jsonRet || 0 == jsonRet.length) {
				return;
			}
			const jsonObj:Object = JSON.parse(jsonRet);
			if (!jsonObj) {
				return;
			}
			const error:String = jsonObj["error"];
			if (error) {
				_log.warn("delete API key:{0} {1}", _apiKey, error);
				TinyKeystore.delErrKey(_apiKey);
			}
		}
	}
}

/**
 * 秘钥
 */
class TinyKeystore {
	private static const _apiKeys:Vector.<String> = Vector.<String>([
		"iO9fjIy5SZVHo3FNjzCL3iJY127AHE05",
		"GGZJSXGWDBc8mHLDAQMeW8ktyk8TmvQL",
		"ORRCXgdD6cN22D6pgWZvoe36WsVHckbN",
		"VPWBwRQnlPXPxDBszKi1c9FLCJr9HHL7",
		"fXTiTsDPgx5uQjJtRmU8hLvuon31tDKj",
		"rad38MpeXmFrqWWWNDjJJUBpQMrd7lip",
		"X4mu2MGlnaygtpQAiGBTkcfkcl5CYLw1",
		"q4ddOuH8LXJ9P5rWuJEjR5OE5f3Jc8Qt",
		"iVrcnsrw3AeJWSno8uwtFI89hLHciJ4F",
		"Vd8V4uJuMuBphugV5KIkcHXQfcf14I2A",
		"0UVuQUIRKZZlYFMDMBk3YqGUgLTopFs5",
		"qIsfUqTn1CCD6zFfZBWwELxJuJ0kvoZY",
		"zHjVvJ1uC5iw9BFGnpYS4D1K3bGkw65M",
		"nKNQJuF9mHdKXquv33nhPYAQwzfTbTpk",
		"snpmO1BqvA5RDq0yOnKfTrugkwPjaMp9",
		"UGu0vNnqvbWJsIqHCUQ5Ergd6fKZTpcx",
		"g1hA124HODN4vLBGZ8DccnyyIKs8qaOb",
		"kF64SE1p2meZi9BrVpRrAzD5yXv6mWU1",
		"YkYLXb7A4Re9cAoL9ye4RNW7ajWLYXlT",
		"aEDJkmclYSF0zVFE2YjOVNo2fqwm2YsD",
		"ey0PfofpW0EKmwqsjBWYWuXgDsEwVal0",
		"V5cw239ZfrK3oMdhcYs3XDLfveZtx7xC",
		"uqWxxtAntPmScAF5glmGdUOSSmI7WF7l",
		"O7NWVOIgr3iAsbS94zWB4eOxSpiQQVV5"
	]);
	
	public static function get size():uint
	{
		return _apiKeys.length;
	}
	
	public static function delErrKey(key:String):void
	{
		const pos:int = _apiKeys.lastIndexOf(key);
		if (-1 != pos) {
			_apiKeys.removeAt(pos);
		}
	}
	
	public static function popApiKey():String
	{
		const size:uint = _apiKeys.length;
		return (0 == size) ? null : _apiKeys[uint(Math.random() * size)];
	}
}

