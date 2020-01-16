package com.joli.modules.artist.image.slim.process
{
	import com.joli.art2.affairs.task.TaskExecutor;
	import com.joli.art2.affairs.task.TaskCase;
	import com.joli.modules.artist.image.slim.affairs.SlimImageReq;
	import com.joli.modules.artist.image.slim.process.utils.ISlimGroupHandler;
	import com.joli.modules.artist.image.slim.process.utils.SlimGroup;
	
	/**
	 * 压缩图片任务
	 * @author Joli
	 * @date 2018-8-30 下午4:06:10
	 */
	public class SlimImageTask extends TaskExecutor implements ISlimGroupHandler
	{
		private var _req:SlimImageReq;
		private var _callback:Function;
		private var _slimGroup:SlimGroup;
		
		public function SlimImageTask(asyncTask:TaskCase)
		{
			super(asyncTask);
			_slimGroup = new SlimGroup(5, this);
		}
		
		override public function dispose():void
		{
			super.dispose();
			if (null != _slimGroup) {
				_slimGroup.dispose();
				_slimGroup = null;
			}
			_req = null;
			_callback = null;
		}
		
		public function start(req:SlimImageReq, callback:Function):void
		{
			debug("启动压缩程序...");
			_req = req;
			_callback = callback;
			_slimGroup.start(req.src_dir, req.dst_dir, this, req.recursion);
		}
		
		public function onSlimComplete(errorCode:int):void {
			debug("all images slim done");
			if (null != _callback) {
				_callback(errorCode);
			}
		}		
	}
}