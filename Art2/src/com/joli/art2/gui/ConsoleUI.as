package com.joli.art2.gui
{
	import mx.core.ScrollPolicy;
	import mx.events.FlexEvent;

	/**
	 * 控制台UI
	 * @author Joli
	 */
	public final class ConsoleUI extends ConsoleUIX
	{
		private var _headLength:uint = 32;
		private var _discards:Number = 0.5;
		private var _maxLines:uint = 999;
		private var _logLines:uint = 0;
		
		public function ConsoleUI()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, onLoaded, false, 0, true);
			super();
		}

		private function onLoaded(event:FlexEvent):void
		{
			textArea.htmlText = "";
			textArea.selectable = true;
			textArea.editable = false;
			textArea.wordWrap = true;
			textArea.horizontalScrollPolicy = ScrollPolicy.OFF;
			textArea.verticalScrollPolicy = ScrollPolicy.ON;
			textArea.addEventListener(FlexEvent.VALUE_COMMIT, onValueCommit, false, 0, true);
		}
		
		/**
		 * 监听文本更新事件，自动滚动到底部。
		 */
		private function onValueCommit(event:FlexEvent):void
		{
			textArea.verticalScrollPosition = textArea.maxVerticalScrollPosition;
		}

		[inline]
		private function formatLine(line:String):String
		{
			return ['<font color="#', getColor(line), '">', line, "</font>", "\n"].join("");
		}
		
		private function getColor(line:String):String
		{
			var color:uint = 0x0;
			if (-1 != line.lastIndexOf("[DEBUG]", _headLength)) {
				color = 0x0;
			}  else if (-1 != line.lastIndexOf("[WARN]", _headLength)) {
				color = 0xFF00FF;
			} else if (-1 != line.lastIndexOf("[ERROR]", _headLength)) {
				color = 0xFF0000;
			} else if (-1 != line.lastIndexOf("[INFO]",  _headLength)) {
				color = 0xCC9966;
			} else if (-1 != line.lastIndexOf("[FATAL]", _headLength)) {
				color = 0xFF3300;
			}
			return color.toString(16);
		}
		
		/**
		 * 清理控制台
		 */
		public function clear():void
		{
			textArea.htmlText = "";
		}
		
		/**
		 * 添加文本
		 * @param msg:String 文本
		 */
		public function append(msg:String):void
		{
			var text:String = textArea.htmlText;
			text += formatLine(msg);
			if (_logLines < _maxLines) {
				_logLines++;
			} else {
				text = text.substr(text.lastIndexOf("\n", Math.ceil(_discards * text.length)));
				_logLines = Math.ceil(_discards * (_maxLines + 1));
			}
			textArea.htmlText = text;
		}
	}
}