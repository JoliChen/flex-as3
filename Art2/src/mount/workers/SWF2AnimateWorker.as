package mount.workers
{
	import com.joli.art2.affairs.task.TaskCase;
	import com.joli.modules.flash.animate.affairs.AnimateReq;
	import com.joli.modules.flash.animate.affairs.AnimateRet;
	import com.joli.modules.flash.animate.process.AnimateTask;
	
	import flash.utils.ByteArray;
	
	/**
	 * SWF动画导出线程
	 * @author Joli
	 * @date 2018-7-18 下午6:33:12
	 */
	public class SWF2AnimateWorker extends TaskCase
	{
		private var _task:AnimateTask;
		
		public function SWF2AnimateWorker()
		{
			super();
		}
		
		override protected function onResume(bytes:ByteArray):void
		{
			const req:AnimateReq = new AnimateReq();
			req.read(bytes);
			
			if (!_task) {
				_task = new AnimateTask(this);
			}
			_task.start(req);
		}
		
		override public function exit(code:int):void
		{
			const ret:AnimateRet = new AnimateRet(code);
			postExitMsg(ret);
		}
	}
}