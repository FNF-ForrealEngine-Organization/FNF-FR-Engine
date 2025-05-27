package psychlua;

// Nothing much since MusicBeatState handle everything now
class CustomState extends MusicBeatState {
    public var sillyName:String;

    public function new(fileName:String) {
        super();
        FlxG.camera.bgColor = 0xFF000000;

        setStateScript(false);
        sillyName = fileName;
        
        FlxG.cameras.reset();
    }

    override function create() {
        GlobalScriptManager.setStateScript(sillyName, this);
        super.create();
    }
}