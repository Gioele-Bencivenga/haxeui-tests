package components;

import abstractions.Product;
import haxe.ui.core.Platform;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.events.ScrollEvent;
import haxe.ui.containers.TableView;
import haxe.ui.components.Label;
import haxe.ui.components.TextField;
import haxe.ui.core.ItemRenderer;
import haxe.ui.events.MouseEvent;

class EditableItemRenderer extends ItemRenderer {
	/**
	 * The item's label displays its text when not editing.
	 */
	private var _label:Label;

	public function new() {
		super();
		_label = new Label();
		_label.percentWidth = 100;
		_label.verticalAlign = "center";
		addComponent(_label);
	}

	public override function onReady() {
		super.onReady();
		var parentTable = findAncestor(TableView);
		if (parentTable != null) {
			parentTable.registerEvent(ScrollEvent.CHANGE, onTableScroll);
			parentTable.registerEvent(UIEvent.CHANGE, onTableSelectionChange);
		}
	}

	private function onTableScroll(_) {
		if (_CURRENT_RENDERER != null) {
			_CURRENT_RENDERER.saveEdit();
		}
	}

	private function onTableSelectionChange(_) {
		if (_CURRENT_RENDERER != null) {
			var parentTable = findAncestor(TableView);
			if (parentTable != null) {
				var thisIndex = parentTable.dataSource.indexOf(_data);
				if (thisIndex != parentTable.selectedIndex && _CURRENT_RENDERER == this) {
					_CURRENT_RENDERER.saveEdit();
				}
			}
		}
	}

	/**
	 * Function setting the label's text to the data found in the datasource, called every time a change is detected.
	 * @param data the data that was changed (check it out, it's a product)
	 */
	private override function onDataChanged(data:Dynamic) {
		super.onDataChanged(data);
		if (data == null) {
			return;
		}
		var product:Product = data;
		/**
		 * Ian: well, the reflect stuff is just setting values on a dynamic field, ie, the "data item"... if you had a typed datasource (new ArrayDataSource<MyObject>) then you wouldnt need that, its just about getting the data in and out of the item of the data source
		 */
		var value = Reflect.field(data, this.id);
		_label.text = Std.string(value);
	}

	@:bind(this, MouseEvent.DBL_CLICK)
	private function onDoubleClick(event:MouseEvent) {
		startEdit();
	}

	/**
	 * Used to save the value the field had when an edit was started.
	 * 
	 * Needed so `cancelEdit()` can revert back to this.
	 */
	private var originalValue:String = "";

	private function startEdit() {
		// if we double clicked on the current editable item renderer we don't need to start editing again
		if (_CURRENT_RENDERER == this) {
			return;
		}
		// if we are editing another item renderer we save the edit on that one before switching
		if (_CURRENT_RENDERER != null) {
			_CURRENT_RENDERER.saveEdit();
		}
		_CURRENT_RENDERER = this;
		originalValue = _label.text;
		// create a textfield with the same text as the label's and put it over the label
		var tf = getTextField();
		tf.text = _label.text;
		this.addComponent(tf);
		// Ian explains: when you scroll a scrollview, it disables all interactive components, but not visuallly, it just pauses all their interactive events - this is to stop misclicks and such when you are "drag scrolling"... so what was happening is it was disabling the interactivity, which is normal, but not reenabling it, im not 100% sure why yet, but, like the .focus=false, .focus=true thing, it smells like a bug / edge case - i just havent had time to look into it, so just worked around it
		tf.disableInteractivity(false);
		// focus it so the cursor is there (shouldn't be needed, working around a possible bug)
		tf.focus = false;
		tf.focus = true;
		// select all text inside the field
		tf.selectionStartIndex = 0;
		tf.selectionEndIndex = tf.text.length;
	}

	/**
	 * Saves the edited data in the table's dataSource and exits editing mode.
	 */
	private function saveEdit() {
		if (_TEXTFIELD != null) {
			saveEditedData();
			stopEdit();
		}
	}

	/**
	 * Saves the edited data updating the table's dataSource.
	 */
	private function saveEditedData() {
		// if we are currently editing this field
		if (_TEXTFIELD != null && _CURRENT_RENDERER == this) {
			// if data was actually changed
			if (_TEXTFIELD.text != _label.text) {
				_label.text = _TEXTFIELD.text;
				// set this itemRenderer's _data to label's text
				Reflect.setField(_data, this.id, _label.text);
				// update table's dataSource with this itemRenderer's data
				var parentTable = findAncestor(TableView);
				if (parentTable != null) {
					parentTable.dataSource.update(parentTable.selectedIndex, _data);
				}
			}
		}
	}

	/**
	 * Cancels the edit reverting the changes.
	 */
	private function cancelEdit() {
		if (_TEXTFIELD != null) {
			_TEXTFIELD.text = originalValue;
			saveEditedData();
			stopEdit();
		}
	}

	/**
	 * Remove textfield, stopping the edit.
	 * 
	 * Also sets `_CURRENT_RENDERER = null`, don't really remember why
	 */
	private function stopEdit() {
		this.removeComponent(_TEXTFIELD, false);
		_CURRENT_RENDERER = null;
	}

	/**
	 * Creates a new `TextField` if there is none, or gets the existing one.
	 * @return a `TextField`
	 */
	private function getTextField():TextField {
		if (_TEXTFIELD == null) {
			_TEXTFIELD = new TextField();
			_TEXTFIELD.percentWidth = 100;

			_TEXTFIELD.registerEvent(KeyboardEvent.KEY_DOWN, onTextFieldKey);
			_TEXTFIELD.registerEvent(UIEvent.CHANGE, onTextFieldChange);
		}

		return _TEXTFIELD;
	}

	//////////////////////////////////////////////////////////////////////////////////////////////////////
	// STATIC STUFF // to ensure there is only one instance of var, and only 1 set of events dispatched //
	//////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * The `TextField` that appears over `label` when editing.
	 */
	private static var _TEXTFIELD:TextField = null;

	/**
	 * There can only be 1 or 0 `EditableItemRenderer` at a time, if there is one it gets stored here.
	 */
	private static var _CURRENT_RENDERER:EditableItemRenderer = null;

	private static function onTextFieldKey(event:KeyboardEvent) {
		if (_CURRENT_RENDERER != null) {
			if (event.keyCode == Platform.instance.KeyEnter) {
				_CURRENT_RENDERER.saveEdit();
			} else if (event.keyCode == Platform.instance.KeyEscape) {
				_CURRENT_RENDERER.cancelEdit();
			}
		}
	}

	private static function onTextFieldChange(_) {
		if (_CURRENT_RENDERER != null) {
			_CURRENT_RENDERER.saveEditedData();
		}
	}
}
