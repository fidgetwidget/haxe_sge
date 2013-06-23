package sge.geom;

import flash.display.Graphics;

import sge.collision.AABB;
import sge.graphics.Camera;

/**
 * ...
 * @author fidgetwidget
 */
class Circle extends Shape
{

	public var radius:Float;
	public var transformedRadius(get, never):Float;
	
	/**
	 * Constructor
	 * @param	x - x axis origin offset value 
	 * @param	y - y axis origin offset value
	 * @param	radius - circle shape radius
	 */
	public function new(x:Float = 0, y:Float = 0, radius:Float = 1) 
	{
		super(x, y);
		this.radius = radius;
	}
	
	override public function free() :Void 
	{
		super.free();
		radius = 0;
	}
	
	/// Draw the transformed version of the Shape
	override public function draw( graphics:Graphics, camera:Camera = null ) :Void 
	{		
		if (camera == null)
			graphics.drawCircle(ix, iy, radius * scaleX);
		else
			graphics.drawCircle(ix - camera.ix, iy - camera.iy, radius * scaleX);
	}
	
	override public function get_bounds():AABB 
	{
		if (_bounds == null) 
			_bounds = new AABB();		
		_bounds.set_centerHalfs(x, y, radius , radius);
		return _bounds;
	}
	
	/*
	 * Circle Shape Property Changes 
	 */
	/// Scale will effect BOTH horizontal and vertical for circles
	override private function set_scaleX( x:Float ) :Float { _isTransformed = false; _transform.scaleX = x; return _transform.scaleY = x; }
	override private function set_scaleY( y:Float ) :Float { _isTransformed = false; _transform.scaleX = y; return _transform.scaleY = y; }
	
	private function get_transformedRadius() :Float { return radius * _transform.scaleX; }
}