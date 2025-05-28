package psychlua;

class CustomState extends MusicBeatState {
    var fileName:String;
    
    public function new(fileName:String) {
        super();
        this.fileName = fileName;
    }

    override function create() {
        setStateScript(fileName);

        #if DISCORD_ALLOWED
        DiscordClient.changePresence("On Custom States: " + fileName, null);
        #end
        
        super.create();
    }
}