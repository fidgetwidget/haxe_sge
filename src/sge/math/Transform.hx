package sge.math;

import flash.geom.Matrix;

import sge.lib.IRecyclable;


/**
 * Transform 
 * (a class for sharing transform data between objects)
 * has position, rotation, and scale data (and z - paralax depth)
 * 
 * position: 	x, y position relative to its parent.
 * z:			z draw position, used for draw order and paralax effects.
 * rotation:	rotation value relative to its parent.
 * scale:		x, y scale values relative to its parent.
 * @author fidgetwidget
 */
 
class Transform implements IRecyclable
{
	
	/*
	 * Properties 
	 */
	public var position(get_position, set_position):Vector2D;
	public var x(get_x, set_x):Float;
	public var y(get_y, set_y):Float;
	public var ix(get_ix, set_ix):Int;
	public var iy(get_iy, set_iy):Int;
		
	public var z(get_z, set_z):Float; // used for draw order and paralax scroll multiplication
	
	public var rotation(get_rotation, set_rotation):Float;
	
	public var scale(get_scale, set_scale):Vector2D;
	public var scaleX(get_scaleX, set_scaleX):Float;
	public var scaleY(get_scaleY, set_scaleY):Float;
	
	/*
	 * Members
	 */
	private var _p:Vector2D; // position
	private var _ix:Int;
	private var _iy:Int;
	private var _z:Float; 
	private var _r:Float;
	private var _s:Vector2D; // scale
	
	private var _transformed:Bool = false;
	private var _m:Matrix;
	
	public function new( x:Float = 0, y:Float = 0, z:Float = 0, rotation:Float = 0, scale_x:Float = 1, scale_y:Float = 1 ) 
	{
		_p = new Vector2D();
		_s = new Vector2D();
		_m = new Matrix();
		
		set(x, y, z, rotation, scale_x, scale_y);
	}
	
	public function set( x:Float = 0, y:Float = 0, z:Float = 0, rotation:Float = 0, scale_x:Float = 1, scale_y:Float = 1 ) :Void {
		
		// Position
		_p.x = x;
		_p.y = y;
		_ix = Std.int(x);
		_iy = Std.int(y);
		// Rotation
		_r = rotation;
		// Scale
		_s.x = scale_x;
		_s.y = scale_y;
		
		// Paralax/Draw Order
		_z = z;
		
	}
	
	public function getMatrix() :Matrix 
	{
		_m.identity();
		_m.tx = _p.x;
		_m.ty = _p.y;
		_m.rotate(_r * Math.PI / 180);
		_m.scale(_s.x, _s.y);
		return _m;
	}
	
	
	/**
	 * Getters & Setters
	 */
	private function get_position() 			:Vector2D 	{ return _p; }
	private function get_x() 					:Float 		{ return _p.x; }
	private function get_y() 					:Float 		{ return _p.y; }	
	private function get_ix() 					:Int 		{ return _ix; }	
	private function get_iy() 					:Int 		{ return _iy; }	
	private function get_z() 					:Float 		{ return _z; }
	private function get_rotation() 			:Float 		{ return _r; }
	private function get_scale() 				:Vector2D 	{ return _s; }
	private function get_scaleX() 				:Float 		{ return _s.x; }
	private function get_scaleY() 				:Float 		{ return _s.y; }
	
	private function set_position( p:Vector2D ) :Vector2D	{ return _p = p; }
	private function set_x( x:Float ) 			:Float 		{ _p.x = x; _ix = Std.int(x); return _p.x; }	
	private function set_y( y:Float ) 			:Float 		{ _p.y = y; _iy = Std.int(y); return _p.y; }
	private function set_ix( x:Int ) 			:Int 		{ _p.x = _ix = x; return _ix; }
	private function set_iy( y:Int ) 			:Int 		{ _p.y = _iy = y; return _iy; }	
	private function set_z( z:Float ) 			:Float 		{ return _z = z; }
	private function set_rotation( r:Float ) 	:Float 		{ return _r = r; }
	private function set_scaleX( sx:Float ) 	:Float 		{ return _s.x = sx; }
	private function set_scaleY( sy:Float ) 	:Float 		{ return _s.y = sy; }
	private function set_scale( s:Vector2D ) 	:Vector2D 	{ return _s = s; }
	
	
	/*
	 * IRecycleable 
	 */
	public function free() :Void 
	{		
		_p.x = 0;
		_p.y = 0;
		_s.x = 0;
		_s.y = 0;
		_z = 0;
		_r = 0;
		_m.identity();
		
		_free = true;
	}
	public function get_free() :Bool { return _free; }
	public function set_free( free:Bool ) :Bool { return _free = free; }
	private var _free:Bool = false;
	
}