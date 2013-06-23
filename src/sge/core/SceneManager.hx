package sge.core;

import haxe.ds.StringMap;

/**
 * ...
 * @author fidgetwidget
 */
class SceneManager
{
	/*
	 * Properties
	 */
	public static var currentScene(get, never) : Scene;
	public static var scenes					: StringMap<Scene>;
	public static var sceneNames(get, never)	: Array<String>;
	
	/*
	 * Members
	 */	
	private static var _topScene	: String; // scene name for access via scenes
	private static var _nextScene	: String;
	private static var _s			: Scene;
	private static var _sceneNames	: Array<String>;
	
	public static function init() 
	{
		scenes = new StringMap();
		_sceneNames = new Array<String>();
		_s = null;
		_topScene = "";
		_nextScene = "";
	}
	
	
	public static function addScene( scene:Scene, readyNow:Bool = false ) :Void 
	{
		// TODO: do some error handling here
		scenes.set(scene.id, scene);
		_sceneNames.push(scene.id);
		
		if (readyNow) {
			readyScene(scene.id);
		}
	}

	
	public static function readyScene( sceneId:String ) :Void 
	{				
		if (!scenes.exists(sceneId)) { return; } // TODO: throw an error?
		
		_nextScene = sceneId;
		_s = scenes.get(_topScene);
		if (_s != null) {
			// setup the event listener function on scene exit complete
			_s.on_Exit = _exitScene;
			// tell the scene to start exiting
			_s.exit(); 
		} else {
			_s = scenes.get(_nextScene);
			_topScene = _nextScene;
			_nextScene = "";
			_s.ready();
		}
	}
	
	
	private static function _exitScene( s:Scene ) : Void 
	{
		_s = scenes.get(_topScene);
		if (s != _s) { return; }
		_s.on_Exit = null;
		
		_s = scenes.get(_nextScene);
		_topScene = _nextScene;
		_nextScene = "";
		if (_s == null) { return; }
		_s.ready();
	}
	
	
	private static function get_currentScene() : Scene 
	{
		_s = scenes.get(_topScene);
		return _s;
	}
	
	private static function get_sceneNames() : Array<String>
	{
		return _sceneNames;
	}
	
}