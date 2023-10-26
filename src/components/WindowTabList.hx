package components;

import haxe.ui.core.Component;
import haxe.ui.geom.Size;
import haxe.ui.events.MouseEvent;
import haxe.ui.components.Image;
import haxe.ui.containers.windows.Window;
import haxe.ui.components.Button;
import haxe.ui.containers.windows.WindowList;

@:build(haxe.ui.ComponentBuilder.build("assets/components/window-tablist.xml"))
class WindowTabList extends WindowList {
	override function onReady() {
		super.onReady();
	}
}

@:composite(WindowListItemLayout)
private class WindowListItem extends Button {
	public var relatedWindow:Window;

	public function new() {
		super();
		toggle = true;
		componentGroup = "windowlist";
		selected = true;

		iconPosition = "far-left";
		var image = new Image();
		image.id = "window-list-close-button";
		image.addClass("window-list-close-button");
		image.includeInLayout = false;
		image.scriptAccess = false;
		image.onClick = onCloseClicked;
		image.registerEvent(MouseEvent.MOUSE_DOWN, function(event:MouseEvent) {
			event.cancel();
		});
		addComponent(image);

		this.onChange = function(_) {
			if (this.selected == true) {
				var windowList = findAncestor(WindowList);
				if (relatedWindow.minimized) {
					windowList.windowManager.restoreWindow(relatedWindow);
				}
				windowList.windowManager.bringToFront(relatedWindow);
			}
		}

		var events = cast(this._internalEvents, ButtonEvents);
		events.recursiveStyling = false;
	}

	private function onCloseClicked(event:MouseEvent) {
		event.cancel();
		var windowList = findAncestor(WindowList);
		windowList.windowManager.closeWindow(relatedWindow);
	}
}

private class WindowListItemLayout extends ButtonLayout {
	private override function repositionChildren() {
		super.repositionChildren();

		var image = _component.findComponent("window-list-close-button", Image, false);
		if (image != null && image.hidden == false && component.componentWidth > 0) {
			image.top = Std.int((component.componentHeight / 2) - (image.componentHeight / 2)) + marginTop(image) - marginBottom(image);
			image.left = component.componentWidth - image.componentWidth - paddingRight + marginLeft(image) - marginRight(image);
		}
	}

	public override function calcAutoSize(exclusions:Array<Component> = null):Size {
		var size = super.calcAutoSize(exclusions);

		var image = _component.findComponent("window-list-close-button", Image, false);
		if (image != null && image.hidden == false) {
			size.width += image.width + horizontalSpacing;
		}

		return size;
	}
}