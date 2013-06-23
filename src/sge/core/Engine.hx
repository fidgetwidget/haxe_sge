package sge.core;


import flash.Lib;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.errors.Error;
import flash.events.Event;
import flash.events.KeyboardEvent;
import openfl.Assets;
import openfl.display.FPS;
import haxe.Timer;
import haxe.ds.StringMap;
import motion.Actuate;

import sge.graphics.AssetManager;
import sge.graphics.Draw;
import sge.io.Input;
import sge.lib.Properties;
import sge.math.Random;

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
	
	/*
	 * Instance Properties
	 */
	public static var delta			(get_delta, null) 		: Float;
	public static var root			(get_root, null) 		: Sprite;
	public static var stage			(get_stage, null) 		: Stage;
	public static var graphics		(get_graphics, null) 	: Graphics;
	public static var properties	(default, null) 		: Properties;
	
	/*
	 * Members
	 */	
	private var _fps:FPS;	
	private var _delta 		: Float;
	private var _root 		: Sprite;
	private var _stage 		: Stage;
	private var _graphics 	: Graphics;
	private var _scene		: Scene;
	
	/// Timer
	private var _start:Float;
	private var _last:Float;
	private var _current:Float;
	
	
	public function new() {		
		
		_fps = new FPS();		
		properties = new Properties();
	}
	
	public function init( root:MovieClip ) :Void
	{	
		_start = _current = Timer.stamp();
		
		_root = root;
		_stage = root.stage;
		_graphics = root.graphics;
		
		properties.add("_STAGE_WIDTH", _stage.stageWidth);
		properties.add("_STAGE_HEIGHT", _stage.stageHeight);
		
		Input.init( _stage );
		Draw.init( _graphics );
		EntityFactory.init();
		AssetManager.init();
		SceneManager.init();
		Random.init( Std.int(_start) );
		Actuate.reset(); // not nessesary, but just here to remind that you have access to Actuate
		
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
		_scene = SceneManager.currentScene;
		if (_scene != null)
			_scene.update( delta );
	}
	
	private function _render() :Void {
		// Clear the Screen
		_graphics.clear();
		
		// Draw the active Scene
		_scene = SceneManager.currentScene;
		if (_scene != null)
			_scene.render();
		
	}
	
	private function _postUpdate() :Void {
		
	}
	
	private function _pause() :Void {
		Actuate.pauseAll();
	}
	
	private function _resume() :Void {
		Actuate.resumeAll();
	}	

	/// -------------------------------------------------------------------
	///  Scene Manager
	/// -------------------------------------------------------------------
	
	public function addScene( scene:Scene, readyNow:Bool = false ) :Void {
		SceneManager.addScene( scene, readyNow );
	}
	
	public function readyScene( sceneId:String ) :Void {
		SceneManager.readyScene( sceneId );
	}	
	
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