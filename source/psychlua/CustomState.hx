package psychlua;

// Nothing much since MusicBeatState handle everything now
class CustomState extends MusicBeatState {
    public var sillyName:String;    
    public function new(fileName:String) {
        super();
        FlxG.camera.bgColor = 0xFF000000;

        sillyName = fileName;
        FlxG.cameras.reset();
    }

    override function create() {
        GlobalScriptManager.setStateScript(sillyName, this);
        super.create();
        
        GlobalScriptManager.create();
        GlobalScriptManager.createPost();
    }

    override function update(elapsed:Float) {
        GlobalScriptManager.update(elapsed);
        super.update(elapsed);
        GlobalScriptManager.updatePost(elapsed);
    }

    override function destroy() {
        GlobalScriptManager.destroy();
        super.destroy();
    }
}