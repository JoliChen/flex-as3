package com.jonlin.io
{
	import com.jonlin.io.events.StorageEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;

	/**
	 * 本地记录
	 * @author Joli
	 */
	public class LocalStorage extends EventDispatcher
	{
		/**
		 * 记录变更事件
		 */
		[Event(name="STORAGE_CHANGE", type="com.jonlin.io.events.StorageEventt")]
		
		/**
		 * 记录删除事件
		 */
		[Event(name="STORAGE_DELETE", type="com.jonlin.io.events.StorageEventt")]
		
		private var _name:String;
		private var _db:SharedObject;
		
		/**
		 * 构造函数
		 * @param name:String 文件名称
		 * 
		 * Windows XP
		 * 网络访问： C:\Documents and Settings\[你的用户名]\Application Data\Macromedia\Flash Player\#SharedObjects\[随机码]\[网站域名]\[页面目录]\[sharedobject实际对象名].sol
		 * AIR 程序：C:\Documents and Settings\[你的用户名]\Application Data\[AIR 程序逆域名 ]\Local Store\#SharedObjects\[flash程序名].swf\[sharedobject实际对象名].sol
		 * 
		 * Windows Vista
		 * C:/Users/username/[你的用户名]/AppData/Roaming/Macromedia/Flash Player/#SharedObjects/[网站域名]/[页面目录]/[flash程序名].swf/[sharedobject实际对象名].sol
		 * 
		 * Linux/Unix
		 * /home/[你的用户名]/.macromedia/Flash_Player/#SharedObjects/[网站域名]/[页面目录] /[flash程序名].swf/[sharedobject实际对象名].sol
		 * 
		 * Mac OS X:
		 * 网络访问： Macintosh HD:Users:[你的用户名]:Library:Preferences:Macromedia:Flash Player:#SharedObjects:[随机码]:[网站域名]:[页面目录]\[sharedobject实际对象名]sol
		 * AIR 程序：Macintosh HD:Users:[你的用户名]:Library:Preferences:[AIR 程序逆域名 ]:Local Store:#SharedObjects:[flash程序名].swf\[sharedobject实际对象名].sol
		 */
		public function LocalStorage(name:String)
		{
			_name = name;
			try {
				_db = SharedObject.getLocal(name, "/");
			} catch(error:Error) {
				trace(error);
			}
		}
		
		/**
		 * 获取属性
		 * @param key
		 * @return 
		 */		
		public function getValue(key:*):*
		{
			return _db.data[key];
		}
		
		/**
		 * 获取属性（先判断是否存在，如不存在则返回默认值。）
		 * @param key
		 * @param defaultValue
		 * @return 
		 */		
		public function optValue(key:*, defaultValue:*=undefined):*
		{
			return has(key) ? _db.data[key] : defaultValue;
		}
		
		/**
		 * 存储属性
		 * @param key
		 * @param value
		 * @param flush
		 * @return 
		 */		
		public function put(key:*, value:*, flush:Boolean=true):*
		{
			var oldValue:* = _db.data[key];
			if (oldValue !== value) {
				_db.data[key] = value;
				if (flush) {
					submit();
				}
				if (hasEventListener(StorageEvent.STORAGE_CHANGE)) {
					dispatchEvent(new StorageEvent(StorageEvent.STORAGE_CHANGE, key, oldValue, value));
				}
			}
			return oldValue;
		}

		/**
		 * 删除key属性
		 * @param key
		 * @param flush
		 * @return 
		 */		
		public function del(key:*, flush=true):*
		{
			var oldValue:* = _db.data[key];
			if(delete _db.data[key]) {
				if (flush) {
					submit();
				}
				if (hasEventListener(StorageEvent.STORAGE_DELETE)) {
					dispatchEvent(new StorageEvent(StorageEvent.STORAGE_DELETE, key, oldValue));
				}
			}
			return oldValue;
		}
		
		/**
		 * 判断是否包含key属性
		 * @param key
		 * @return 
		 */		
		public function has(key:*):Boolean
		{
			return _db.data.hasOwnProperty(key);
		}
		
		/**
		 * 强制保存到本地一次
		 */		
		public function submit() : void
		{
			var ret:String = null;
			try {
				ret = _db.flush();
			} catch(error:Error) {
				trace(error);
			}
			if (ret == SharedObjectFlushStatus.FLUSHED) {
				trace(_name, "SharedObjectFlushStatus.FLUSHED");
			} else if (ret == SharedObjectFlushStatus.PENDING) {
				trace(_name, "SharedObjectFlushStatus.PENDING");
				_db.addEventListener(NetStatusEvent.NET_STATUS, onDiskStatus);
			}
		}
		
		private function onDiskStatus(event:NetStatusEvent):void 
		{
			_db.removeEventListener(NetStatusEvent.NET_STATUS, onDiskStatus);
			if (event.info.code == "SharedObject.Flush.Success") {
				submit();
			} else if(event.info.code == "SharedObject.Flush.Failed") {
				trace("SharedObject.Flush.Failed");
			}
		}
	}
}