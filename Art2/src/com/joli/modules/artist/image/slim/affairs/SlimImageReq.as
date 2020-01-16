package com.joli.modules.artist.image.slim.affairs
{
	import com.joli.art2.affairs.task.channel.ITaskRequest;
	
	import flash.utils.ByteArray;
	
	
	/**
	 * 图片压缩任务请求
	 * @author Joli
	 * @date 2018-8-30 下午3:16:17
	 */
	public class SlimImageReq implements ITaskRequest
	{
		/**
		 * 根据设定数据生成请求参数
		 * @param dao
		 * @return 
		 */		
		public static function create(dao:SlimImageDao):SlimImageReq
		{
			const req:SlimImageReq = new SlimImageReq();
			req._src_dir = dao.src_dir;
			req._dst_dir = dao.dst_dir;
			req._recursion = dao.recursion;
			return req;
		}
		
		private var _src_dir:String;
		private var _dst_dir:String;
		private var _recursion:Boolean;
		
		public function SlimImageReq()
		{
		}
		
		public function write(bytes:ByteArray):void
		{
			bytes.writeUTF(_src_dir);
			bytes.writeUTF(_dst_dir);
			bytes.writeBoolean(_recursion);
		}
		
		public function read(bytes:ByteArray):void
		{
			_src_dir = bytes.readUTF();
			_dst_dir = bytes.readUTF();
			_recursion = bytes.readBoolean();
		}
		
		public function get src_dir():String
		{
			return _src_dir;
		}
		
		public function get dst_dir():String
		{
			return _dst_dir;
		}
		
		public function get recursion():Boolean
		{
			return _recursion;
		}
	}
}