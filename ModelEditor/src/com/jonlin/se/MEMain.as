package com.jonlin.se
{
	import com.jonlin.se.uix.EditorView;
	import com.jonlin.se.user.UserPrefer;
	import com.jonlin.se.user.UserTPConf;
	import com.jonlin.se.user.UserHabits;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	
	import spark.components.Application;

	public class MEMain
	{
		public static const singleton:MEMain = new MEMain();
		private static const AUTO_MODE:int = 1;
		private static const EDIT_MODE:int = 2;

		private var uiApp:Application;
		private var osApp:NativeApplication;
		private var osWin:NativeWindow;
		private var launchOpts:Array;
		private var launchStep:int;
		private var editView:EditorView;
		
		private var _uHabits:UserHabits;
		private var _uPrefer:UserPrefer;
		private var _uTPConf:UserTPConf;
		
		private var runMode:int = 0;
		
		public function MEMain()
		{
			if (singleton) {
				throw new Error("repeat creating a singleton");
			}
			launchStep = 0;
		}
		
		/**
		 * 用户习惯记录
		 */
		public function get userHabits():UserHabits
		{
			return _uHabits;
		}
		
		/**
		 * 用户首选配置
		 */
		public function get userPrefer():UserPrefer
		{
			return _uPrefer;
		}
		
		/**
		 * 用户TP配置
		 */
		public function get userTPConf():UserTPConf
		{
			return _uTPConf;
		}
		
		public function initialize():void
		{
			_uHabits = new UserHabits("root");
			_uPrefer = new UserPrefer("root");
			_uTPConf = new UserTPConf("root");
			osApp = NativeApplication.nativeApplication;
			osApp.addEventListener(InvokeEvent.INVOKE, invokeHandler);
		}
		
		private function invokeHandler(event:InvokeEvent):void
		{
			osApp.removeEventListener(InvokeEvent.INVOKE, invokeHandler);
			launchOpts = event.arguments;
			if (++launchStep > 1) {
				didLaunching();
			}
		}
		
		public function uiComplete(app:Application, window:NativeWindow):void
		{
			uiApp = app;
			osWin = window;
			if (++launchStep > 1) {
				didLaunching();
			}
		}
		
		private function didLaunching():void
		{
			launchStep = 0;
			if (!launchOpts || launchOpts.length <= 0) {
				uiApp.addEventListener(Event.ENTER_FRAME, onLoadEditor);
			} else {
				openCommand(launchOpts);
			}
		}
		
		private function onLoadEditor(event:Event):void
		{
			uiApp.removeEventListener(Event.ENTER_FRAME, onLoadEditor);
			openEditor();
		}
		
		private function openCommand(options:Array):void
		{
			trace("open command", options);
			runMode = AUTO_MODE;
			if (osWin.active) {
				osWin.minimize();
			}
		}
		
		private function openEditor():void
		{
			trace("open editor");
			runMode = EDIT_MODE;
			if (!osWin.active) {
				osWin.activate();
			}
			if (!editView) {
				editView = new EditorView();
				uiApp.addElement(editView);
			}
		}
	}
}