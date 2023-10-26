# haxeui tests

some haxeui stuff

## running the project

Run the project:

- Make sure all files are saved
- Run the command `haxe html5.hxml`
- Open `index.html` (which opens the generated `Main.js` file) in a browser

## debugging the project

Debugging is possible by having a file called `launch.json` inside a `.vscode` folder in the project's `root`.

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "msedge",
      "request": "launch",
      "name": "Launch Edge",
      // relative path you compile your project to
      "file": "build/html5/index.html",
  }
  ]
}
```

Click on "Run and Debug" in vscode's sidebar, then on the green play button (make sure the dropdown on the button's side displays the correct `configurations.name` "Launch Browser").

Running the project this way should let us place breakpoints in the code that will be triggered.

## module.xml notes

```xml
<module>
    <components>
        <class package="haxe.ui.containers.properties" loadAll="true" />
    </components>
</module>
```

`package="folder"` adds all files found in the specified `folder`.

`loadAll="true"` will add all classes found inside the files.

You can also use `<class name="class_name"/>` if you want just one class and not a package.

## html5.hxml notes

To check all components, you can add `-D component_resolution_verbose` in the `.hxml` file.
