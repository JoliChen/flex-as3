package com.joli.art2.gui
{
	import com.joli.art2.features.ArtModuleBase;
	import mx.core.UIComponent;

	public final class OptionsUI extends OptionsUIX
	{
		public function OptionsUI()
		{
		}
		
		public function showModule(mod:ArtModuleBase):void {
			removeAllElements();
			var comp:UIComponent = mod.gui as UIComponent;
			if (comp) {
				// comp.width = this.width;
				// comp.height = this.height;
				// comp.validateNow();
				addElement(comp);
			}
		}
	}
}