package com.joli.modules.flash.animate
{
	import com.joli.art2.Art;
	import com.joli.art2.ArtFactory;
	import com.joli.art2.affairs.IAffairsDAO;
	import com.joli.art2.affairs.IAffairsTask;
	import com.joli.art2.affairs.task.TaskHost;
	import com.joli.art2.features.ArtModuleBase;
	import com.joli.art2.features.IModuleGUI;
	import com.joli.modules.flash.animate.affairs.AnimateReq;
	import com.joli.modules.flash.animate.affairs.AnimateRet;
	import com.joli.modules.flash.animate.affairs.AnimateDao;
	import com.joli.modules.flash.animate.gui.SWFAnimateUI;
	
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	/**
	 * SWF动画导出模块
	 * @author Joli
	 * @date 2018-7-17 下午5:40:02
	 */
	public final class SWFAnimateModule extends ArtModuleBase implements IAffairsTask
	{
		private const worker:String = "SWF2AnimateWorker";
		private var _session:TaskHost;
		private var _isBusy:Boolean;
		
		private var _gui:SWFAnimateUI;
		private var _dao:AnimateDao;
		
		public function SWFAnimateModule(id:uint, name:String)
		{
			super(id, name);
			_isBusy = false;
			_dao = new AnimateDao(ArtFactory.DAO_FlashAnimate);
		}
		
		override public function dispose():void
		{
			super.dispose();
			_gui = null;
			_dao = null;
			if (_session) {
				_session.dispose();
				_session = null;
			}
		}
		
		public override function get gui():IModuleGUI
		{
			if (!_gui) {
				_gui = new SWFAnimateUI(this, _dao);
			}
			return _gui;
		}
		
		public function get dao():IAffairsDAO
		{
			return _dao;
		}
		
		public function resume():void
		{
			if (_isBusy) {
				Alert.show("动画导出程序正忙！");
				return;
			}
			const req:AnimateReq = AnimateReq.create(_dao);
			_isBusy = true;
			
			Art.singleton.clearConsole();
			if (!_session) {
				_session = new TaskHost(worker);
			}
			_session.start(req, onTaskExit);
		}
		
		private function onTaskExit(bytes:ByteArray):void
		{
			_isBusy = false;
			const ret:AnimateRet = new AnimateRet();
			ret.read(bytes);
			Art.logger(worker).debug("exit:{0}", ret.exitCode);			
		}
	}
}