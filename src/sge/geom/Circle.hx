package sge.geom;

import nme.display.Graphics;
import sge.physics.Transform;

/**
 * ...
 * @author fidgetwidget
 */

class Circle extends Shape
{

	public var radius:Float;
	public var transformedRadius(get_transformedRadius, never):Float;
	
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
	
	public override function free() :Void 
	{
		super.free();
		radius = 0;
	}
	
	public override function inBounds(x:Float, y:Float) :Bool 
	{		
		dx = this.x - x;
		dy = this.y - y;
		return (dx * dx + dy * dy) <= (radius * radius);
	}
	private var dx:Float;
	private var dy:Float;
	
	/// Draw the transformed version of the Shape
	public override function draw( graphics:Graphics ) :Void 
	{		
		graphics.drawCircle(x, y, radius * scaleX);
	}
	
	/*
	 * Circle Shape Property Changes 
	 */
	/// Scale will effect BOTH horizontal and vertical for circles
	private override function set_scaleX( x:Float ) :Float { _isTransformed = false; _transform.scaleX = x; return _transform.scaleY = x; }
	private override function set_scaleY( y:Float ) :Float { _isTransformed = false; _transform.scaleX = y; return _transform.scaleY = y; }
	
	private function get_transformedRadius() :Float { return radius * _transform.scaleX; }
}