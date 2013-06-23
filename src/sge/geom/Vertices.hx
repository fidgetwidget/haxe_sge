package sge.geom;

import flash.geom.Point;

import sge.math.Vector2D;

/**
 * ...
 * @author fidgetwidget
 */
class Vertices
{
	public static inline var POSITION_BEFORE:String = "before";
	public static inline var POSITION_AFTER:String = "after";

	/*
	 * Properties 
	 */
	public var length(get, never) :Int;
	
	/*
	 * Members 
	 */
	private var _verts:Array<Vector2D>;
	
	public function new( points:Array<Point> = null ) 
	{	
		_verts = new Array<Vector2D>();
		if (points != null) {
			for (p in points) {
				_verts.push(Vector2D.fromPoint(p));
			}
		}
	}
	
	
	public function remove( v:Vector2D ) :Bool
	{
		return _verts.remove(v);
	}
	
	public inline function get( index:Int ) :Vector2D
	{
		return (_verts == null ? null : _verts[index]);
	}
	
	public function setAt( v:Vector2D, index:Int ) :Void 
	{
		if (_verts.length < index) { return; }
		_verts[index] = v;
	}
	
	public inline function getLast() :Vector2D 
	{
		return (_verts == null ? null : _verts[_verts.length - 1]);
	}
	
	public function add( v:Vector2D ) :Int 
	{
		return _verts.push(v);
	}	
	
	
	public function setPoint( index:Int, x:Float, y:Float ) :Bool 
	{
		if (_verts.length < index) {
			_verts[index].x = x;
			_verts[index].y = y;
			return true;
		}
		return false;
	}
	
	public function addPoint( x:Float, y:Float ) :Int
	{
		return _verts.push(new Vector2D(x, y));
	}
	
	public function insertPoint( v:Vector2D, x:Float, y:Float, position:String = POSITION_AFTER ) :Void {
		
		for (i in 0..._verts.length) {
			if (_verts[i] == v)
			{
				switch ( position ) 
				{
					case POSITION_BEFORE:
						_verts.insert(i, new Vector2D(x, y));
						break;
					case POSITION_AFTER:
						_verts.insert(i + 1, new Vector2D(x, y));
						break;
				}
				return;
			}
		}
		// if the point doesn't exist, then just add the line to the end of the verticies
		addPoint(x, y);		
	}
	
	// Remove all points from the list
	public function clear() :Void {
		_verts.splice(0, _verts.length);
	}
	
	private inline function get_length() :Int
	{
		return (_verts == null ? 0 : _verts.length);
	}
	
	public function iterator() :Iterator<Vector2D> {
		return _verts.iterator();
	}
	
}