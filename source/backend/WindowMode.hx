package backend;

import lime.app.Application;

#if windows
@:buildXml('
    <target id="haxe">
        <lib name="dwmapi.lib" if="windows" />
    </target>
    ')
@:cppFileCode('
    #include <Windows.h>
    #include <cstdio>
    #include <iostream>
    #include <tchar.h>
    #include <dwmapi.h>
    #include <winuser.h>

    #ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
    #define DWMWA_USE_IMMERSIVE_DARK_MODE 20 // support for windows 11
    #endif
    ')
@:dox(hide)
class WindowMode {
    public static function windowSet(fullscreen:Bool, borderless:Bool = false) {
        Application.current.window.borderless = borderless;
        Application.current.window.fullscreen = fullscreen;
    }

    @:functionCode('
        int darkMode = enable ? 1 : 0;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE, reinterpret_cast<LPCVOID>(&darkMode), sizeof(darkMode)))
            DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE, reinterpret_cast<LPCVOID>(&darkMode), sizeof(darkMode));
    ')
	public static function setDarkMode(enable:Bool) {}

	public static function darkMode(enable:Bool) {
		setDarkMode(enable);
	}
}
#else
class WindowMode {
    public static function windowSet(fullscreen:Bool, borderless:Bool = false) {
        Application.current.window.borderless = borderless;
        Application.current.window.fullscreen = fullscreen;
    }
}
#end