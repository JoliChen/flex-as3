package com.jonlin.an.tick
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	/**
	 * 时间轴
	 * @author jonlin
	 * @date 2019-8-10 上午11:12:11
	 */
	public class AnTimeline
	{
		private var _units:Vector.<ITickUnit>;
		private var _timer:Timer;
		private var _fps:int;
		
		public function AnTimeline(frameRate:int)
		{
			_units = new Vector.<ITickUnit>();
			_fps = frameRate;
			_timer = new Timer(1000.0 / frameRate);
			_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
		}
		
		public function get isRunning():Boolean
		{
			return _timer.running;
		}

		private function onTimer(event:TimerEvent):void
		{
			for (var i:int=0, n:int=_units.length; i<n; ++i) {
				_units[i].tick();
			}
			for (i=_units.length-1; i>-1; --i) {
				if (_units[i].isDead) {
					_units.removeAt(i);
				}
			}
		}
		
		public function start():void
		{
			_timer.start();
		}
		
		public function pause():void
		{
			_timer.stop();
		}
		
		public function set fps(frameRate:int):void
		{
			if (0 < frameRate < 61) {
				_fps = frameRate;
				_timer.delay = 1000.0 / frameRate;
			} else {
				trace("unsupport fps", frameRate);
			}
		}
		
		public function get fps():int
		{
			return _fps;
		}
		
		public function add(unit:ITickUnit):void
		{
			if (_units.lastIndexOf(unit) == -1) {
				_units.push(unit);
			}
		}
		
		public function has(unit:ITickUnit):Boolean
		{
			return _units.indexOf(unit) != -1;
		}
	}
}