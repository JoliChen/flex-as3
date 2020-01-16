package com.jonlin.an.sprite
{
	import com.jonlin.an.tick.ITickUnit;
	import com.jonlin.core.IDispose;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	/**
	 * 动画精灵
	 * @author jonlin
	 * @date 2019-8-10 上午11:12:11
	 */
	public class AnSprite extends Sprite implements ITickUnit, IDispose
	{
		protected var _canvas:Bitmap;
		protected var _spriteAnima:SpriteAnima;
		protected var _spriteFrame:SpriteFrame;
		protected var _totalFrames:uint;
		protected var _currentFrame:int;
		protected var _stride:int;
		protected var _isDead:Boolean;
		protected var _isOnce:Boolean;
		protected var _isPlay:Boolean;
		
		public function AnSprite()
		{
			super();
			_isOnce = false;
			_stride = 1;
			_canvas = new Bitmap();
			this.addChild(_canvas);
		}
		
		public function dispose():void
		{
			_isDead = true;
			this.clear();
			this.removeChild(_canvas);
		}
		
		public function clear():void
		{
			_isPlay = false;
			_totalFrames = 0;
			_currentFrame = 0;
			_spriteAnima = null;
			_spriteFrame = null;
			_canvas.bitmapData = null;
		}
		
		public function play():void
		{
			_isPlay = true;
		}
		
		public function pause():void
		{
			_isPlay = false;
		}
		
		public function gotoAndPlay(index:int):void
		{
			_isPlay = true;
			if (_totalFrames > 0) {
				gotoFrame(index % _totalFrames);	
			}
		}
		
		public function gotoAndStop(index:int):void
		{
			_isPlay = false;
			if (_totalFrames > 0) {
				gotoFrame(index % _totalFrames);
			}
		}

		public function set spriteAnima(data:SpriteAnima):void
		{
			_spriteAnima = data;
			_totalFrames = data.frames.length;
			if (_totalFrames > 0) {
				gotoFrame(0);
			}
		}
		public function get spriteAnima():SpriteAnima
		{
			return _spriteAnima;
		}
		
		public function get totalFrames():uint
		{
			return _totalFrames;
		}
		
		public function get currentFrame():int
		{
			return _currentFrame;	
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlay;
		}
		
		public function get isDead():Boolean
		{
			return _isDead;
		}
		
		public function set isOnce(b:Boolean):void
		{
			_isOnce = b;
		}
		public function get isOnce():Boolean
		{
			return _isOnce;
		}
		
		public function set stride(i:int):void
		{
			_stride = i;	
		}
		public function get stride():int
		{
			return _stride;
		}
		
		public function tick():void
		{
			if (_isPlay && _totalFrames > 0) {
				gotoFrame(_currentFrame + _stride);
			}
		}
		
		protected function gotoFrame(i:int):void
		{
			if (i >= _totalFrames) {
				if (_isOnce) {
					onOnceFinish();
					return;
				}
				i = i - _totalFrames;
			} else if (i < 0) {
				if (_isOnce) {
					onOnceFinish();
					return;
				}
				i = i + _totalFrames;
			}
			onEnterFrame(i);
		}
		
		protected function onOnceFinish():void
		{
			_isDead = true;
		}
		
		protected function onEnterFrame(i:int):void
		{
			_currentFrame = i;
			var sf:SpriteFrame = _spriteAnima.frames[i];
			if (sf) {
				if (_spriteFrame != sf) {
					_spriteFrame = sf;
					_canvas.bitmapData = sf.texture;
					_canvas.x = _spriteAnima.origin.x + _spriteFrame.origin.x;
					_canvas.y = _spriteAnima.origin.y + _spriteFrame.origin.y;
				}
			} else {
				_spriteFrame = null;
				_canvas.bitmapData = null;
			}
			if (_spriteAnima.evtMap && i in _spriteAnima.evtMap) {
				trace(_spriteAnima.evtMap[i]);
			}
		}
	}
}