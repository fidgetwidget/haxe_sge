package sge.geom;

import nme.display.Graphics;
import nme.errors.Error;
import nme.geom.Point;

import sge.physics.Transform;

/**
 * ...
 * @author fidgetwidget
 */

class Shape 
{
	
	public var x(get_x, set_x):Float;
	public var y(get_y, set_y):Float;
	public var rotation(get_rotation, set_rotation):Float;
	public var scaleX(get_scaleX, set_scaleX):Float;
	public var scaleY(get_scaleY, set_scaleY):Float;
	
	private var _transform:Transform;		
	private var _isTransformed:Bool = false;
	
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
	
	public function draw( graphics:Graphics ) :Void {
		throw "Shape's \"draw\" is an abstract method.";
	}
	
	public function inBounds(x:Float, y:Float) :Bool {
		throw "Shape's \"inBounds\" is an abstract method.";
		return false;
	}
	
	public function setTransform( t:Transform ) :Void {
		_isTransformed = false;
		_transform.set(t.x, t.y, t.z, t.rotation, t.scaleX, t.scaleY);
	}
	
	private function get_x() :Float 				{ return _transform.x; }
	private function get_y() :Float 				{ return _transform.y; }
	private function get_rotation() :Float 			{ return _transform.rotation; }
	private function get_scaleX() :Float 			{ return _transform.scaleX; }
	private function get_scaleY() :Float 			{ return _transform.scaleY; }
	
	private function set_x( x:Float ) :Float 		{ _isTransformed = false; return _transform.x = x; }
	private function set_y( y:Float ) :Float 		{ _isTransformed = false; return _transform.y = y; }
	private function set_rotation( r:Float ) :Float { _isTransformed = false; return _transform.rotation = r; }
	private function set_scaleX( x:Float ) :Float 	{ _isTransformed = false; return _transform.scaleX = x; } 
	private function set_scaleY( y:Float ) :Float 	{ _isTransformed = false; return _transform.scaleY = y; }
	
	
	
	/*
	 * Static Shape Factory functions
	 * 
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
		var rotation = (Math.PI * 2) * 0.5;
		for ( i in 0...sides ) {
			angle = (rotation * i) + ((Math.PI - rotation) * 0.5);
			p = new Point();
			p.x = Math.cos(angle) * radius;
			p.y = Math.sin(angle) * radius;
			points.push(p);
		}
		return new Polygon( x, y, points );
	}
	
}