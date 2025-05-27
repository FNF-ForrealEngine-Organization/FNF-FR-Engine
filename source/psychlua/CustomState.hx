package psychlua;

// Nothing much since MusicBeatState handle everything now
class CustomState extends MusicBeatState {
    public function new(fileName:String) {
        super();

        setStateScript(false);
        GlobalScriptManager.setStateScript(fileName, this);
    }
}