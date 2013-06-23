package sge.geom;

import flash.display.Graphics;

import sge.collision.AABB;
import sge.graphics.Camera;

/**
 * ...
 * @author fidgetwidget
 */

class Box extends Shape {
	
	
	public var width:Float;
	public var height:Float;
	
	/**
	 * Constructor
	 * @param	x - x axis position value 
	 * @param	y - y axis position value
	 * @param	width - box shape width
	 * @param   height - box shape height
	 */
	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0 ) 
	{
		super(x, y);
		this.width = width;
		this.height = height;
	}
	
	override public function free() :Void 
	{
		super.free();
		width = 0;
		height = 0;
	}
	
	/// Draw the transformed version of the Shape
	override public function draw( graphics:Graphics, camera:Camera = null ) :Void 
	{
		if (camera == null) 
			graphics.drawRect(ix, iy, width, height);
		else 
			graphics.drawRect(ix - camera.ix, iy - camera.iy, width, height);
	}
	
	override public function get_bounds():AABB 
	{
		if (_bounds == null) 
			_bounds = new AABB();
		_bounds.setRect(x, y, width, height);
		return _bounds;
	}
	
}