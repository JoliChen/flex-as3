package com.jm.ane.miss
{
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.utils.Dictionary;
	
	/**
	 * ANE操作接口
	 * @author jonlin
	 * @date 2020-2-21 下午5:54:39
	 */
	public class AneKit
	{
		private var _ec:ExtensionContext;
		private var _md:Dictionary;
		
		public function AneKit(extensionID:String)
		{
			_md = new Dictionary();
			_ec = ExtensionContext.createExtensionContext(extensionID, null);
			if (_ec)
			{
				_ec.addEventListener(StatusEvent.STATUS, onStatus);
			}
		}
		
		private function onStatus(event:StatusEvent):void
		{
			var method:String = event.code;
			var data:String = event.level;
			trace("[AneKit] onStatus " + method + " " + data);
			
			var callback:Function = _md[method];
			if (null != callback)
			{
				callback.apply(null, data);
			}
		}
		
		public function dispose():void
		{
			trace("[AneKit] dispose");
			if (_ec)
			{
				_ec.removeEventListener(StatusEvent.STATUS, onStatus);
				_ec.dispose();
				_ec = null;
			}
			if (_md)
			{
				this.cancelAll();
				_md = null;
			}
		}
		
		public function listen(method:String, callback:Function):void
		{
			trace("[AneKit] listen " + method);
			_md[method] = callback;
		}
		
		public function cancel(method:String):void
		{
			trace("[AneKit] cancel " + method);
			delete _md[method];
		}
		
		public function cancelAll():void
		{
			trace("[AneKit] cancelAll");
			var keys:Array = [];
			for (var method:String in _md)
			{
				keys.push(method);
			}
			for each (method in keys) 
			{
				delete _md[method];
			}
		}
		
		public function call(method:String, data:String):Object
		{
			trace("[AneKit] call " + method + " " + data);
			if (_ec)
			{
				return _ec.call(method, data);
			}
			return null;
		}
	}
}