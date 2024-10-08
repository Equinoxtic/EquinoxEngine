package funkin.api.discord;

import Sys.sleep;
import discord_rpc.DiscordRpc;

#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end

using StringTools;

typedef PresenceOptions = {
	@:optional var state             :String;
	@:optional var smallImageKey     :String;
	@:optional var hasStartTimestamp :Bool;
	@:optional var endTimestamp      :Float;
}

class DiscordClient
{
	public static var isInitialized:Bool = false;
	public function new()
	{
		trace("Discord Client starting...");
		DiscordRpc.start({
			#if (!debug)
			clientID: "1244628667779252274",
			#else
			clientID: "1245359637327253524",
			#end
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			//trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}

	static function onReady()
	{
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			#if (!debug)
			largeImageKey: 'equinoxrpc',
			largeImageText: '${Variables.APPLICATION_TITLE}'
			#else
			largeImageKey: 'equinoxrpc_debug',
			largeImageText: '${Variables.APPLICATION_TITLE}: Developer Build'
			#end
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		isInitialized = true;
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		var startTimestamp:Float = 0.0;

		if (hasStartTimestamp) {
			startTimestamp = Date.now().getTime();
		}

		if (endTimestamp > 0) {
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			#if (!debug)
			largeImageKey: 'equinoxrpc',
			largeImageText: Variables.APPLICATION_VERSION,
			#else
			largeImageKey: 'equinoxrpc_debug',
			largeImageText: '${Variables.APPLICATION_TITLE} Branch: [${Variables.GIT_BRANCH} @ ${Variables.GIT_HASH}]',
			#end
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
			endTimestamp : Std.int(endTimestamp / 1000)
		});

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State) {
		Lua_helper.add_callback(lua, "changePresence", function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
			changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
		});
	}
	#end
}

class DiscordAPI
{
	public static function updateRichPresence(?details:Null<String> = '- DETAILS -', ?options:Null<PresenceOptions>):Void
	{
		#if (desktop)
		DiscordClient.changePresence(
			details,
			options.state,
			options.smallImageKey,
			options.hasStartTimestamp,
			options.endTimestamp
		);
		#else
		return;
		#end
	}
}
