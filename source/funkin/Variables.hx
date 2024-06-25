package funkin;

import funkin.util.macro.GitCommit as Repository;
import lime.app.Application;

class Variables
{
	/**
	 * The title of the application.
	 */
	public static final APPLICATION_TITLE:String = "Equinox Engine";

	/**
	 * The base engine of the application.
	 */
	public static final BASE_ENGINE_TITLE:String = "Psych Engine";

	/**
	 * The title of the base game.
	 */
	public static final FUNKIN_TITLE:String = "Friday Night Funkin\'";

	/**
	 * The current version of the client.
	 */
	public static final CLIENT_VERSION:String = "0.4.0";

	/**
	 * The version of the application.
	 */
	public static var APPLICATION_VERSION(get, never):String;

	/**
	 * The version of the base engine.
	 */
	public static var BASE_ENGINE_VERSION(get, never):String;

	/**
	 * The version of the base game.
	 */
	public static var FUNKIN_VERSION(get, never):String;

	static function get_APPLICATION_VERSION():String
	{
		#if !debug
		var version:String = Http.requestStringFrom('https://raw.githubusercontent.com/Equinoxtic/EquinoxEngine/master/.GIT_VERSION');
		return 'v${version}';
		#else
		return 'dev : ${GIT_BRANCH} @ ${GIT_HASH}';
		#end
	}

	static function get_BASE_ENGINE_VERSION():String
	{
		var version:String = Http.requestStringFrom('https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/0.6.3/gitVersion.txt');
		return 'v${version}';
	}

	static function get_FUNKIN_VERSION():String
	{
		return 'v${Application.current.meta.get('version')}';
	}

	/**
	 * Get the grouped version string of the application.
	 * @return String
	 */
	public static function getGroupedVersionString():String
	{
		return '${APPLICATION_TITLE} - ${CLIENT_VERSION} | ${BASE_ENGINE_TITLE} - ${BASE_ENGINE_VERSION}';
	}

	/**
	 * Get the grouped version of the base game.
	 * @return String
	 */
	public static function getFunkinVersionString():String
	{
		return '${FUNKIN_TITLE} - ${FUNKIN_VERSION}';
	}

	/**
	 * The current branch of the engine's repository.
	 */
	public static final GIT_BRANCH:String = Repository.getGitBranch();

	/**
	 * The current commit hash of the engine's repository.
	 */
	public static final GIT_HASH:String = Repository.getGitCommitHash();

	/**
	 * Get the grouped string of the git branch and commit hash.
	 * @return String
	 */
	public static function getGroupedGitBranch():String
	{
		return 'Branch: ${GIT_BRANCH} @ ${GIT_HASH}';
	}
}
