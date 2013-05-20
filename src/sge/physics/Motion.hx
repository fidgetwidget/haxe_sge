package sge.physics;
import sge.interfaces.IRecyclable;


/**
 * Motion
 * (a class for sharing motion data between objects)
 * has acceleration, velocity, and friction values for position and rotation
 * 
 * @author fidgetwidget
 */

typedef MotionData = {	
	ax:Float, ay:Float, ar:Float, 	// position and rotation acceleration
	vx:Float, vy:Float, vf:Float, 	// position velocity and friction
	vr:Float, fr:Float, 			// rotation velocity and friction
	max_v:Float, max_r:Float
}
 
class Motion implements IRecyclable
{
	public static var MIN_THRESHOLD:Float = 0.5;
	
	/*
	 * Properties
	 */
	//* Acceleration
	public var accel(get_a, set_a) 	: Vec2;
	public var ax(get_ax, set_ax)	: Float;
	public var ay(get_ay, set_ay)	: Float;
	//* Velocity
	public var v(get_v, set_v) 		: Vec2;
	public var vx(get_vx, set_vx) 	: Float; 
	public var vy(get_vy, set_vy) 	: Float; 
	//* Friction/Drag
	public var vf(get_fv, set_fv) 	: Float;	
	public var fx(get_fx, set_fx) 	: Float;
	public var fy(get_fy, set_fy) 	: Float;	
	//* (Optional) Maximum Velocity
	public var max_v				: Float = 0;
	
	//* Rotation Acceleration, Velocity & Friction/Drag
	public var ar					: Float = 0;
	public var vr					: Float = 0;
	public var fr					: Float = 1;
	//* (Optional) Maximum Rotation Velocity
	public var max_r				: Float = 0;
	
	public var inMotion(get_inMotion, never):Bool;
	
	/*
	 * Members
	 */
	private var _a	:Vec2;
	private var _v	:Vec2;
	private var _vf	:Vec2;
	
	 
	/**
	 * Constructor
	 */
	public function new( vx:Float = 0, vy:Float = 0, fx:Float = 1, fy:Float = 1, vr:Float = 0, fr:Float = 1 ) 
	{
		_a = new Vec2();
		ar = 0;
		_v = new Vec2();		
		_vf = new Vec2();
		set( vx, vy, fx, fy, vr, fr );
	}
	
	public function set( vx:Float = 0, vy:Float = 0, fx:Float = 1, fy:Float = 1, vr:Float = 0, fr:Float = 1 ) :Void
	{
		this.vx = vx;
		this.vy = vy;
		this.fx = fx;
		this.fy = fy;
		this.vr = vr;
		this.fr = fr;
	}
	
	public function setMax( max_v:Float = 0, max_r = 0 ) :Void 
	{
		this.max_v = max_v;
		this.max_r = max_r;
	}
	
	
	
	/**
	 * Apply the motion to the given transform
	 * @param	t
	 * @param	delta
	 * @param	updateSelf
	 * @return
	 */
	public function apply( t:Transform, delta:Float = 1, updateSelf:Bool = true ) :Transform 
	{
		if (delta < 0 || Math.isNaN(delta)) { return t; }
		
		if (max_v != 0 && _v.x != 0 && _v.y != 0)
		{
			if (_v.x * _v.x + _v.y * _v.y > max_v * max_v) {
				_v.normalize();
				_v.scale(max_v);
			}
		}
		
		if (updateSelf) {
			_updateSelf( delta * 0.5 );
		}		
		
		if (max_r != 0 && vr != 0) 
		{
			if ( vr > max_r ) { 
				vr = max_r;
			} 
			else
			if ( vr < -max_r ) {
				vr = -max_r;
			}
		}
		
		// allow for self update only
		if (t != null) {
			t.x += _v.x * delta;
			t.y += _v.y * delta;
			t.rotation += vr * delta;
		}
		
		if (updateSelf) {
			_updateSelf( delta * 0.5 );
		}
		
		return t;
	}
	
	private function _updateSelf( delta:Float ) :Void 
	{
		if (_a.y != 0 || _a.x != 0) {
			_v.x += _a.x * delta;
			_v.y += _a.y * delta;
		}
		else 
		if (_vf.x != 0 || _vf.y != 0) {
			_v.x -= _v.x * _vf.x;
			_v.y -= _v.y * _vf.y;
		}		
		if (_v.x < 1 && _v.x > -1) { _v.x = 0; }
		if (_v.y < 1 && _v.y > -1) { _v.y = 0; }
		
		if ( ar != 0 ) {
			vr += ar * delta;
		}
		else
		if ( fr != 0 ) {
			vr -= vr * fr * delta;
		}		
		if (vr < 1 && vr > -1) { vr = 0; }
	}
	
	
	/*
	 * Getters & Setters
	 */
	
	private function get_a() :Vec2 				{ return _a; }
	private function set_a( a:Vec2 ) :Vec2 		{ return _a = a; } 
	
	private function get_ax() :Float 			{ return _a.x; }	
	private function get_ay() :Float 			{ return _a.y; }
	private function set_ax( ax:Float ) :Float 	{ return _a.x = ax; }
	private function set_ay( ay:Float ) :Float 	{ return _a.y = ay; }
	 
	private function get_v() :Vec2 				{ return _v; }
	private function set_v( v:Vec2 ) :Vec2 		{ return _v = v; }
	
	private function get_vx() :Float 			{ return _v.x; }	
	private function get_vy() :Float 			{ return _v.y; }
	private function set_vx( vx:Float ) :Float 	{ return _v.x = vx; }
	private function set_vy( vy:Float ) :Float 	{ return _v.y = vy; }
	
	private function get_fv() :Float 			{ return (_vf.x + _vf.y) * 0.5; }
	private function set_fv( fv:Float ) :Float 	{ _vf.x = _vf.y = fv; return fv; }
	
	private function get_fx() :Float 			{ return _vf.x; }	
	private function get_fy() :Float 			{ return _vf.y; }
	private function set_fx( fx:Float ) :Float 	{ return _vf.x = fx; }
	private function set_fy( fy:Float ) :Float 	{ return _vf.y = fy; }
	
	private function get_inMotion() :Bool 
	{ 
		return (_v.x != 0 || _v.y != 0 || vr != 0);
	}
	
	
	/// IRecyclable
	public function free() :Void
	{
		_a.x = 0;
		_a.y = 0;
		_v.x = 0;
		_v.y = 0;
		_vf.x = 1;
		_vf.y = 1;
		max_v = 0;
		ar = 0;
		vr = 0;		
		fr = 1;
		max_r = 0;
		
		_free = true;
	}
	public function get_free() :Bool 			{ return _free; }
	public function set_free( free:Bool ) :Bool { return _free = free; }
	private var _free :Bool;
	
}