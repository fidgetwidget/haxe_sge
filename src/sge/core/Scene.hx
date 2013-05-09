package sge.core;

import nme.display.Graphics;
import nme.geom.Point;
import haxe.FastList;

import sge.graphics.Atlas;
import sge.graphics.Draw;

/**
 * ...
 * @author fidgetwidget
 */

class Scene
{
	
	/*
	 * Properties 
	 */
	public var id:String;
	public var parent:Scene;
	public var camera:Camera;	
	public var offset(get_offset, set_offset) :Point;
	
	public var visible:Bool;	
	public var active:Bool;	
	public var ending:Bool;
	
	public var inTransition(get_inTransition, never):Bool;
	public var transitionValue(get_transitionValue, never):Float;	
	
	public var transitionOnTime:Float;
	public var transitionOffTime:Float;
	
	
	public var on_Exit:Dynamic;
	
	public var entities:EntityManager;
	public var count(get_count,null):Int;
	
	
	
	/*
	 * Members 
	 */
	private var _offset:Point;
	private var transitionTime:Float;
		
	/**
	 * Constructor	 * 
	 * @param	parent - the scene parent (default: null)
	 */
	public function new( parent:Scene = null )
	{		
		id = "Scene"; // This needs to be set and unique in order to be used by the scene manager
		visible = false;
		active = false;
		entities = null; // To be set by the specific implimentation
		transitionOnTime = transitionOffTime = 0;		
		this.parent = parent;
	}
	
	public function free() :Void 
	{		
		visible = false;
		active = false;
		_offset = null;
		entities = null;
	}
	
	/**
	 * Begin Exiting the scene
	 * NOTE: this function is called when a new scene is set to ready by the scene manager
	 */
	public function exit() :Void 
	{
		ending = true;
		transitionTime = transitionOffTime;
	}
	
	public function ready() :Void
	{
		if (transitionOnTime == 0) { 
			active = true; 
		} else {
			transitionTime = transitionOnTime;
		}
	}
	
	// Called just prior to finally exiting.
	private function _exit() :Void {
		
	}
	
	//** Update and Render
	public function update( delta:Float ) :Void 
	{				
		if (!active && !inTransition && !ending) { return; }
		_updateTransition( delta );
		_handleInput( delta );
		_update( delta );
		_postUpdate( delta );		
	}
	
	private function _updateTransition( delta:Float ) :Void 
	{
		
		if (inTransition)
		{			
			transitionTime -= delta;
			
			if (transitionTime < 0) 
			{ 
				// Transition is complete
				transitionTime = 0; 
				if (!ending) { active = true; }
			}
		}
	}
	
	private function _handleInput( delta:Float ) :Void 
	{
		/// Each Scene can have their own input handling
		/// You can also put this logic in the Entities
	}
	
	
	private function _update( delta:Float ) :Void 
	{
		if (entities == null) { return; }
		for (e in entities) 
		{
			e.update( delta );
		}
		
	}
	
	
	private function _postUpdate( delta:Float ) :Void 
	{
		
		if (on_Exit != null && ending && transitionTime == 0)
		{ 
			_exit();
			on_Exit(this);
		}
	}
	
	
	public function render() :Void
	{
		if (entities == null) { return; }
		for (e in entities) 
		{
			e.render( camera );
		}
	}
	
	/// ------------------------------------------------------------------- 
	///  Entity Managment
	/// -------------------------------------------------------------------
	public function add( e:Entity ) :Void {	
		
		if (entities == null) { 
			entities = new EntityManager(); // fall back on the default EntityManager if none have been set up
		}
		entities.add( e );
	}
	
	public function remove( e:Entity, ?free:Bool = true ) :Bool {
		
		entities.remove(e, free);
		return true;
	}
	
	
	//** Getters and Setters
	private function get_count() :Int	{ return entities.count; }
	
	private function get_offset() :Point { 
		if (parent != null) {
			var o = _offset.clone();
			return o.add(parent.offset);
		}
		return _offset;
	}
	private function set_offset( p:Point ) :Point 
	{ 
		// set the local value given the world value (TODO: either make this the standard behaviour everywhere, or change this)
		if (parent != null) {
			_offset.x = p.x - parent.offset.x;
			_offset.y = p.y - parent.offset.y;
		} else
		{
			_offset.x = p.x;
			_offset.y = p.y;
		}
		
		return _offset;
	}	
	
	private inline function get_inTransition() :Bool { return transitionTime != 0;  }
	private inline function get_transitionValue() :Float { return !inTransition ? 0 : transitionTime / (ending ? transitionOffTime : transitionOnTime); }
	
}