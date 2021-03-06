package sge.math;

import flash.geom.Point;
import flash.geom.Matrix;

import sge.lib.IRecyclable;

/**
 * ...
 * @author fidgetwidget
 */
class Vector2D
{
	
	public var x:Float;
	public var y:Float;
	public var length(get_length, never):Float;

	public function new( x:Float = 0, y:Float = 0 ) 
	{
		this.x = x;
		this.y = y;
	}
	
	// Point conversion function
	public function toPoint( p:Point = null ) :Point
	{
		if (p == null) { p = new Point(); }
		p.x = x;
		p.y = y;
		return p;
	}
	
	public function set( x:Float, y:Float ) :Void {
		this.x = x;
		this.y = y;
	}
	
	public function setFromVector( v:Vector2D ) :Void {
		x = v.x;
		y = v.y;
	}
	public function setFromPoint( p:Point ) :Void {
		x = p.x;
		y = p.y;
	}
	
	public function clone() :Vector2D {
		var v:Vector2D = new Vector2D();
		v.x = x;
		v.y = y;
		return v;		
	}
	
	// --- Math functions
	
	// Normalization functions
	// bring the vectors megantude(length) to 1 while 
	// maintaining the direction
	public function normalize() :Void
	{
		var l:Float = length;
		x = x / l;
		y = y / l;
		return;
	}
	
	public function transform( m:Matrix ) :Void {
		x = x*m.a + y*m.c + m.tx;
		y = x*m.b + y*m.d + m.ty;		
	}
	
	
	public inline function leftNormal() :Void
	{
		var _x:Float = x;
		x = -y;
		y = _x;
		return;
	}
	
	public inline function rightNormal() :Void
	{
		var _x:Float = x;
		x = y;
		y = -_x;
		return;
	}
	
	// basic aritmatic functions
	public inline function scale( scaler:Float ) :Void
	{
		x *= scaler;
		y *= scaler;
		return;
	}
	
	
	// clamp the vector to within a maximum length
	public function clamp( max:Float ) :Void
	{
		// only clamp if we exceded max
		if (x * x + y * y > max * max)
		{
			normalize();
			this.scale( max );
		}
		return;
	}
	// determin if the vector megnatude is less or equal to the given range
	public inline function withinRange( range:Float ) :Bool
	{
		return x * x + y * y <= range * range;
	}
	
	// returns the dot product of this vector and the given values
	public inline function dotProduct(x:Float, y:Float) :Float
	{
		return this.x * x + this.y * y;
	}
	
	// returns the cross product of this vector and the given values
	public inline function crossProduct(x:Float, y:Float) :Float
	{
		return this.x * y - this.y * x;
	}
	
	// reflects this vector with the given vector values
	public inline function reflect( x:Float, y:Float ) :Void
	{
		var dp:Float = dotProduct(x, y);
		this.x = this.x + 2 * x * dp;
		this.y = this.y + 2 * y * dp;
		return;
	}
	
	// returns the angle of the vector (in radians)
	public inline function angle() :Float
	{
		var angle:Float = Math.atan2(x, y);
		if (angle < 0) { angle += 2 * Math.PI; }
		return angle;
	}
	
	// the exponent value of the vector
	public inline function lengthSquared() :Float
	{
		return x * x + y * y;
	}
	
	
	public inline function get_length() :Float {
		return Math.sqrt(x * x + y * y);
	}
	
	/*
	 * IRecycleable 
	 */
	public function free() :Void 
	{		
		x = 0;
		y = 0;
		_free = true;
	}
	public function get_free() :Bool { return _free; }
	public function set_free( free:Bool ) :Bool { return _free = free; }
	private var _free:Bool = false;
	
	
	
	
	/// ------------------------------
	/// Static Math functions
	/// ------------------------------
	
	// returns the length of the given vectors values
	public static inline function lengthOf(x:Float, y:Float) :Float
	{
		return Math.sqrt(x * x + y * y);
	}
	
	// projection vector (with optimization for when vector b is a unit vector)
	public static inline function projectAOnB(ax:Float, ay:Float, bx:Float, by:Float, bIsUnit:Bool = false, result:Vector2D = null) :Vector2D
	{
		if (result == null) { result = new Vector2D(); }
		var dp:Float = ax * bx + ay * by;
		if (bIsUnit)
		{
			result.x = dp * bx;
			result.y = dp * by;
		}
		else
		{
			result.x = (dp / (bx * bx + by * by)) * bx;
			result.y = (dp / (bx * bx + by * by)) * by;
		}
		return result;
	}
	
	public static function normal( x:Float, y:Float ) :Vector2D 
	{
		var v:Vector2D = new Vector2D();
		v.x = x;
		v.y = y;
		v.normalize();
		return v;
	}
	
	public static function add( a:Vector2D, b:Vector2D ) :Vector2D 
	{
		a.x += b.x;
		a.y += b.y;
		return a;
	}
	
	public static function subtract( a:Vector2D, b:Vector2D ) :Vector2D 
	{
		a.x -= b.x;
		a.y -= b.y;
		return a;
	}
	public static function multiply( a:Vector2D, b:Vector2D ) :Vector2D 
	{
		a.x *= b.x;
		a.y *= b.y;
		return a;
	}
	
	public static function devide( a:Vector2D, b:Vector2D ) :Vector2D 
	{
		a.x /= b.x;
		a.y /= b.y;
		return a;
	}
	
	public static function transformVector( x:Float, y:Float, m:Matrix ) : Vector2D 
	{
		var v:Vector2D = new Vector2D(x, y);
		v.x = v.x*m.a + v.y*m.c + m.tx;
		v.y = v.x*m.b + v.y*m.d + m.ty;
		return v;
	}
	public static function transformVectors( a:Array<Vector2D>, m:Matrix ) : Array<Vector2D> 
	{
		for (v in a) {
			v.transform(m);
		}
		return a;
	}
	
	// Static conversion function
	// returns a new Euclidean Vector from a Point
	public static function fromPoint( p:Point ) : Vector2D
	{
		var v:Vector2D = new Vector2D();
		v.x = p.x;
		v.y = p.y;
		return v;
	}
	// returns a new Euclidean Vector from an angle (normalized)
	public static function fromAngle( angle:Float ) :Vector2D
	{
		var v:Vector2D = new Vector2D();
		v.x = Math.sin(angle);
		v.y = Math.cos(angle);
		//v.normalize(); // this should already be the case, give the angle doesn't have a magnatude
		return v;
	}
	
}