package psychlua;

import openfl.utils.Assets;
import substates.GameOverSubstate;
import flxsvg.FlxSvgSprite;

class SvgSpriteFunctions {
    #if flxsvg
	public static function implement(funk:FunkinLua)
	{
		var lua = funk.lua;

        Lua_helper.add_callback(lua, "makeLuaSvgSprite", function(tag:String, ?svg:String = null, ?x:Float = 0, ?y:Float = 0) {
			tag = tag.replace('.', '');
			LuaUtils.destroyObject(tag);
			var leSvg:FlxSvgSprite = new FlxSvgSprite(x, y);
			if(svg != null && svg.length > 0)
			{
				leSvg.loadSvg(Assets.getText(Paths.getPath('images/$svg.svg')));
			}
			MusicBeatState.getVariables().set(tag, leSvg);
			leSvg.active = true;
		});
        Lua_helper.add_callback(lua, "addLuaSvgSprite", function(tag:String, ?inFront:Bool = false) {
			var mySvg:FlxSvgSprite = MusicBeatState.getVariables().get(tag);
			if(mySvg == null) return;

			var instance = LuaUtils.getTargetInstance();
			if(inFront)
				instance.add(mySvg);
			else
			{
				if(PlayState.instance == null || !PlayState.instance.isDead)
					instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), mySvg);
				else
					GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), mySvg);
			}
		});
        Lua_helper.add_callback(lua, "removeLuaSvgSprite", function(tag:String, destroy:Bool = true, ?group:String = null) {
			var obj:FlxSvgSprite = LuaUtils.getObjectDirectly(tag);
			if(obj == null || obj.destroy == null)
				return;
			
			var groupObj:Dynamic = null;
			if(group == null) groupObj = LuaUtils.getTargetInstance();
			else groupObj = LuaUtils.getObjectDirectly(group);

			groupObj.remove(obj, true);
			if(destroy)
			{
				MusicBeatState.getVariables().remove(tag);
				obj.destroy();
			}
		});
		Lua_helper.add_callback(lua, "luaSvgSpriteExists", function(tag:String) {
			var obj:FlxSvgSprite = MusicBeatState.getVariables().get(tag);
			return (obj != null && (Std.isOfType(obj, FlxSvgSprite)));
		});
    }
    #end
}