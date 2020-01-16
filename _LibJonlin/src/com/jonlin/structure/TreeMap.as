package com.jonlin.structure
{
	/**
	 * 有序字典
	 * @author Joli
	 */
	public final class TreeMap
	{
		private var _keys:Array;
		private var _vals:Array;
		
		public function TreeMap(source:TreeMap=null)
		{
			if (source) {
				_keys = source._keys.concat();
				_vals = source._vals.concat();
			} else {
				_keys = [];
				_vals = [];
			}
		}
		
		[inline]
		public function copy():TreeMap
		{
			return new TreeMap(this);
		}
		
		[inline]
		public function clear():void
		{
			_vals.length = _keys.length = 0;
		}
		
		[inline]
		public function get length():uint
		{
			return _keys.length;
		}

		public function setValue(key:*, value:*):void
		{
			var i:int = _keys.lastIndexOf(key);
			if (-1 == i) {
				i = length;
				_keys[i] = key;
			}
			_vals[i] = value;
		}
		
		[inline]
		public function getValue(key:*):*
		{
			var i:int = _keys.lastIndexOf(key);
			return -1==i ? null : _vals[i];
		}
		
		[inline]
		public function getValueAt(pos:uint):*
		{
			return _vals[pos];
		}
		
		[inline]
		public function getKeyAt(pos:uint):*
		{
			return _keys[pos];
		}
		
		[inline]
		public function setPairAt(pos:uint, key:*, value:*):void
		{
			_keys[pos] = key;
			_vals[pos] = value;
		}
		
		[inline]
		public function pushPair(key:*, value:*):void
		{
			setPairAt(length, key, value);
		}
		
		public function delKey(key:*):void
		{
			const i:int = _keys.lastIndexOf(key);
			if (-1 != i) {
				delPos(i);
			}
		}
		
		public function delPos(pos:uint):void
		{
			_keys.splice(pos, 1);
			_vals.splice(pos, 1);
		}
		
		[inline]
		public function has(key:*):Boolean
		{
			return -1 != _keys.lastIndexOf(key);
		}
		
		[inline]
		public function keys():Array
		{
			return _keys.concat();
		}
		
		[inline]
		public function values():Array
		{
			return _vals.concat();
		}
	}
}