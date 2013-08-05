package sge.geom;

import flash.display.Graphics;
import flash.errors.Error;
import flash.geom.Point;
import sge.collision.AABB;
import sge.graphics.Camera;
import sge.lib.IHasBounds;

import sge.math.Transform;

/**
 * ...
 * @author fidgetwidget
 */

class Shape implements IHasBounds
{
	
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var ix(get, set):Int;
	public var iy(get, set):Int;
	public var rotation(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	
	private var _transform:Transform;
	private var _isTransformed:Bool = false;
	private var _bounds:AABB;
	
	/**
	 * Constructor
	 * @param	x - x axis position value 
	 * @param	y - y axis position value
	 */
	public function new( x:Float, y:Float ) 
	{
		_transform = new Transform(x, y);
	}
	
	public function free() :Void {
		_transform.free();
	}
	
	public function draw( graphics:Graphics, camera:Camera = null ) :Void {
		throw "Shape's \"draw\" is an abstract method.";
	}
	
	/// NOTE: this doesn't assign the transform object, but just its values - in order to preserve the '_isTransformed' bool
	public function setTransform( t:Transform ) :Void {
		_isTransformed = false;
		_transform.set(t.x, t.y, t.z, t.rotation, t.scaleX, t.scaleY);
	}
	
	private function get_x() :Float 				{ return _transform.x; }
	private function get_y() :Float 				{ return _transform.y; }
	private function get_ix() :Int					{ return _transform.ix; }
	private function get_iy() :Int					{ return _transform.iy; }
	private function get_rotation() :Float 			{ return _transform.rotation; }
	private function get_scaleX() :Float 			{ return _transform.scaleX; }
	private function get_scaleY() :Float 			{ return _transform.scaleY; }
	
	private function set_x( x:Float ) :Float 		{ _isTransformed = false; return _transform.x = x; }
	private function set_y( y:Float ) :Float 		{ _isTransformed = false; return _transform.y = y; }
	private function set_ix( ix:Int ) :Int			{ _isTransformed = false; return _transform.ix = ix; }
	private function set_iy( iy:Int ) :Int			{ _isTransformed = false; return _transform.iy = iy; }
	private function set_rotation( r:Float ) :Float { _isTransformed = false; return _transform.rotation = r; }
	private function set_scaleX( x:Float ) :Float 	{ _isTransformed = false; return _transform.scaleX = x; } 
	private function set_scaleY( y:Float ) :Float 	{ _isTransformed = false; return _transform.scaleY = y; }
	
	
	public function get_bounds():AABB 
	{		
		throw "Shape's \"get_bounds\" is an abstract method.";
		return _bounds;
	}
	
	
	/*
	 * Static Shape Factory functions * 
	 * TODO: add recycling
	 */
	
	public static function makeCircle( x:Float, y:Float, radius:Float ) :Circle 
	{
		return new Circle(x, y, radius);
	}
	
	public static function makeBox( x:Float, y:Float, width:Float, height:Float ) :Box 
	{
		return new Box(x, y, width, height);
	}
	
	public static function makeTriangle( x:Float, y:Float, radius:Float ) :Polygon
	{
		return makePolygon( x, y, radius, 3 );
	}
	
	public static function makePolygon( x:Float, y:Float, radius:Float, sides:Int ) :Polygon
	{
		if (sides < 3) { throw "Polgons require 3 or more sides."; return null; }
		
		var points:Array<Point> = [];
		var p:Point;
		var angle:Float;
		var rotation = (Math.PI * 2) / sides;
		
		for ( i in 0...sides ) {
			angle = i * rotation;
			p = new Point();
			p.x = Math.cos(angle) * radius;
			p.y = Math.sin(angle) * radius;
			points.push(p);
		}
		return new Polygon( x, y, points );
	}
	
}