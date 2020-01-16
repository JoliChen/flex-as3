package com.joli.modules.flash.animate.affairs
{
	import com.joli.art2.affairs.task.channel.ITaskRequest;
	
	import flash.utils.ByteArray;
	
	/**
	 * 导出SWF动画请求
	 * @author Joli
	 * @date 2018-7-18 下午3:09:24
	 */
	public class AnimateReq implements ITaskRequest
	{
		/**
		 * 根据设定数据生成请求参数
		 * @param dao
		 * @return 
		 */		
		public static function create(dao:AnimateDao):AnimateReq
		{
			var req:AnimateReq = new AnimateReq();
			req._src_files = dao.src_files;
			req._dest_dir = dao.dest_dir;
			req._make_dir = dao.make_dir;
			req._texturepacker = dao.texturepacker;
			req._tp_maxsize = dao.tp_maxsize;
			req._tp_scale = dao.tp_scale;
			req._tp_premultiplyAlpha = dao.tp_premultiplyAlpha;
			req._slim_images = dao.slimImages;
			req._print_profile = dao.print_profile;
			req._animate_format = dao.animate_format;
			req._animate_source = dao.animate_source;
			req._print_mc_warns = dao.print_mc_warns;
			req._animate_id_set = dao.animate_id_set;
			req._auto_pow2_limit = dao.auto_pow2_limit;
			return req;
		}
		
		
		private var _src_files:Array;
		private var _dest_dir:String;
		private var _make_dir:String;
		private var _texturepacker:String;
		private var _tp_maxsize:int;
		private var _tp_scale:Number;
		private var _tp_premultiplyAlpha:Boolean;
		private var _slim_images:Boolean;
		private var _print_profile:Boolean;
		private var _print_mc_warns:Boolean;
		private var	_animate_format:String;
		private var _animate_source:String;
		private var _animate_id_set:String;
		private var _auto_pow2_limit:Number;
		
		public function AnimateReq() {}
		
		public function write(bytes:ByteArray):void
		{
			bytes.writeInt(_src_files.length);
			for (var i:int=0, len:int=_src_files.length; i<len; ++i) {
				bytes.writeUTF(_src_files[i]);
			}
			bytes.writeUTF(_dest_dir);
			bytes.writeUTF(_make_dir);
			bytes.writeUTF(_texturepacker);
			bytes.writeShort(_tp_maxsize);
			bytes.writeFloat(_tp_scale);
			bytes.writeBoolean(_tp_premultiplyAlpha);
			bytes.writeBoolean(_slim_images);
			bytes.writeBoolean(_print_profile);
			bytes.writeBoolean(_print_mc_warns);
			bytes.writeUTF(_animate_format);
			bytes.writeUTF(_animate_source);
			bytes.writeUTF(_animate_id_set);
			bytes.writeFloat(_auto_pow2_limit);
		}
		
		public function read(bytes:ByteArray):void
		{
			_src_files = [];
			for (var i:int=0, len:int=bytes.readInt(); i<len; ++i) {
				_src_files[i] = bytes.readUTF();
			}
			_dest_dir = bytes.readUTF();
			_make_dir = bytes.readUTF();
			_texturepacker = bytes.readUTF();
			_tp_maxsize = bytes.readShort();
			_tp_scale = bytes.readFloat();
			_tp_premultiplyAlpha = bytes.readBoolean();
			_slim_images = bytes.readBoolean();
			_print_profile = bytes.readBoolean();
			_print_mc_warns = bytes.readBoolean();
			_animate_format = bytes.readUTF();
			_animate_source = bytes.readUTF();
			_animate_id_set = bytes.readUTF();
			_auto_pow2_limit = bytes.readFloat();
		}
		
		public function get src_files():Array
		{
			return _src_files;
		}
		
		public function get dest_dir():String
		{
			return _dest_dir;
		}
		
		public function get make_dir():String
		{
			return _make_dir;
		}
		
		public function get texturepacker():String
		{
			return _texturepacker;
		}
		
		public function get tp_maxsize():int
		{
			return _tp_maxsize;
		}
		
		public function get tp_scale():Number
		{
			return _tp_scale;
		}
		
		public function get tp_premultiplyAlpha():Boolean
		{
			return _tp_premultiplyAlpha;
		}
		
		public function get slim_images():Boolean
		{
			return _slim_images;
		}
		
		public function get print_profile():Boolean
		{
			return _print_profile;
		}
		
		public function get print_mc_warns():Boolean
		{
			return _print_mc_warns;
		}
		
		public function get animate_format():String
		{
			return _animate_format;
		}

		public function get animate_source():String
		{
			return _animate_source;
		}

		public function get animate_id_set():String
		{
			return _animate_id_set;
		}
		
		public function get auto_pow2_limit():Number
		{
			return _auto_pow2_limit;
		}
	}
}