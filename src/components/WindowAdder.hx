package components;

import haxe.ui.events.MouseEvent;
import haxe.ui.containers.Box;
import windows.AboutWindow;
import haxe.ui.containers.windows.Window;
import haxe.ui.events.UIEvent;
import haxe.ui.components.DropDown;

@:build(haxe.ui.ComponentBuilder.build("assets/components/window-adder.xml"))
class WindowAdder extends Box {
	var parentView:MainView;

	override function onReady() {
		super.onReady();

		parentView = findAncestor(MainView);
	}

	@:bind(dpd_windows, MouseEvent.CLICK)
	private function onDpdWindowsClick(event:UIEvent) {
		dpd_windows.focus = true;
	}

	@:bind(dpd_windows, UIEvent.CHANGE)
	private function onDpdWindowsSelection(event:UIEvent) {
		dpd_windows.text = '+ Add';
		var window:Window = null;
		switch event.target.text {
			case 'Main Window':
				window = parentView.createMainWindow();
				window = parentView.positionWindow(window);
			case 'About Window':
				window = new AboutWindow();
				window = parentView.positionWindow(window);
			default:
				window = parentView.createMainWindow();
				window = parentView.positionWindow(window);
		}
		parentView.winManInst.addWindow(window);
	}
}
