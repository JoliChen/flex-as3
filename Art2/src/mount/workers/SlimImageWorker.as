package mount.workers
{
	import com.joli.art2.affairs.task.TaskCase;
	import com.joli.modules.artist.image.slim.affairs.SlimImageReq;
	import com.joli.modules.artist.image.slim.affairs.SlimImageRet;
	import com.joli.modules.artist.image.slim.process.SlimImageTask;
	
	import flash.utils.ByteArray;
	
	/**
	 * 压缩图片线程
	 * @author Joli
	 * @date 2018-8-30 下午4:04:09
	 */
	public class SlimImageWorker extends TaskCase
	{
		private var _task:SlimImageTask;
		
		public function SlimImageWorker()
		{
			super();
		}
		
		override protected function onResume(bytes:ByteArray):void
		{
			const req:SlimImageReq = new SlimImageReq();
			req.read(bytes);
			
			if (!_task) {
				_task = new SlimImageTask(this);
			}
			_task.start(req, function(exitCode:int):void {
				exit(exitCode);
			});
		}
		
		override public function exit(code:int):void
		{
			const ret:SlimImageRet = new SlimImageRet(code);
			postExitMsg(ret);
		}
	}
}