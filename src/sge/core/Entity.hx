package sge.core;

import flash.display.DisplayObject;
import motion.Actuate;

import sge.collision.AABB;
import sge.collision.CollisionData;
import sge.collision.CollisionResolver;
import sge.collision.Collider;
import sge.lib.IRecyclable;
import sge.lib.IHasBounds;
import sge.lib.IHasId;
import sge.math.Transform;
import sge.math.Motion;
import sge.math.Vector2D;


/**
 * The basic type of object in a game
 * @author fidgetwidget
 */

class Entity implements IHasBounds //, implements IHasId, implements IRecyclable <-- flashdevelop is throwing an error for some reason????
{

	public static inline var DYNAMIC	: Int = 1;
	public static inline var STATIC		: Int = 2;
	public static inline var FIXED		: Int = 4;
	
	/*
	 * Properties
	 */
	public var id			: Int;
	public var parent		: Entity;
	public var className	: String;
	
	// transformation access
	public var x			(get, set)	: Float;
	public var y			(get, set)	: Float;
	public var ix			(get, set)	: Int;
	public var iy			(get, set)	: Int;
	public var rotation		(get, set)	: Float;
	public var scaleX		(get, set)	: Float;
	public var scaleY		(get, set)	: Float;
	public var transform	(get, set)	: Transform;
	
	// motion access
	public var vx			(get, set)	: Float;
	public var vy			(get, set)	: Float;
	public var ax			(get, set)	: Float;
	public var ay			(get, set)	: Float;
	public var fx			(get, set)	: Float;
	public var fy			(get, set)	: Float;	
	public var av			(get, set)	: Float;
	public var aa			(get, set)	: Float;
	public var af			(get, set)	: Float;	
	public var motion		(get, set)	: Motion;
	
	public var visible		(get, set)	: Bool;
	public var active		(get, set)	: Bool;
	
	public var mc			: DisplayObject;
	public var collider		: Collider;
	public var state		: Int = STATIC; // should it be default Dynamic, or Static?
	
	/*
	 * Members
	 */
	private var _t:Transform;
	private var _m:Motion;
	private var _visible:Bool;
	private var _active:Bool;	
	
	/*
	 * Constructor
	 */
	public function new() 
	{
		id = EntityFactory.getNextEntityId();
		_t = new Transform();
		className = Type.getClassName( Entity );
	}
	
	/*
	 * Update & Render
	 */
		
	public function update( delta : Float ) :Void 
	{
		if (!active) { return; }
		
		_input( delta );
		_update( delta );
		_updateTransform( delta );
	}
	
	// If there is user input that affects the entity, put that code here
	private function _input( delta : Float ) : Void {}
	
	// Any non user input based updates go here
	private function _update( delta : Float ) : Void  {}
	
	// Lastly we udpate the transform based on the now updated motion
	private function _updateTransform( delta : Float ) : Void 
	{
		if ( motion == null || !motion.inMotion ) { return; }
		motion.apply( _t, delta ); // non collision transform update
	}
	
	
	/*
	 * Render the entity
	 */
	public function render( camera ) : Void
	{
		if ( !visible || mc == null ) { return; }
		_render( camera );
	}
	
	private function _render( camera ) : Void {
		
	}
	
	/*
	 * Collision Functions
	 */
	public function collisionTest( collider : Collider, cdata : CollisionData = null ) : Bool {
		if ( this.collider == null ) { return false; }
		
		return this.collider.collide( collider, cdata );
	}
	
	public function collisionAABBTest( aabb : AABB, cdata : CollisionData = null ) : Bool {
		if ( this.collider == null ) { return false; }
		
		return this.collider.collideAABB( aabb, cdata );
	}
	
	public function collideAndResolve( collider : Collider, resolver : CollisionResolver = null ) : Void {
		
		// TODO: add in collision resolution types
		// Default: minumum adjustment + zero the relevant velocity
		throw "collideAndResolve is not yet implemented.";
	}
	
	
	/*
	 * Tween Functions
	 */
	/// Default duration is 0.33 (or 1/3rd of a second)
	 
	public function moveBy( x:Float, y:Float, time:Float = 0.33 ) : Void {
		moveTo( this.x + x, this.y + y, time );
	}	
	public function moveTo( x:Float, y:Float, time:Float = 0.33 ) : Void {
		Actuate.tween( this, time, { x:x, y:y } );
	}
	
	public function rotateBy( r:Float = 0, time:Float = 0.33 ) : Void {
		rotateTo( rotation + r, time );
	}
	public function rotateTo( r:Float, time:Float = 0.33 ) : Void {
		Actuate.tween(this, time, { rotation:r } ).smartRotation();
	}
	
	/*
	 * Getters & Setters
	 */
	private function get_x() 						:Float 		{ return (parent == null) ? _t.x : _t.x + parent.x; }
	private function get_y() 						:Float 		{ return (parent == null) ? _t.y : _t.y + parent.y; }
	private function get_ix() 						:Int		{ return (parent == null) ? _t.ix : _t.ix + parent.ix; }
	private function get_iy() 						:Int		{ return (parent == null) ? _t.iy : _t.iy + parent.iy; }
	private function get_rotation() 				:Float 		{ return (parent == null) ? _t.rotation : _t.rotation + parent.rotation; }
	private function get_scaleX() 					:Float 		{ return (parent == null) ? _t.scaleX : _t.scaleX + parent.scaleX; }
	private function get_scaleY() 					:Float		{ return (parent == null) ? _t.scaleY : _t.scaleY + parent.scaleY; }
	private function get_transform() 				:Transform 	{ return _t; }
	
	private function get_vx()						:Float		{ return (_m == null) ? 0 : (parent == null) ? _m.vx : _m.vx + parent.vx; }
	private function get_vy()						:Float		{ return (_m == null) ? 0 : (parent == null) ? _m.vy : _m.vy + parent.vy; }
	private function get_ax()						:Float		{ return (_m == null) ? 0 : (parent == null) ? _m.ax : _m.ax + parent.ax; }
	private function get_ay()						:Float		{ return (_m == null) ? 0 : (parent == null) ? _m.ay : _m.ay + parent.ay; }
	private function get_fx()						:Float		{ return (_m == null) ? 0 : (parent == null) ? _m.fx : _m.fx + parent.fx; }
	private function get_fy()						:Float		{ return (_m == null) ? 0 : (parent == null) ? _m.fy : _m.fy + parent.fy; }
	private function get_av()						:Float		{ return (_m == null) ? 0 : (parent == null) ? _m.angularVelocity : _m.angularVelocity + parent.av; }
	private function get_aa()						:Float		{ return (_m == null) ? 0 : (parent == null) ? _m.angularAcceleration : _m.angularAcceleration + parent.aa; }
	private function get_af()						:Float		{ return (_m == null) ? 0 : (parent == null) ? _m.angularFriction : _m.angularFriction + parent.af; }
	private function get_motion()					:Motion		{ return _m; }
		
	private function get_visible() 					:Bool 		{ return _visible; }
	private function get_active() 					:Bool 		{ return _active; }
	
	
	private function set_x( x:Float ) 				:Float 		{ return _t.x = (parent == null) ? x : x - parent.x; }
	private function set_y( y:Float ) 				:Float 		{ return _t.y = (parent == null) ? y : y - parent.y; }
	private function set_ix( x:Int ) 				:Int		{ return _t.ix = (parent == null) ? x : x - parent.ix; }
	private function set_iy( y:Int ) 				:Int		{ return _t.iy = (parent == null) ? y : y - parent.iy; }
	private function set_rotation( r:Float ) 		:Float 		{ return _t.rotation = (parent == null) ? r : r - parent.rotation; }
	private function set_scaleX( sx:Float ) 		:Float 		{ return _t.scaleX = (parent == null) ? sx : sx - parent.scaleX; }
	private function set_scaleY( sy:Float ) 		:Float 		{ return _t.scaleY = (parent == null) ? sy : sy - parent.scaleY; }
	private function set_transform( t:Transform ) 	:Transform 	{ return _t = t; }
	
	private function set_vx( vx:Float )				:Float		{ return (_m == null) ? 0 : _m.vx = (parent == null) ? vx : vx - parent.vx; }
	private function set_vy( vy:Float )				:Float		{ return (_m == null) ? 0 : _m.vy = (parent == null) ? vy : vy - parent.vy; }
	private function set_ax( ax:Float )				:Float		{ return (_m == null) ? 0 : _m.ax = (parent == null) ? ax : ax - parent.ax; }
	private function set_ay( ay:Float )				:Float		{ return (_m == null) ? 0 : _m.ay = (parent == null) ? ay : ay - parent.ay; }
	private function set_fx( fx:Float )				:Float		{ return (_m == null) ? 0 : _m.fx = (parent == null) ? fx : fx - parent.fx; }
	private function set_fy( fy:Float )				:Float		{ return (_m == null) ? 0 : _m.fy = (parent == null) ? fy : fy - parent.fy; }
	private function set_av( av:Float )				:Float		{ return (_m == null) ? 0 : _m.angularVelocity = (parent == null) ? av : av - parent.av; }
	private function set_aa( aa:Float )				:Float		{ return (_m == null) ? 0 : _m.angularAcceleration = (parent == null) ? aa : aa - parent.aa; }
	private function set_af( af:Float )				:Float		{ return (_m == null) ? 0 : _m.angularFriction = (parent == null) ? af : af - parent.af; }
	private function set_motion( m:Motion )			:Motion		{ return _m = m; }	
	
	private function set_visible( visible:Bool ) 	:Bool 		{ return _visible = visible; }
	private function set_active( active:Bool ) 		:Bool 		{ return _active = active; }
	
	
	
	/*
	 * IHasBounds 
	 */
	public function get_bounds() :AABB
	{
		if (collider == null)  
			return null; 
		else
			return collider.get_bounds();
	}
	/*
	 * IHasId 
	 */
	public function get_id() :Int
	{
		return id;
	}
	
	/*
	 * IRecycleable 
	 */
	public function free() :Void 
	{		
		// free's up only the things that are initialized in the constructor
		_t.free();	
		if (_m != null) {
			_m.free();
		}
		_free = true;
	}
	public function get_free() :Bool { return _free; }
	public function set_free( free:Bool ) :Bool { return _free = free; }
	private var _free:Bool = false;
	
}