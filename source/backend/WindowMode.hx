package backend;

import lime.app.Application;

class WindowMode {
    public static function windowSet(fullscreen:Bool, borderless:Bool = false) {
        Application.current.window.borderless = borderless;
        Application.current.window.fullscreen = fullscreen;
    }
}