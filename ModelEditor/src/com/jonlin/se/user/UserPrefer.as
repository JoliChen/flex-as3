package com.jonlin.se.user
{
	import com.jonlin.io.LocalStorage;
	
	/**
	 * 
	 * @author jonlin
	 * @date 2019-8-10 下午6:26:13
	 */
	public class UserPrefer extends LocalStorage
	{
		public static const FPS:String = "fps";
		public static const FRAME_TIME:String = "frameTime";
		public static const ANCHOR_X:String = "anchorX";
		public static const ANCHOR_Y:String = "anchorY";
		public static const SEAT_X:String = "seatX";
		public static const SEAT_Y:String = "seatY";
		public static const KEYBOARD_FACTOR:String = "keyboardFactor";
		
		public function UserPrefer(userName:String)
		{
			super(userName + "/prefer");
		}
		
		public function get fps():int
		{
			return optValue(FPS, 60);
		}
		public function set fps(i:int):void
		{
			put(FPS, i);
		}
		
		public function get frameTime():int
		{
			return optValue(FRAME_TIME, 5);
		}
		public function set frameTime(i:int):void
		{
			put(FRAME_TIME, i);
		}
		
		public function get anchorX():Number
		{
			return optValue(ANCHOR_X, 0.5);
		}
		public function set anchorX(n:Number):void
		{
			put(ANCHOR_X, n);
		}
		
		public function get anchorY():Number
		{
			return optValue(ANCHOR_Y, 0.3);
		}
		public function set anchorY(n:Number):void
		{
			put(ANCHOR_Y, n);
		}
		
		public function get seatX():Number
		{
			return optValue(SEAT_X, 0.5);
		}
		public function set seatX(n:Number):void
		{
			put(SEAT_X, n);
		}
		
		public function get seatY():Number
		{
			return optValue(SEAT_Y, 0.35);
		}
		public function set seatY(n:Number):void
		{
			put(SEAT_Y, n);
		}
		
		public function get keyboardFactor():Number
		{
			return optValue(KEYBOARD_FACTOR, 1);
		}
		public function set keyboardFactor(n:Number):void
		{
			put(KEYBOARD_FACTOR, n);
		}
	}
}