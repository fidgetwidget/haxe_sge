package sge.particles;

import sge.math.Motion;
import sge.math.Transform;
import sge.math.Vector2D;

/**
 * ...
 * @author fidgetwidget
 */
class Particle
{
	
	public var emitter		: Emitter;
	public var life			: Float;
	public var progress		(get, never) : Float;	// between 1 (fully a live) and 0 (dead)
	public var remaining	(get, never) : Float;
	
	// transformation access
	public var x			(get, set)	: Float;
	public var y			(get, set)	: Float;
	public var ix			(get, set)	: Int;
	public var iy			(get, set)	: Int;
	public var z			(get, set)  : Float;
	public var rotation		(get, set)	: Float;
	public var scaleX		(get, set)	: Float;
	public var scaleY		(get, set)	: Float;
	public var transform	(get, set)	: Transform;
	
	// motion access
	public var vx			(get, set)	: Float;	// Positional Velocity, Acceleration, Friction
	public var vy			(get, set)	: Float;
	public var ax			(get, set)	: Float;
	public var ay			(get, set)	: Float;
	public var fx			(get, set)	: Float;
	public var fy			(get, set)	: Float;	
	public var av			(get, set)	: Float;	// Angular Velocity, Acceleration, Friction
	public var aa			(get, set)	: Float;
	public var af			(get, set)	: Float;	
	public var motion		(get, set)	: Motion;
	
	private var _t 			: Transform;
	private var _m 			: Motion;
	private var _remaining 	: Float;

	public function new( emitter:Emitter ) 
	{
		this.emitter = emitter;
	}
	
	public function make( life:Float, properties:Dynamic ) :Void 
	{
		this.life = life;
		_remaining = life;
	}
	
	public function update( delta : Float ) :Void 
	{
		motion.apply( transform, delta );
		
		_remaining -= delta;
		if (_remaining <= 0) {
			die();
		}
	}
	
	public function die( recycle:Bool = true ) : Particle {
		
		transform.free();
		motion.free();
		if (recycle) {
			emitter.recycle( this );
		}
		return this;
	}
	
	/*
	 * Getters & Setters
	 */
	private function get_x() 						: Float 	{ return _t.x; }
	private function get_y() 						: Float 	{ return _t.y; }
	private function get_ix() 						: Int		{ return _t.ix; }
	private function get_iy() 						: Int		{ return _t.iy; }
	private function get_z() 						: Float 	{ return _t.z; }
	private function get_rotation() 				: Float 	{ return _t.rotation; }
	private function get_scaleX() 					: Float 	{ return _t.scaleX; }
	private function get_scaleY() 					: Float		{ return _t.scaleY; }
	private function get_transform() 				: Transform { return _t; }
	
	private function get_vx()						: Float		{ return (_m == null) ? 0 : _m.vx; }
	private function get_vy()						: Float		{ return (_m == null) ? 0 : _m.vy; }
	private function get_ax()						: Float		{ return (_m == null) ? 0 : _m.ax; }
	private function get_ay()						: Float		{ return (_m == null) ? 0 : _m.ay; }
	private function get_fx()						: Float		{ return (_m == null) ? 0 : _m.fx; }
	private function get_fy()						: Float		{ return (_m == null) ? 0 : _m.fy; }
	private function get_av()						: Float		{ return (_m == null) ? 0 : _m.angularVelocity; }
	private function get_aa()						: Float		{ return (_m == null) ? 0 : _m.angularAcceleration; }
	private function get_af()						: Float		{ return (_m == null) ? 0 : _m.angularFriction; }
	private function get_motion()					: Motion	{ return _m; }
	
	private function get_progress() 				: Float  	{ return _remaining / life; }
	private function get_remaining() 				: Float 	{ return _remaining; }
	
	private function set_x( x:Float ) 				:Float 		{ return _t.x = x; }
	private function set_y( y:Float ) 				:Float 		{ return _t.y = y; }
	private function set_ix( x:Int ) 				:Int		{ return _t.ix = ix; }
	private function set_iy( y:Int ) 				:Int		{ return _t.iy = iy; }
	private function set_z( z:Float )				: Float 	{ return _t.z = z; }
	private function set_rotation( r:Float ) 		:Float 		{ return _t.rotation = r; }
	private function set_scaleX( sx:Float ) 		:Float 		{ return _t.scaleX = sx; }
	private function set_scaleY( sy:Float ) 		:Float 		{ return _t.scaleY = sy; }
	private function set_transform( t:Transform ) 	:Transform 	{ return _t = t; }
	
	private function set_vx( vx:Float )				:Float		{ return (_m == null) ? 0 : _m.vx = vx; }
	private function set_vy( vy:Float )				:Float		{ return (_m == null) ? 0 : _m.vy = vy; }
	private function set_ax( ax:Float )				:Float		{ return (_m == null) ? 0 : _m.ax = ax; }
	private function set_ay( ay:Float )				:Float		{ return (_m == null) ? 0 : _m.ay = ay; }
	private function set_fx( fx:Float )				:Float		{ return (_m == null) ? 0 : _m.fx = fx; }
	private function set_fy( fy:Float )				:Float		{ return (_m == null) ? 0 : _m.fy = fy; }
	private function set_av( av:Float )				:Float		{ return (_m == null) ? 0 : _m.angularVelocity = av; }
	private function set_aa( aa:Float )				:Float		{ return (_m == null) ? 0 : _m.angularAcceleration = aa; }
	private function set_af( af:Float )				:Float		{ return (_m == null) ? 0 : _m.angularFriction = af; }
	private function set_motion( m:Motion )			:Motion		{ return _m = m; }	
	
}