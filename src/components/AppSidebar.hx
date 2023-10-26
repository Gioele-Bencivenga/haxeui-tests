package components;

import haxe.ui.containers.SideBar;

@:build(haxe.ui.macros.ComponentMacros.build("assets/components/app-sidebar.xml"))
class AppSidebar extends SideBar {
	public function new() {
		super();
		width = 250;
		percentHeight = 100;
	}
}
