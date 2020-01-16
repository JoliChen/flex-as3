package com.jonlin.event
{
	import com.jonlin.core.IDispose;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * 事件代理
	 * @author Joli
	 * @date 2018-7-13 下午6:06:46
	 */
	public class EventProxy implements IEventDispatcher, IDispose
	{
		private var _dispatcher:EventDispatcher;
		private var _bubbledMap:Dictionary;
		private var _captureMap:Dictionary;
//		private var _eventCache:Dictionary;
//		private var _cacheLimit:int;
		
		public function EventProxy(dispatcher:EventDispatcher=null)
		{
			if (!dispatcher) {
				_dispatcher = new EventDispatcher();
			} else {
				_dispatcher = dispatcher;
			}
			_bubbledMap = new Dictionary();
			_captureMap = null;
//			_cacheLimit = cacheLimit;
//			if (cacheLimit != 0) {
//				_cacheLimit = cacheLimit > 0 ? cacheLimit : int.MAX_VALUE;
//				_eventCache = new Dictionary();
//			} else {
//				_cacheLimit = 0;
//			}
		}
		
		public function dispose():void
		{
			if (_bubbledMap)  {
				removeAllBubbledListener();
				_bubbledMap = null;
			}
			if (_captureMap)  {
				removeAllCaptureListener();
				_captureMap = null;
			}
//			if (_eventCache) {
//				removeAllCachedEvent();
//				_eventCache = null;
//			}
			_dispatcher = null;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if (!regist(type, listener, useCapture)) {
				throw new Error("listener has already existed");
				return;
			}
			_dispatcher.addEventListener(type, listener, useCapture, priority, true);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
			remove(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
//			if (event is IReusableEvent) {
//				cachingEvent(event.type, event as IReusableEvent);
//			}
			return _dispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return _dispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return _dispatcher.willTrigger(type);
		}
		
		private function regist(type:String, listener:Function, useCapture:Boolean=false):Boolean 
		{
			var dict:Dictionary = null;
			if (useCapture) {
				if (!_captureMap) {
					_captureMap = new Dictionary();
				}
				dict = _captureMap;
			} else {
				dict = _bubbledMap;
			}
			var listenerZone:Vector.<Function> = null;
			if (type in dict) {
				listenerZone = dict[type];
			} else {
				listenerZone = new Vector.<Function>();
				dict[type] = listenerZone;
			}
			if (listenerZone.indexOf(listener) != -1) {
				return false;
			}
			listenerZone.push(listener);
			return true;
		}
		
		private function remove(type:String, listener:Function, useCapture:Boolean=false):void 
		{
			var dict:Dictionary = null;
			if (useCapture) {
				if (!_captureMap) {
					return;
				}
				dict = _captureMap;
			} else {
				dict = _bubbledMap;
			}
			if (!(type in dict)) {
				return;
			}
			var listenerZone:Vector.<Function> = dict[type];
			var index:int = listenerZone.indexOf(listener);
			if (index != -1)  {
				listenerZone.removeAt(index);
			}
		}
		
		public function removeAllCaptureListener():void 
		{
			for(var type:String in _captureMap) {
				var listenerZone:Vector.<Function> = _captureMap[type];
				for(var i:int=listenerZone.length-1; i>-1; --i) {
					_dispatcher.removeEventListener(type, listenerZone[i], true);
				}
			}
		}
		
		public function removeAllBubbledListener():void 
		{
			for(var type:String in _bubbledMap) {
				var listenerZone:Vector.<Function> = _bubbledMap[type];
				for(var i:int=listenerZone.length-1; i>-1; --i) {
					_dispatcher.removeEventListener(type, listenerZone[i], false);
				}
			}
		}
		
//		public function removeAllCachedEvent():void
//		{
//			for each(var eventZone:Vector.<Function> in _eventCache) {
//				eventZone.length = 0;
//			}
//		}
//		
//		public function cachingEvent(type:String, event:IReusableEvent):void
//		{
//			var eventZone:Vector.<IReusableEvent> = null;
//			if (type in _eventCache) {
//				eventZone = _eventCache[type];
//			} else {
//				eventZone = new Vector.<IReusableEvent>();
//				_eventCache[type] = eventZone;
//			}
//			if (eventZone.length < _cacheLimit) {
//				if (eventZone.indexOf(event) == -1) {
//					eventZone.push(event);
//				}
//			}
//		}
//		
//		public function obtainEvent(type:String):IReusableEvent
//		{
//			if (!(type in _eventCache)) {
//				return null;
//			}
//			var eventZone:Vector.<IReusableEvent> = _eventCache[type];
//			if (eventZone.length > 0) {
//				var event:IReusableEvent = eventZone.pop();
//				event.onReuse();
//				return event;
//			}
//			return null;
//		}
	}
}