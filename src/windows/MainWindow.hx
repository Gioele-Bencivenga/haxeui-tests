package windows;

import abstractions.Product;
import haxe.ui.components.TextField;
import haxe.ui.events.UIEvent;
import haxe.ui.components.Column;
import haxe.ui.containers.Header;
import haxe.ui.containers.TableView;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;

using StringTools;

@:build(haxe.ui.macros.ComponentMacros.build("assets/windows/main-window.xml"))
class MainWindow extends TableWindow {
	public function new() {
		super();
		_tableView = mainTable;
		// find a way to automatically get headers inside windows instead of direct reference
		disableTextFieldsClickEvents(header1.findComponents(TextField));
		// fixes item renderers backgrounds
		_tableView.onScroll = preventItemRendererScrewups;
	}

	@:bind(button2, MouseEvent.CLICK)
	private function printStuff(_eventInfo:MouseEvent) {
		trace('DATASOURCE: ${mainTable.dataSource}');
	}

	@:bind(btn_delete, MouseEvent.CLICK)
	private function onBtnDeleteClick(eventInfo:MouseEvent) {
		removeTableItem(mainTable.selectedItem);
	}

	@:bind(btn_setColor, MouseEvent.CLICK)
	private function onBtnColorClick(eventInfo:MouseEvent) {
		colorTableItem(mainTable.selectedItem);
	}

	@:bind(idFilter, UIEvent.CHANGE)
	private function onIdFilterChange(_) {
		if (idFilter.text == null) {
			mainTable.dataSource.clearFilter();
			return;
		}
		var text = idFilter.text.trim().toLowerCase();
		if (text.length == 0) {
			mainTable.dataSource.clearFilter();
		} else {
			mainTable.dataSource.filter((index, product:Product) -> {
				if ((product.Id.toLowerCase() + " " + product.Name.toLowerCase()).contains(text)) {
					return true;
				}
				return false;
			});
		}
	}
}
