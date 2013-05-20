package sge.core;

import nme.Assets;
import nme.Lib;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.BitmapData;
import nme.display.FPS;
import nme.display.Stage;
import nme.errors.Error;
import nme.events.Event;
import nme.events.KeyboardEvent;

import haxe.FastList;
import haxe.Timer;
import com.eclecticdesignstudio.motion.Actuate;

import sge.graphics.AssetManager;
import sge.graphics.Draw;
import sge.io.Input;
import sge.lib.Properties;
import sge.random.Random;


/**
 * @author fidgetwidget
 * 
 * the sge_Engine is: 
 *  - the SceneManager 
 *  - static access for other managers (graphics/asset manager, entity manager)
 *  - static resources for game time/delta * 
 */

class Engine
{
	/*
	 * Static Instance
	 */
	public static var instance : Engine;
	
	public static var delta(get_delta, null) :Float;
	public static var root(get_root, null) : Sprite;
	public static var stage(get_stage, null) :Stage;
	public static var graphics(get_graphics, null) :Graphics;
	public static var properties(default, null) :Properties;
	
	/*
	 * Properties
	 */
	public var stageSprite : Sprite; // a temp solution to make the added to stage event trigger the init 
	
	/*
	 * Members
	 */	
	private var _fps:FPS;	
	// Scene Manager	
	private var topScene:String; // scene name for access via scenes
	private var nextScene:String;
	private var _s:Scene;
	private var _delta : Float;
	private var _root : Sprite;
	private var _stage : Stage;
	private var _graphics : Graphics;
	
	public function new(root) {
		
		_root = root;
		stageSprite = new Sprite(); // temp solution - used to init on "Added to Stage"		
		
		_fps = new FPS();
		
		// scene manager data
		scenes = new Hash();
		_sceneNames = new Array<String>();
		_s = null;
		topScene = "";
		nextScene = "";
		
		properties = new Properties();
	}
	
	public function init() :Void
	{	
		_start = _current = Timer.stamp();
		
		_stage = root.stage;
		properties.add("_STAGE_WIDTH", _stage.stageWidth);
		properties.add("_STAGE_HEIGHT", _stage.stageHeight);
		
		_graphics = root.graphics;
		Input.init( _stage );
		Draw.init( _graphics );
		EntityFactory.init();
		AssetManager.init();
		Random.init( Std.int(_start) );
		Actuate.reset(); // not nessesary, but just here to remind that you have access to Actuate
		
		#if (!js)
		/// the pgr.gconsole.GameConsole doesn't work in html5 targets - will need to replace this eventually...
		Debug.init();		
		Debug.registerVariable(this, "_sceneNames", "all_scenese");
		Debug.registerFunction(this, "readyScene", "readyScene");
		#end
		
		_stage.addEventListener( Event.ACTIVATE, function(_) _resume() );
		_stage.addEventListener( Event.DEACTIVATE, function(_) _pause() );
		
		_stage.addChild( _fps );		
		_stage.addEventListener(Event.ENTER_FRAME, function(_) update());
	}
	
	public function update() :Void { 	
		
		_updateDelta();		
		
		_preUpdate();
		
		Input.update();
		
		_update();
		
		_render();
		
		_postUpdate();
		
		_root.x = 0;
		_root.y = 0;
	}
	
	private function _updateDelta():Void 
	{
		_last = _current;
		_current = Timer.stamp();
		_delta = (_current - _last);
	}
	
	//pre input update
	private function _preUpdate() :Void {
		
	}
	
	// Update AFTER the Input Update
	private function _update() :Void {
		_s = scenes.get(topScene);
		if (_s != null) {
			_s.update( _delta );
		}
	}
	
	private function _render() :Void {
		// Clear the Screen
		_graphics.clear();
		
		// Draw the active Scene
		_s = scenes.get(topScene);
		if (_s != null) { 
			_s.render();
		}
	}
	
	private function _postUpdate() :Void {
		
	}
	
	private function _pause() :Void {
		Actuate.pauseAll();
	}
	
	private function _resume() :Void {
		Actuate.resumeAll();
	}
	
	// Timer variables
	private var _start:Float;
	private var _last:Float;
	private var _current:Float;
	

	/// -------------------------------------------------------------------
	///  Scene Manager
	/// -------------------------------------------------------------------
	// TODO: create the SceneManager class and put this code in there
	public function addScene( scene:Scene, readyNow:Bool = false ) :Void {
		// TODO: do some error handling here
		scenes.set(scene.id, scene);
		_sceneNames.push(scene.id);
		
		if (readyNow) {
			readyScene(scene.id);
		}
	}
	
	/**
	 * Readies the scene 
	 * @param	sceneId
	 */
	public function readyScene( sceneId:String ) :Void {		
		
		if (!scenes.exists(sceneId)) { return; } // TODO: throw an error?
		
		nextScene = sceneId;
		_s = scenes.get(topScene);
		if (_s != null) { 
			_s.on_Exit = _exitScene;
			_s.exit(); 
		} else {
			_s = scenes.get(nextScene);
			topScene = nextScene;
			nextScene = "";
			_s.ready();
		}
	}
	
	private function _exitScene( s:Scene ) :Void {
		_s = scenes.get(topScene);
		if (s != _s) { return; }
		_s.on_Exit = null;
		
		_s = scenes.get(nextScene);
		topScene = nextScene;
		nextScene = "";
		if (_s == null) { return; }
		_s.ready();
	}

	
	// Scene Manager hash table
	private var scenes:Hash<Scene>;
	private var _sceneNames:Array<String>;
	
	
	/// -------------------------------------------------------------------
	///  Asset Manager
	/// -------------------------------------------------------------------

	public static function saveBitmap( source:Dynamic ) :Bool {
		return AssetManager.saveBitmap( source );
	}	
	
	public static function getBitmap( source:Dynamic ) :BitmapData {
		return AssetManager.getBitmap( source );
	}	
	
	/// -------------------------------------------------------------------
	///  Entity Recycling
	/// -------------------------------------------------------------------
		
	/**
	 * Get an entity of the given type
	 */
	public static function getEntity<E:Entity>( type:Class<E>, forceNew:Bool = false ) :E {
		
		return EntityFactory.getEntity(type, forceNew);
	}
	
	/**
	 * Release the given entity and add it to the pool
	 */
	public static function free( e:Entity ) :Void {		
		
		EntityFactory.free(e);
	}	
	
	//** -------------------------------------------------------------------
	
	
	//** Static Property Getters
	private static function get_delta() :Float {
		if (instance == null) {
			throw new Error(" Engine not yet initialized ");
		}
		return instance._delta;
	}	
	
	private static function get_root() :Sprite {
		if (instance == null || instance._root == null) {
			throw new Error(" Engine not yet initialized ");
		}
		return instance._root;
	}
	
	private static function get_stage() :Stage {
		if (instance == null || instance._stage == null) {
			throw new Error(" Engine not yet initialized ");
		}
		return instance._stage;
	}
	
	private static function get_graphics() :Graphics {
		if (instance == null || instance._graphics == null) {
			throw new Error(" Engine not yet initialized ");
		}
		return instance._graphics;
	}
	
}