package sge.math;

/**
 * ...
 * @author fidgetwidget
 */
class Motion
{
	
	public var acceleration(get, set):Vector2D;
	public var ax(get, set):Float;
	public var ay(get, set):Float;
	public var velocity(get, set):Vector2D;
	public var vx(get, set):Float;
	public var vy(get, set):Float;
	
	public var angularAcceleration:Float;
	public var angularVelocity:Float;
	
	public var friction(get, set):Vector2D;
	public var fx(get, set):Float;
	public var fy(get, set):Float;
	public var angularFriction:Float;
	
	public var inMotion(get, never):Bool;
	
	// (optional) maximum velocities
	public var max_v:Float = 0;
	public var max_av:Float = 0;
	
	
	private var _a:Vector2D;
	private var _v:Vector2D;
	private var _f:Vector2D;

	public function new( vx:Float = 0, vy:Float = 0, av:Float = 0, ax:Float = 0, ay:Float = 0, aa:Float = 0, fx:Float = 1, fy:Float = 1, af:Float = 1 ) 
	{
		_a = new Vector2D();
		_v = new Vector2D();
		_f = new Vector2D();
		set(vx, vy, av, ax, ay, aa, fx, fy, af);
	}
	
	public function set( vx:Float = 0, vy:Float = 0, av:Float = 0, ax:Float = 0, ay:Float = 0, aa:Float = 0, fx:Float = 1, fy:Float = 1, af:Float = 1 ) 
	{
		_v.x = vx;
		_v.y = vy;
		angularVelocity = av;
		
		_a.x = ax;
		_a.y = ay;
		angularAcceleration = aa;
		
		_f.x = fx;
		_f.y = fy;
		angularFriction = af;
	}
	
	public function apply( t:Transform, delta:Float, updateMotion:Bool = true ) :Transform 
	{
		if (delta < 0 || Math.isNaN(delta)) { return t; }
		
		if (updateMotion)
			update( delta * 0.5, true );
		
		// allow for self update only
		if (t != null) {
			t.x += _v.x * delta;
			t.y += _v.y * delta;
			t.rotation += angularVelocity * delta;
		}
		
		if (updateMotion)
			update( delta * 0.5, true );
		
		return t;
	}
	
	// Update the velocity with acceleration and friction 
	public function update( delta:Float, half:Bool = false ) :Void {
		
		_updateLinear( delta, half );		
		_updateRotation( delta, half );
		_constrain(); // make sure the velocity is within the set bounds
	}
	
	// Update the x,y velocity
	private function _updateLinear( delta:Float, half:Bool = false ) :Void 
	{
		// apply acceleration
		if (_a.y != 0 || _a.x != 0) {
			_v.x += _a.x * delta;
			_v.y += _a.y * delta;
		}
		// apply friction
		if (_f.x != 0 && _v.x != 0) {	
			if (_v.x > 0)
				_v.x -= Math.abs(_v.x) * _f.x * (half ? 0.5 : 1);
			else 
				_v.x += Math.abs(_v.x) * _f.x * (half ? 0.5 : 1);
		}
		if (_f.y != 0 && _v.y != 0) {
			if (_v.y > 0)
				_v.y -= Math.abs(_v.y) * _f.y * (half ? 0.5 : 1);
			else 
				_v.y += Math.abs(_v.y) * _f.y * (half ? 0.5 : 1);
		}		
	}
	// Update the angular velocity
	private function _updateRotation( delta:Float, half:Bool = false ) :Void 
	{
		// apply acceleration
		if ( angularAcceleration != 0 ) {
			angularVelocity += angularAcceleration * delta;
		}
		// apply friction
		if ( angularVelocity != 0 && angularFriction != 0 ) {
			if ( angularVelocity > 0 ) {
				angularVelocity -= Math.abs(angularVelocity) * angularFriction * (half ? 0.5 : 1);
			} else {
				angularVelocity += Math.abs(angularVelocity) * angularFriction * (half ? 0.5 : 1);
			}
		}		
		
	}
	
	private function _constrain() :Void
	{
		// don't allow for velocities between -0.999... and 0.999...
		if (_v.x < 1 && _v.x > -1) { _v.x = 0; }
		if (_v.y < 1 && _v.y > -1) { _v.y = 0; }
		if (angularVelocity < 1 && angularVelocity > -1) { angularVelocity = 0; }
		
		// keep velocities between maximums
		if (max_v != 0 && _v.x != 0 && _v.y != 0)
		{
			if (Math.abs(_v.x * _v.x + _v.y * _v.y) > Math.abs(max_v * max_v)) {
				_v.normalize();
				_v.scale(max_v);
			}
		}
		
		if (max_av != 0 && angularVelocity != 0) 
		{
			if ( angularVelocity > max_av ) { 
				angularVelocity = max_av;
			} 
			else
			if ( angularVelocity < -max_av ) {
				angularVelocity = -max_av;
			}
		}
	}
	
	/*
	 * Getters & Setters
	 */
	
	private function get_acceleration() 			:Vector2D 	{ return _a; }
	private function set_acceleration( a:Vector2D ) :Vector2D 	{ return _a = a; } 
	
	private function get_ax() 						:Float 		{ return _a.x; }	
	private function get_ay() 						:Float 		{ return _a.y; }
	private function set_ax( ax:Float ) 			:Float 		{ return _a.x = ax; }
	private function set_ay( ay:Float ) 			:Float 		{ return _a.y = ay; }
	 
	private function get_velocity() 				:Vector2D 	{ return _v; }
	private function set_velocity( v:Vector2D ) 	:Vector2D 	{ return _v = v; }
	
	private function get_vx() 						:Float 		{ return _v.x; }	
	private function get_vy() 						:Float 		{ return _v.y; }
	private function set_vx( vx:Float ) 			:Float 		{ return _v.x = vx; }
	private function set_vy( vy:Float ) 			:Float 		{ return _v.y = vy; }
	
	private function get_friction() 				:Vector2D	{ return _f; }
	private function set_friction( f:Vector2D ) 	:Vector2D	{ return _f = f; }
		
	private function get_fx() 						:Float 		{ return _f.x; }	
	private function get_fy() 						:Float 		{ return _f.y; }
	private function set_fx( fx:Float ) 			:Float 		{ return _f.x = fx; }
	private function set_fy( fy:Float ) 			:Float 		{ return _f.y = fy; }
	
	private function get_inMotion() :Bool 
	{ 
		return (_v.x != 0 || _v.y != 0 || angularVelocity != 0) ||
		 (_a.x != 0 || _a.y != 0 || angularAcceleration != 0);
	}
	
	
	public function free() :Void 
	{		
		_a.x = 0;
		_a.y = 0;
		_v.x = 0;
		_v.y = 0;
		_f.x = 1;
		_f.y = 1;
		
		angularAcceleration = 0;
		angularVelocity = 0;
		angularFriction = 1;
		
		max_v = 0;
		max_av = 0;
		
		_free = true;
	}
	public function get_free() :Bool { return _free; }
	public function set_free( free:Bool ) :Bool { return _free = free; }
	private var _free:Bool = false;
	
}