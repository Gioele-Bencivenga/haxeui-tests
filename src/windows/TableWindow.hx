package windows;

import abstractions.Product;
import haxe.ui.data.ArrayDataSource;
import components.EditableItemRenderer;
import haxe.ui.components.TextField;
import haxe.ui.containers.TableView;
import haxe.ui.containers.windows.Window;
import haxe.ui.events.MouseEvent;

/**
 * A window whose main function is viewing and interacting with a `TableView`.
 */
class TableWindow extends Window {
	var _tableView:TableView;

	var selectedIndices = [];

	public function new() {
		super();
	}

	public function fillTable(_data:ArrayDataSource<String>) {
		_tableView.dataSource = _data;
	}

	/**
	 * Registers a mouse click event on all the passed `textFields` that calls e.cancel().
	 * 
	 * Was originally created to disable header click events in tables so that filters could be clicked without triggering a sort (due to a bug in haxeui bubbling up events to parents).
	 * @param textFields the `Array` of `TextField`s that we want to cancel the event for 
	 */
	private function disableTextFieldsClickEvents(textFields:Array<TextField>) {
		for (textField in textFields) {
			textField.registerEvent(MouseEvent.CLICK, (e) -> {
				e.cancel();
			});
		}
	}

	/**
	 * Correctly recalculates background color of item renderer on scroll so they don't have problems with virtual tables.
	 * @param _ 
	 */
	private function preventItemRendererScrewups(_) {
		var startI = Std.int(_tableView.vscrollPos / _tableView.itemHeight);
		var renderers = _tableView.findComponents("compounditemrenderer");
		for (c in renderers) {
			c.removeClass("colored");
		}
		for (i in selectedIndices) {
			var ind = i - startI;
			var line = renderers[ind];
			if (line != null)
				line.addClass("colored");
		}
	}

	/**
	 * Removes the passed `item` from `tableView.dataSource`.
	 * @param item the item we want to remove
	 */
	private function removeTableItem(item:EditableItemRenderer) {
		_tableView.dataSource.remove(item);
	}

	private function colorTableItem(item:EditableItemRenderer) {
		var startI = Std.int(_tableView.vscrollPos / _tableView.itemHeight);
		var c = _tableView.findComponents("compounditemrenderer")[_tableView.selectedIndex - startI];
		c.addClass("colored");
		selectedIndices.push(_tableView.selectedIndex);
	}
}
