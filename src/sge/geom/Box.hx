package sge.geom;

import nme.display.Graphics;

import sge.physics.AABB;

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
	
	public override function free() :Void 
	{
		super.free();
		width = 0;
		height = 0;
	}
	
	public override function inBounds(x:Float, y:Float) :Bool 
	{		
		if (x < this.x || x > this.x + width) { return false; }
		if (y < this.y || y > this.y + height) { return false; }
		return true;
	}
	
	/// Draw the transformed version of the Shape
	public override function draw( graphics:Graphics ) :Void 
	{		
		graphics.drawRect(x, y, width, height);
	}
	
}