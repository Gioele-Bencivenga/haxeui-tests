package;

import abstractions.Product;
import haxe.ui.containers.windows.Window;
import components.AppSidebar;
import windows.MainWindow;
import haxe.ui.containers.SideBar;
import haxe.ui.data.ArrayDataSource;
import thx.csv.Csv;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.io.Bytes;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialogs.FileDialogTypes;
import haxe.ui.containers.dialogs.OpenFileDialog;
import haxe.ui.containers.windows.WindowManager;

@:build(haxe.ui.ComponentBuilder.build("assets/views/main-view.xml"))
class MainView extends VBox {
	public var winManInst:WindowManager;

	var _dataBank:ArrayDataSource<Product>;

	public function new() {
		super();
		winManInst = WindowManager.instance;
		// normally will default to "Screen" but lets change that to our container
		winManInst.container = windowContainer;
		winManInst.openMaximized = true;
	}

	public override function onReady() {
		createSidebar();
	}

	var _sidebar:SideBar;

	private function createSidebar() {
		_sidebar = new AppSidebar();
		_sidebar.position = "left";
		_sidebar.method = "float";
		_sidebar.modal = false;
	}

	@:bind(btn_sidebar, MouseEvent.CLICK)
	private function onShowSideBar(eventInfo:MouseEvent) {
		if (_sidebar.hidden) {
			_sidebar.show();
		} else {
			_sidebar.hide();
		}
	}

	public function createMainWindow() {
		var mainWindow = new MainWindow();

		if (_dataBank != null) {
			mainWindow.fillTable(_dataBank);
			// mainWindow.mainTable.dataSource = _dataBank;
		}

		return mainWindow;
	}

	public function positionWindow(window:Window, left = 30, top = 30, width = 400, height = 400):Window {
		window.left = left;
		window.top = top;
		window.width = width;
		window.height = height;

		return window;
	}

	@:bind(btn_import, MouseEvent.CLICK)
	private function onBtnImportClick(_eventInfo:MouseEvent) {
		var dialog = new OpenFileDialog();
		dialog.options = {
			readContents: true,
			title: "Open CSV File",
			readAsBinary: false,
			extensions: FileDialogTypes.ANY
		};
		dialog.onDialogClosed = function(_event) {
			if (_event.button == DialogButton.OK) {
				updateTabs(dialog.selectedFiles[0].text);
				// open main window to show the data that was just imported
				var window:Window = createMainWindow();
				window = positionWindow(window);
				WindowManager.instance.addWindow(window);
			}
		}
		dialog.show();
	}

	/**
	 * Thanks Ian Harrigan
	 * 
	 * source http://haxeui.org/explorer/#containers/dialogs/file_dialogs
	 * @param _byteData 
	 * @param _textData 
	 */
	private function updateTabs(_byteData:Bytes = null, _textData:String = null) {
		var indexToSelect = 0;
		if (_byteData != null && _textData == null) {
			_textData = _byteData.toString();
			indexToSelect = 0;
		} else if (_byteData == null && _textData != null) {
			_byteData = Bytes.ofString(_textData);
			indexToSelect = 1;
		}

		storeData(_textData);
	}

	private function storeData(_data:String) {
		var decoded = Csv.decode(_data);
		var dataSource = new ArrayDataSource<Product>();
		for (row in decoded) {
			dataSource.add(getProduct(row));
		}
		_dataBank = dataSource;
	}

	private function getProduct(_row:Array<String>):Dynamic {
		var product = new Product(_row[0], _row[1], _row[2], _row[3], _row[4]);

		return product;
	}

	// no clue what this does, find out
	// we need to extend View instead of VBox but don't know the import for View
	// private override function onHidden() {
	//    WindowManager.instance.reset();
	// }
}
