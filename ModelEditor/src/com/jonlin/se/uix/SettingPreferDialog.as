package com.jonlin.se.uix
{
	import com.jonlin.se.MEMain;
	import com.jonlin.se.user.UserPrefer;
	
	import mx.events.FlexEvent;

	/**
	 * 首选配置 设置框
	 * @author jonlin
	 * @date 2019-8-7 下午2:55:24
	 */
	public class SettingPreferDialog extends SettingPreferUIX
	{
		private var _uPrefer:UserPrefer;
		
		public function SettingPreferDialog()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreate, false, 0, true);
			super();
		}
		
		private function onCreate(event:FlexEvent):void
		{
			_uPrefer = MEMain.singleton.userPrefer;
			kFactorText.text = _uPrefer.keyboardFactor.toString();
			frameTsText.text = _uPrefer.frameTime.toString();
			anchorXText.text = _uPrefer.anchorX.toString();
			anchorYText.text = _uPrefer.anchorY.toString();
			originXText.text = _uPrefer.seatX.toString();
			originYText.text = _uPrefer.seatY.toString();
			
			kFactorText.addEventListener(FlexEvent.ENTER, onPressEnter, false, 0, true);
			frameTsText.addEventListener(FlexEvent.ENTER, onPressEnter, false, 0, true);
			anchorXText.addEventListener(FlexEvent.ENTER, onPressEnter, false, 0, true);
			anchorYText.addEventListener(FlexEvent.ENTER, onPressEnter, false, 0, true);
			originXText.addEventListener(FlexEvent.ENTER, onPressEnter, false, 0, true);
			originYText.addEventListener(FlexEvent.ENTER, onPressEnter, false, 0, true);
		}
		
		private function onPressEnter(event:FlexEvent):void
		{
			switch(event.currentTarget)
			{
				case kFactorText: {
					_uPrefer.keyboardFactor = parseFloat(kFactorText.text);
					break;
				}
				case frameTsText: {
					_uPrefer.frameTime = parseInt(frameTsText.text);
					break;
				}
				case anchorXText: {
					_uPrefer.anchorX = parseFloat(anchorXText.text);
					break;
				}
				case anchorYText: {
					_uPrefer.anchorY = parseFloat(anchorYText.text);
					break;
				}
				case originXText: {
					_uPrefer.seatX = parseFloat(originXText.text);
					break;
				}
				case originYText: {
					_uPrefer.seatY = parseFloat(originYText.text);
					break;
				}
			}
		}
	}
}