package
{
	import com.jp.ane.AneKit;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	/**
	 * 
	 * @author jonlin
	 * @date 2020-2-22 下午3:52:52
	 */
	public class MissPro extends Sprite
	{
		public function MissPro()
		{
			super();
			
			// 支持 autoOrient
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var kit:AneKit = new AneKit("com.jm.ane.miss");
			kit.call("alert", "提示提示我");
			kit.listen("onAlert", function(data:String):void{
				trace("onalert:" + data);
			});
		}
	}
}