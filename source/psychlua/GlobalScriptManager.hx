package psychlua;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if HSCRIPT_ALLOWED
import psychlua.HScript.HScriptInfos;
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
#end

#if (!flash && sys)
import shaders.ErrorHandledShader.ErrorHandledRuntimeShader;
#end

using StringTools;

// manager and execute all scripts in the engine
class GlobalScriptManager {
    #if LUA_ALLOWED 
    public static var luaArray:Array<FunkinLua> = []; 
    #end
    
    #if HSCRIPT_ALLOWED
	public static var hscriptArray:Array<HScript> = [];
	#end

    #if LUA_ALLOWED
	public static function startLuasNamed(luaFile:String)
	{
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = Paths.getSharedPath(luaFile);

		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = Paths.getSharedPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;

			new FunkinLua(luaToLoad);
			return true;
		}
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public static function startHScriptsNamed(scriptFile:String)
	{
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);
		#end

		if(FileSystem.exists(scriptToLoad))
		{
			if (Iris.instances.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public static function initHScript(file:String)
	{
		var newScript:HScript = null;
		try
		{
			newScript = new HScript(null, file);
			if (newScript.exists('onCreate')) newScript.call('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
		}
		catch(e:IrisError)
		{
			var pos:HScriptInfos = cast {fileName: file, showLine: false};
			Iris.error(Printer.errorToString(e, false), pos);
			var newScript:HScript = cast (Iris.instances.get(file), HScript);
			if(newScript != null)
				newScript.destroy();
		}
	}
	#end

	public static function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public static function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaArray)
		{
			if(script.closed)
			{
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(script.closed) arr.push(script);
		}

		if(arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public static function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(LuaUtils.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;

		for(script in hscriptArray)
		{
			@:privateAccess
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var callValue = script.call(funcToCall, args);
			if(callValue != null)
			{
				var myValue:Dynamic = callValue.returnValue;

				if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
				{
					returnVal = myValue;
					break;
				}

				if(myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
		}
		#end

		return returnVal;
	}

	public static function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public static function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public static function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public static function setStateScript(nameState:String, ?variable:Dynamic) {
		// Remove scripts from other states first
		removeStateScripts(nameState);
		
		// Only create new scripts if they don't exist for current state
		if (!hasStateScript(nameState)) {
			#if LUA_ALLOWED
			startLuasNamed('states/' + nameState + '.lua');
			setOnLuas('stateName', nameState);
			if(variable != null)
				setOnLuas('game', variable);
			#end

			#if HSCRIPT_ALLOWED
			startHScriptsNamed('states/' + nameState + '.hx');
			setOnHScript('stateName', nameState);
			if(variable != null)
				setOnHScript('game', variable);
			#end
		}
	}

	public static function hasStateScript(nameState:String):Bool {
		#if LUA_ALLOWED
		for (lua in luaArray)
		{
			if(lua.scriptName == Paths.getPath('states/' + nameState + '.lua'))
				return true;
		}
		#end
		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
		{
			if(script.origin == Paths.getPath('states/' + nameState + '.hx'))
				return true;
		}
		#end
		return false;
	}

	private static function removeStateScripts(currentState:String):Void {
		#if LUA_ALLOWED
		var i:Int = 0;
		while (i < luaArray.length)
		{
			var lua:FunkinLua = luaArray[i];
			if(lua.scriptName.contains('states/') && !lua.scriptName.contains('states/' + currentState))
			{
				lua.call('onDestroy', []);
				lua.stop();
				luaArray.remove(lua);
				FunkinLua.customFunctions.remove(lua.scriptName);
			}
			else
				i++;
		}
		var i:Int = 0;
		while (i < hscriptArray.length)
		{
			var script:HScript = hscriptArray[i];
			if(script.origin.contains('states/') && !script.origin.contains('states/' + currentState))
			{
				if(script.exists('onDestroy')) script.call('onDestroy');
				script.destroy();
				hscriptArray.remove(script);
			}
			else
				i++;
		}
		#end
	}

    public static function create():Void {
        #if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onCreate', []);
		}
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				if(script.exists('onCreate')) script.call('onCreate');
			}
		#end
    }

    public static function createPost():Void {
        #if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onCreatePost', []);
		}
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				if(script.exists('onCreatePost')) script.call('onCreatePost');
			}
		#end
    }
    
    public static function update(elapsed:Float):Void {
        #if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onUpdate', [elapsed]);
		}
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				if(script.exists('onUpdate')) script.call('onUpdate', [elapsed]);
			}
		#end
    }

    public static function updatePost(elapsed:Float):Void {
        #if LUA_ALLOWED
        for (lua in luaArray)
        {
            lua.call('onUpdatePost', [elapsed]);
        }
        #end
        #if HSCRIPT_ALLOWED
        for (script in hscriptArray)
            if(script != null)
            {
                if(script.exists('onUpdatePost')) script.call('onUpdatePost', [elapsed]);
            }
        #end
    }

    public static function beatHit(curBeat:Int, curDecBeat:Float) {
        #if LUA_ALLOWED
        for (lua in luaArray)
        {
            lua.call('onBeatHit', []);
            lua.set('curBeat', curBeat);
            lua.set('curDecBeat', curDecBeat);
        }
        #end
        #if HSCRIPT_ALLOWED
        for (script in hscriptArray)
            if(script != null)
            {
                if(script.exists('onBeatHit')) script.call('onBeatHit', []);
                setOnHScript('curBeat', curBeat);
                setOnHScript('curDecBeat', curDecBeat);
            }
        #end
    }

    public static function stepHit(curStep:Int, curDecStep:Float) {
        #if LUA_ALLOWED
        for (lua in luaArray)
        {
            lua.call('onStepHit', []);
            lua.set('curStep', curStep);
            lua.set('curDecStep', curDecStep);
        }
        #end
        #if HSCRIPT_ALLOWED
        for (script in hscriptArray)
            if(script != null)
            {
                if(script.exists('onStepHit')) script.call('onStepHit', []);
                setOnHScript('curStep', curStep);
                setOnHScript('curDecStep', curDecStep);
            }
        #end
    }

    public static function destroy():Void {
        #if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = null;
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				if(script.exists('onDestroy')) script.call('onDestroy');
				script.destroy();
			}

		hscriptArray = null;
		#end
    }

    #if (!flash && sys)
	public static var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	#end
	public static function createRuntimeShader(shaderName:String):ErrorHandledRuntimeShader
	{
		#if (!flash && sys)
		if(!ClientPrefs.data.shaders) return new ErrorHandledRuntimeShader(shaderName);

		if(!runtimeShaders.exists(shaderName) && !initLuaShader(shaderName))
		{
			FlxG.log.warn('Shader $shaderName is missing!');
			return new ErrorHandledRuntimeShader(shaderName);
		}

		var arr:Array<String> = runtimeShaders.get(shaderName);
		return new ErrorHandledRuntimeShader(shaderName, arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public static function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (!flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/'))
		{
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if(FileSystem.exists(frag))
			{
				frag = File.getContent(frag);
				found = true;
			}
			else frag = null;

			if(FileSystem.exists(vert))
			{
				vert = File.getContent(vert);
				found = true;
			}
			else vert = null;

			if(found)
			{
				runtimeShaders.set(name, [frag, vert]);
				//trace('Found shader $name!');
				return true;
			}
		}
			#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
			MusicBeatState.getState().addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
			#else
			FlxG.log.warn('Missing shader $name .frag AND .vert files!');
			#end
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}
}