package com.jonlin.se.unit
{
	import com.jonlin.an.geom.AnSize;
	import com.jonlin.an.geom.AnVec2;
	import com.jonlin.an.sprite.AnSprite;
	import com.jonlin.se.support.EditData;
	
	import flash.display.Graphics;
	
	/**
	 * 编辑精灵基准对象
	 * @author jonlin
	 * @date 2019-8-7 下午5:32:04
	 */
	public class EditAvatar extends AnSprite implements IEditUnit
	{
		private var _showBoundAble:Boolean;
		private var _editData:EditData;
		private var _framesListener:Function;
		private var _anchorListener:Function;
						
		public function EditAvatar()
		{
			super();
		}
		
		override public function dispose():void
		{
			super.dispose();
			_framesListener = null;
			_anchorListener = null;
		}
		
		override public function clear():void
		{
			super.clear();
			if (_editData) {
				_editData.dispose();
				_editData = null;
			}
			this.drawBoundBox();
		}
		
		override protected function onEnterFrame(i:int):void
		{
			super.onEnterFrame(i);
			if (null != _framesListener) {
				_framesListener(_currentFrame, _totalFrames);
			}
		}
		
		public function setListeners(framesListener:Function, anchorListener:Function):void
		{
			_framesListener = framesListener;
			_anchorListener = anchorListener;
		}
		
		public function get showBoundAble():Boolean
		{
			return _showBoundAble;
		}
		public function set showBoundAble(b:Boolean):void
		{
			_showBoundAble = b;
			this.drawBoundBox();
		}

		private function drawBoundBox():void
		{
			var pen:Graphics = this.graphics;
			pen.clear();
			if (_showBoundAble && _spriteAnima && _editData) {
				var orig:AnVec2 = _spriteAnima.origin;
				var size:AnSize = _editData.size;
				pen.lineStyle(1, 0x00FF00);
				pen.drawRect(orig.x-1, orig.y-1, size.width+1, size.height+1);
				pen.endFill();
			}
		}

		public function set anchorX(ax:Number):void
		{
			if (_editData && this.modAnchorX(ax)) {
				this.onAnchorChange();
			}
		}
		public function set anchorY(ay:Number):void
		{
			if (_editData && this.modAnchorY(ay)) {
				this.onAnchorChange();
			}
		}
		
		private function modAnchorX(ax:Number):Boolean
		{
			if (_editData.modAnchorX(ax)) {
				if (_spriteAnima) {
					_editData.syncAnimaOriginX(_spriteAnima);
					if (_spriteFrame) {
						_canvas.x = _spriteAnima.origin.x + _spriteFrame.origin.x;
					}
				}
				return true;
			}
			return false;
		}
		
		private function modAnchorY(ay:Number):Boolean
		{
			if (_editData.modAnchorY(ay)) {
				if (_spriteAnima) {
					_editData.syncAnimaOriginY(_spriteAnima);
					if (_spriteFrame) {
						_canvas.y = _spriteAnima.origin.y + _spriteFrame.origin.y;
					}
				}
				return true;
			}
			return false;
		}
		
		private function onAnchorChange():void
		{
			this.drawBoundBox();
			if (null != _anchorListener) {
				_anchorListener(_editData.anchor);
			}
		}
		
		public function dragMove(dx:Number=0, dy:Number=0):void
		{
			if (_editData) {
				var mx:Boolean = this.modAnchorX(_editData.anchor.x + dx / _editData.size.width);
				var my:Boolean = this.modAnchorY(_editData.anchor.y + dy / _editData.size.height);
				if (mx || my) {
					this.onAnchorChange();
				}
			}
		}
		
		public function updateEdit(data:EditData):void
		{
			_editData = data;
			this.spriteAnima = data.buildAnima();
			this.onAnchorChange();
		}
		
		public function updateFrames(text:String):void
		{
			if (!_editData) {
				return;
			}
			_editData.parseLineText(text);
			if (_spriteAnima) {
				_editData.syncAnimaFrames(_spriteAnima);
				this.spriteAnima = _spriteAnima;
			}
		}
		
		public function get editData():EditData
		{
			return _editData;
		}
	}
}