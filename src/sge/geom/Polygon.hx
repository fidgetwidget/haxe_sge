package sge.geom;

import nme.display.Graphics;
import nme.geom.Matrix;
import nme.geom.Point;
import sge.physics.AABB;
import sge.physics.Vec2;

import sge.physics.Transform;

/**
 * ...
 * @author fidgetwidget
 */

class Polygon extends Shape
{
	
	/*
	 * Properties
	 */
	public var vertices:Vertices;
	public var transformed(get_transformed, never):Vertices;
	
	/*
	 * Members
	 */
	private var _transformed:Vertices;
	private var _center:Vec2;
	private var _bounds:AABB;
	
	/**
	 * Constructor
	 * @param	x - x axis origin offset value 
	 * @param	y - y axis origin offset value
	 * @param	points (optional)
	 */
	public function new(x:Float = 0, y:Float = 0, points:Array<Point> = null) 
	{
		super(x, y);
		vertices = new Vertices(points);
		_center = new Vec2();
		_bounds = new AABB();
		_transformed = new Vertices();
	}
	
	public override function free() :Void 
	{
		super.free();
		vertices.clear();
		_center.free();
		_bounds.free();
		_transformed.clear();
	}
	
	public override function inBounds(x:Float, y:Float) :Bool 
	{		
		get_bounds();
		return _bounds.containsPoint(x, y);
	}
	
	/**
	 * Render Method
	 * @param	graphics
	 */
	public override function draw( graphics:Graphics ) :Void 
	{		
		var v:Vec2;
		
		// make sure we have an up to date set of vertices
		get_transformed();
		
		// start at the end position
		v = _transformed.getLast();
		
		graphics.moveTo(v.x, v.y);
		// draw to points 0 ... last
		var count = _transformed.length;
		for (i in 0...count) {
			v = _transformed.get(i);
			graphics.lineTo(v.x, v.y);
		}
	}
	
	/// Returns the transformed verticies
	public function get_transformed() :Vertices 
	{
		if (!_isTransformed) {
			var m:Matrix = _transform.getMatrix();

			_transformed.clear();
			var count = vertices.length;
			var v:Vec2 = vertices.get(0);
			_bounds.expandLeft	 (v.x);
			_bounds.expandRight	 (v.x);
			_bounds.expandTop	 (v.y);
			_bounds.expandBottom (v.y);
			
            for (i in 1...count) {
				v = vertices.get(i);
				_bounds.expandLeft	 ( Math.min(v.x, _bounds.left) );
				_bounds.expandRight	 ( Math.max(v.x, _bounds.right) );
				_bounds.expandTop	 ( Math.min(v.y, _bounds.top) );
				_bounds.expandBottom ( Math.max(v.y, _bounds.bottom) );				
                _transformed.add( vertices.get(i) );
            }
			
			_center.x = _bounds.cx;
			_center.y = _bounds.cy;
			_isTransformed = true;
		}		
		return _transformed;
	}
	
	public function get_center() :Vec2 
	{ 
		if (!_isTransformed) {
			get_transformed();
		}
		return _center; 
	}
	
	public function get_bounds() :AABB 
	{
		if (!_isTransformed) {
			get_transformed();
		}
		return _bounds;
	}
	
}