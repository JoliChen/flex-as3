package com.joli.art2.gui
{
	import com.joli.art2.Art;
	import com.joli.art2.features.ArtModuleBase;
	
	import flash.utils.Dictionary;
	
	import mx.events.FlexEvent;
	import mx.events.ListEvent;

	/**
	 * 功能列表UI
	 * @author Adiers
	 */
	public final class FeatureUI extends FeatureUIX
	{
		private var _map:Dictionary;
		
		public function FeatureUI() {
			_map = new Dictionary(true);
			addEventListener(FlexEvent.CREATION_COMPLETE, onLoaded, false, 0, true);
			super();
		}
		
		private function onLoaded(event:FlexEvent):void
		{
			menu.selectable = true;
		}
		
		/**
		 * 选项变更事件
		 */
		override protected function menu_changeHandler(event:ListEvent):void
		{
			var module:ArtModuleBase = _map[event.itemRenderer.data["id"]];
			Art.singleton.selectModule(module);
		}
		
		public function initMenu(modules:Vector.<ArtModuleBase>):void
		{
			
			var menuData:Array = [];
			for (var i:int=0, e:int=modules.length; i<e; ++i) {
				var m:ArtModuleBase = modules[i];
				menuData.push({"id":m.id, "label":m.name});
				_map[m.id] = m;
			}
			menu.labelField = "label";
			menu.dataProvider = menuData;
		}
		
		public function setSelectIndex(index:int):void {
			menu.selectedIndex = index;
		}
	}
}