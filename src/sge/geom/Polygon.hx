package sge.geom;

import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Point;

import sge.collision.AABB;
import sge.graphics.Camera;
import sge.math.Vector2D;
import sge.math.Transform;

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
	private var _center:Vector2D;
	
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
		_center = new Vector2D();
		_bounds = new AABB();
		_transformed = new Vertices();
		_isTransformed = false;
	}
	
	public override function free() :Void 
	{
		super.free();
		vertices.clear();
		_center.free();
		_bounds.free();
		_transformed.clear();
	}
	
	/**
	 * Render Method
	 * @param	graphics
	 */
	public override function draw( graphics:Graphics, camera:Camera = null ) :Void 
	{		
		if (_offset == null) {
			_offset = new Vector2D();
		}
		if (camera != null) {
			_offset.x = camera.ix;
			_offset.y = camera.iy;
		}
		// make sure we have an up to date set of vertices
		get_transformed();
		
		// start at the end position
		_v = _transformed.getLast();
		
		graphics.moveTo(ix + _v.x - _offset.x, iy + _v.y - _offset.y);
		// draw to points 0 ... last
		var count = _transformed.length;
		for (i in 0...count) {
			_v = _transformed.get(i);
			graphics.lineTo(x + _v.x - _offset.x, iy + _v.y - _offset.y);
		}
	}
	private var _v:Vector2D;	
	private var _offset:Vector2D;
	
	/// Returns the transformed verticies
	public function get_transformed() :Vertices 
	{
		if (!_isTransformed) {
			var m:Matrix = _transform.getMatrix();

			_transformed.clear();
			var count = vertices.length;
			var v:Vector2D = vertices.get(0);
			_bounds.expandLeft	 (v.x);
			_bounds.expandRight	 (v.x);
			_bounds.expandTop	 (v.y);
			_bounds.expandBottom (v.y);
			_transformed.add( v.clone() );
			
            for (i in 1...count) {
				v = vertices.get(i);
				_bounds.expandLeft	 ( Math.min(v.x, _bounds.left) );
				_bounds.expandRight	 ( Math.max(v.x, _bounds.right) );
				_bounds.expandTop	 ( Math.min(v.y, _bounds.top) );
				_bounds.expandBottom ( Math.max(v.y, _bounds.bottom) );
                _transformed.add( v.clone() );
            }
			
			_center.x = _bounds.cx;
			_center.y = _bounds.cy;
			_isTransformed = true;
		}		
		return _transformed;
	}
	
	public function get_center() :Vector2D 
	{ 
		if (!_isTransformed) {
			get_transformed();
		}
		return _center; 
	}
	
	override public function get_bounds() :AABB 
	{
		if (!_isTransformed) {
			get_transformed();
		}
		return _bounds;
	}
	
}