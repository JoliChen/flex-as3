package com.jonlin.se.support
{
	import com.adobe.utils.DictionaryUtil;
	import com.jonlin.an.geom.AnSize;
	import com.jonlin.an.geom.AnVec2;
	import com.jonlin.an.sprite.SpriteAnima;
	import com.jonlin.an.sprite.SpriteFrame;
	import com.jonlin.core.IDispose;
	import com.jonlin.se.MEMain;
	import com.jonlin.se.user.UserPrefer;
	import com.jonlin.utils.MathUtil;
	
	import flash.filesystem.File;
	import flash.utils.Dictionary;

	/**
	 * 编辑的数据
	 * @author jonlin
	 * @date 2019-8-22 下午3:08:03
	 */
	public class EditData implements IDispose
	{
		private static const PRECEISION:int = 6;
		private static const SEP1:String = "|";
		private static const SEP2:String = "_";
		
		public static const TYPE_SUITE:int = 1;
		public static const TYPE_COCOS:int = 2;
		
		private var _type:int;
		private var _images:Vector.<EditImage>;
		private var _source:File;
		
		private var _anchor:AnVec2;
		private var _line:EditProceLine;
		private var _size:AnSize;

		public function EditData(type:int, source:File, images:Vector.<EditImage>)
		{
			_type = type;
			_source = source;
			_images = images;
			_line = new EditProceLine();
			_size = new AnSize();
			_anchor = new AnVec2();
		}
		
		public function dispose():void
		{
			_source = null;
			_images = null;
			_size.width = _size.height = 0;
			_anchor.x = _anchor.y = 0;
			_line.clear();
		}
		
		private static function fixFloat(n:Number):Number
		{
			return MathUtil.fixed(n, PRECEISION);
		}

		public function fromDeafault():void
		{
			var uPrefer:UserPrefer = MEMain.singleton.userPrefer;
			_line.init(_images, uPrefer.frameTime);
			_anchor.x = uPrefer.anchorX;
			_anchor.y = uPrefer.anchorY;
			for each (var img:EditImage in _images) {
				if (img.data.width > _size.width) {
					_size.width = img.data.width;
				}
				if (img.data.height > _size.height) {
					_size.height = img.data.height;
				}
			}
		}
		
		public function fromConfig(config:Object):void
		{
			_line.decode(config["frames"], SEP1, SEP2);
			_size.width = config["width"];
			_size.height = config["height"];
			_anchor.x = config["x"];
			_anchor.y = config["y"];
		}
		
		public function makeConfig():Object
		{
			var obj:Object = {
				"frames": _line.encode(SEP1, SEP2),
				"width": _size.width,
				"height": _size.height,
				"x": _anchor.x,
				"y": _anchor.y
			};
			return obj;
		}
		
		public function parseLineText(text:String):void
		{
			_line.decode(text, SEP1, SEP2);
		}
		
		public function buildLineText():String
		{
			return _line.encode(SEP1, SEP2);
		}
		
		public function buildPublishText():String
		{
			return _line.buildPublish(SEP1, SEP2);
		}
		
		public function buildAnima():SpriteAnima
		{
			var anima:SpriteAnima = new SpriteAnima();
			this.syncAnimaFrames(anima);
			this.syncAnimaOriginX(anima);
			this.syncAnimaOriginY(anima);
			return anima;
		}
		
		public function syncAnimaFrames(anima:SpriteAnima):void
		{
			var events:Dictionary = new Dictionary();
			anima.frames.length = 0;
			var index:int = 0;
			for (var i:int=0, n:int=_line.length, j:int, img:EditImage, prc:EditProce, sf:SpriteFrame; i<n; ++i) {
				prc = _line.getProce(i);
				if (prc.isComment) {
					continue;
				}
				if (prc.event && prc.event.length > 0) {
					events[index] = prc.event;
				}
				if (prc.isEmpty) {
					sf = null;
				} else {
					sf = new SpriteFrame();
					img = this.findImage(prc.name);
					if (img != null) {
						sf.texture = img.data;
						sf.origin.x = img.orig.x;
						sf.origin.y = img.orig.y;
					}
				}
				for (j=prc.time; j>0; --j) {
					index++;
					anima.frames.push(sf);
				}
			}
			if (DictionaryUtil.count(events) > 0) {
				anima.evtMap = events;
			}
		}
		
		public function syncAnimaOriginX(anima:SpriteAnima):void
		{
			anima.origin.x = -fixFloat(_anchor.x * _size.width);
		}
		
		public function syncAnimaOriginY(anima:SpriteAnima):void
		{
			anima.origin.y = fixFloat((_anchor.y - 1) * _size.height);
		}

		private function findImage(name:String):EditImage
		{
			for each(var img:EditImage in _images) {
				if (img.name == name) {
					return img;
				}
			}
			return null;
		}
		
		public function modAnchorX(x:Number):Boolean
		{
			x = fixFloat(x);
			if (_anchor.x != x) {
				_anchor.x = x;
				return true;
			}
			return false;
		}
		
		public function modAnchorY(y:Number):Boolean
		{
			y = fixFloat(y);
			if (_anchor.y != y) {
				_anchor.y = y;
				return true;
			}
			return false;
		}

		public function get line():EditProceLine
		{
			return _line;
		}

		public function get anchor():AnVec2
		{
			return _anchor;
		}
		
		public function get size():AnSize
		{
			return _size;
		}
		
		public function get type():int
		{
			return _type;
		}
		
		public function get source():File
		{
			return _source;
		}
	}
}