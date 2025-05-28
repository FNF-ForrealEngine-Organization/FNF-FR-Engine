package psychlua;

import flixel.FlxObject;
import backend.MusicBeatState;

class CustomSubstate extends MusicBeatSubstate
{
	public static var name:String = 'unnamed';
	public static var instance:CustomSubstate;
	private static var currentState:MusicBeatState;

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua)
	{
		var lua = funk.lua;
		Lua_helper.add_callback(lua, "openCustomSubstate", openCustomSubstate);
		Lua_helper.add_callback(lua, "closeCustomSubstate", closeCustomSubstate);
		Lua_helper.add_callback(lua, "insertToCustomSubstate", insertToCustomSubstate);
	}
	#end
	
	public static function openCustomSubstate(name:String, ?pauseGame:Bool = false)
	{
		var state = FlxG.state;
		if(!(state is MusicBeatState)) return;

		currentState = cast state;
		if(pauseGame)
		{
			FlxG.camera.followLerp = 0;
			currentState.persistentUpdate = false;
			currentState.persistentDraw = true;
			if(FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				// Only pause vocals if we're in PlayState
				if(currentState is PlayState) {
					var playState:PlayState = cast currentState;
					playState.vocals.pause();
				}
			}
		}
		currentState.openSubState(new CustomSubstate(name));
	}

	public static function closeCustomSubstate()
	{
		if(instance != null && currentState != null)
		{
			currentState.closeSubState();
			return true;
		}
		return false;
	}

	public static function insertToCustomSubstate(tag:String, ?pos:Int = -1)
	{
		if(instance != null)
		{
			var tagObject:FlxObject = cast (MusicBeatState.getVariables().get(tag), FlxObject);

			if(tagObject != null)
			{
				if(pos < 0) instance.add(tagObject);
				else instance.insert(pos, tagObject);
				return true;
			}
		}
		return false;
	}

	override function create()
	{
		instance = this;
		GlobalScriptManager.setOnHScript('customSubstate', instance);

		GlobalScriptManager.callOnScripts('onCustomSubstateCreate', [name]);
		super.create();
		GlobalScriptManager.callOnScripts('onCustomSubstateCreatePost', [name]);
	}
	
	public function new(name:String)
	{
		CustomSubstate.name = name;
		GlobalScriptManager.setOnHScript('customSubstateName', name);
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
	
	override function update(elapsed:Float)
	{
		GlobalScriptManager.callOnScripts('onCustomSubstateUpdate', [name, elapsed]);
		super.update(elapsed);
		GlobalScriptManager.callOnScripts('onCustomSubstateUpdatePost', [name, elapsed]);
	}

	override function destroy()
	{
		GlobalScriptManager.callOnScripts('onCustomSubstateDestroy', [name]);
		instance = null;
		name = 'unnamed';
		currentState = null;

		GlobalScriptManager.setOnHScript('customSubstate', null);
		GlobalScriptManager.setOnHScript('customSubstateName', name);
		super.destroy();
	}
}
