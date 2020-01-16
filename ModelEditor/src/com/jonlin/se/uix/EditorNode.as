package com.jonlin.se.uix
{
	import com.jonlin.an.geom.AnVec2;
	import com.jonlin.an.tick.AnTimeline;
	import com.jonlin.io.events.StorageEvent;
	import com.jonlin.se.MEMain;
	import com.jonlin.se.unit.EditAvatar;
	import com.jonlin.se.unit.IEditUnit;
	import com.jonlin.se.user.UserHabits;
	import com.jonlin.se.user.UserPrefer;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import spark.core.SpriteVisualElement;

	/**
	 * 编辑元素容器
	 * @author jonlin
	 * @date 2019-8-14 下午5:00:34
	 */
	public class EditorNode extends SpriteVisualElement
	{
		private var _uHabits:UserHabits;
		private var _uPrefer:UserPrefer;
		
		private var _timeline:AnTimeline;
		private var _avatar:EditAvatar;
		
		private var _editingUnit:IEditUnit;
		private var _dragingUnit:IEditUnit;
		private var _dragBeginXY:AnVec2;
		
		public function EditorNode()
		{
			super();
			_uHabits = MEMain.singleton.userHabits;
			_uPrefer = MEMain.singleton.userPrefer;
			_uHabits.addEventListener(StorageEvent.STORAGE_CHANGE, onChangeHabits, false, 0, true);
			_uPrefer.addEventListener(StorageEvent.STORAGE_CHANGE, onChangePrefer, false, 0, true);
			
			_timeline = new AnTimeline(_uPrefer.fps);
			_timeline.start();
			
			_avatar = new EditAvatar();
			_avatar.showBoundAble = _uHabits.showBoundAble;
			_timeline.add(_avatar);
			this.addChild(_avatar);
			
			_dragBeginXY = new AnVec2();
			this.scaleX = _uHabits.showFlipXAble ? -1 : 1;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage, false, 0, true);
		}
		
		private function onAddToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStage, false);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onPressKeyboard, false, 0, true);
		}
		
		private function onChangeHabits(event:StorageEvent):void
		{
			switch(event.filedKey)
			{
				case UserHabits.SHOW_BOUND_ABLE: {
					_avatar.showBoundAble = event.newValue;
					break;
				}
				case UserHabits.SHOW_FLIPX_ABLE: {
					this.scaleX = event.newValue ? -1 : 1;
					break;
				}
			}
		}
		
		private function onChangePrefer(event:StorageEvent):void
		{
			switch(event.filedKey)
			{
				case UserPrefer.FPS: {
					_timeline.fps = event.newValue;
					break;
				}
			}
		}
		
		private function onPressKeyboard(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.SPACE: {
					_avatar.isPlaying ? _avatar.pause() : _avatar.play();
					break;
				}
				case Keyboard.UP: {
					keyboardMove(0, -1);
					break;
				}
				case Keyboard.DOWN: {
					keyboardMove(0, 1);
					break;
				}
				case Keyboard.LEFT: {
					keyboardMove(1, 0);
					break;
				}
				case Keyboard.RIGHT: {
					keyboardMove(-1, 0);
					break;
				}
			}
		}
		
		private function keyboardMove(dx:Number=0, dy:Number=0):void
		{
			if (_editingUnit) {
				_editingUnit.dragMove(dx * _uPrefer.keyboardFactor, dy * _uPrefer.keyboardFactor);
			}
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			if (_dragingUnit) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false);
				_dragingUnit = null;
			}
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			if (event.target is IEditUnit) {
				_editingUnit = _dragingUnit = event.target as IEditUnit;
				_dragBeginXY.x = event.stageX;
				_dragBeginXY.y = event.stageY;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			}
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if (_dragingUnit) {
				var mx:Number = event.stageX, my:Number = event.stageY;
				_dragingUnit.dragMove(_dragBeginXY.x - mx, my - _dragBeginXY.y);
				_dragBeginXY.x = mx;
				_dragBeginXY.y = my;
			}
		}

		public function get avatar():EditAvatar 
		{
			return _avatar;
		}
		
		public function ctrlTimeline(toStop:Boolean):void
		{
			toStop ? _timeline.pause() : _timeline.start();
		}
	}
}