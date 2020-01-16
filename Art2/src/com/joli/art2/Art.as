package com.joli.art2
{
	import com.joli.art2.console.LogColor;
	import com.joli.art2.console.ConsoleTarget;
	import com.joli.art2.features.ArtModuleBase;
	import com.joli.art2.gui.ConsoleUI;
	import com.joli.art2.gui.FeatureUI;
	import com.joli.art2.gui.OptionsUI;
	import com.jonlin.utils.ReflectUtil;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	/**
	 * 工具总控制器
	 * @author Joli
	 * @date 2018-7-16 下午6:06:09
	 */
	public final class Art
	{
		public static const singleton:Art = new Art();
		
		private var _window:Art2;
		private var _consoleUI:ConsoleUI;
		private var _featureUI:FeatureUI;
		private var _optionsUI:OptionsUI;
		
		private var _isCommandline:Boolean;
		private var _modules:Vector.<ArtModuleBase>;
		private var _selectedModule:ArtModuleBase;
		
		public function Art()
		{
			_isCommandline = false;
		}
		
		/**
		 * 是否命令行模式运行 
		 * @return 
		 */		
		public function get isCommandline():Boolean
		{
			return _isCommandline;
		}
		
		/**
		 * 载入UI 
		 * @param window 窗口
		 * @param consoleUI 控制台
		 * @param featureUI 功能菜单
		 * @param optionsUI 操作区域
		 */		
		public function setup(window:Art2, consoleUI:ConsoleUI, featureUI:FeatureUI, optionsUI:OptionsUI):void
		{
			_window = window;
			_consoleUI = consoleUI;
			_optionsUI = optionsUI;
			_featureUI = featureUI;
			init();
		}
		
		/**
		 * 命令行运行
		 * @param parameter 命令行参数
		 */			
		public function exec(parameter:Array):void
		{
			if (!parameter || parameter.length == 0) {
				if (!_selectedModule) {
					activeModule(_modules[_modules.length-1]);
				}
			} else {
				_isCommandline = true;
				_window.minimize();
				// exec commandline
			}		
		}
		
		private function init():void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			NativeApplication.nativeApplication.autoExit = true;
			
			initLog();
			_modules = ArtFactory.load();
			_featureUI.initMenu(_modules);
		}
		
		private function initLog():void
		{
			var console:ConsoleTarget = new ConsoleTarget(_consoleUI);
			console.includeDate = true;
			console.includeTime = true;
			console.includeLevel = true;
			console.includeCategory = true;
			// console.filters = ["com.joli.*"];
			console.level = LogColor.DEBUG;
			Log.addTarget(console);
		}
		
		public function activeModule(module:ArtModuleBase):void 
		{
			selectModule(module);
			_featureUI.setSelectIndex(_modules.indexOf(module));
		}
		
		public function selectModule(module:ArtModuleBase):void
		{
			_selectedModule = module;
			_optionsUI.showModule(module);
		}
		
		public function clearConsole():void
		{
			_consoleUI.clear();
		}
		
		public static function logger(catalog:*):ILogger
		{
			var logger:ILogger = null;
			if (catalog is String) {
				logger = Log.getLogger(catalog as String);
			} else {
				logger = Log.getLogger(ReflectUtil.getClassPath(catalog));
			}
			return logger;
		}
	}
}