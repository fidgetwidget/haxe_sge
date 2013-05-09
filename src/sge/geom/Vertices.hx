package sge.geom;

import nme.geom.Point;

import sge.physics.Vec2;

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
	public var length(get_length, never) :Int;
	
	/*
	 * Members 
	 */
	private var _verts:Array<Vec2>;
	
	public function new( points:Array<Point> = null ) 
	{	
		_verts = new Array<Vec2>();
		if (points != null) {
			for (p in points) {
				_verts.push(Vec2.fromPoint(p));
			}
		}
	}
	
	
	public function remove( v:Vec2 ) :Bool
	{
		return _verts.remove(v);
	}
	
	public inline function get( index:Int ) :Vec2
	{
		return (_verts == null ? null : _verts[index]);
	}
	
	public function setAt( v:Vec2, index:Int ) :Void 
	{
		if (_verts.length < index) { return; }
		_verts[index] = v;
	}
	
	public inline function getLast() :Vec2 
	{
		return (_verts == null ? null : _verts[_verts.length - 1]);
	}
	
	public function add( v:Vec2 ) :Int {
		return _verts.push(v);
	}
	
	
	
	
	public function set_XY( index:Int, x:Float, y:Float ) :Bool 
	{
		if (_verts.length < index) {
			_verts[index].x = x;
			_verts[index].y = y;
			return true;
		}
		return false;
	}
	
	public function set_Point( index:Int, point:Point ) :Bool
	{
		if (_verts.length < index) {
			_verts[index].x = point.x;
			_verts[index].y = point.y;
			return true;
		}
		return false;		
	}
	
	
	// add a point to the end of the line list
	public function add_Point( point:Point ) :Int 
	{
		return _verts.push( Vec2.fromPoint(point) );
	}
	// add a line to the end of the line list
	public function add_LineSegment( seg:LineSegment ) :Int
	{
		_verts.push( seg.start );
		return _verts.push( seg.end );
	}
	
	
	public function insert( v:Vec2, seg:LineSegment, position:String = POSITION_AFTER ) :Void {
		
		for (i in 0..._verts.length) {
			if (_verts[i] == v)
			{
				switch ( position ) 
				{
					case POSITION_BEFORE:
						_verts.insert(i, seg.end);
						_verts.insert(i, seg.start);
						break;
					case POSITION_AFTER:
						_verts.insert(i + 1, seg.end);
						_verts.insert(i + 1, seg.start);
						break;
				}
				return;
			}
		}
		// if the point doesn't exist, then just add the line to the end of the verticies
		add_LineSegment(seg);		
	}
	
	// Remove all points from the list
	public function clear() :Void {
		_verts.splice(0, _verts.length);
	}
	
	private inline function get_length() :Int
	{
		return (_verts == null ? 0 : _verts.length);
	}
	
	public function iterator() :Iterator<Vec2> {
		return _verts.iterator();
	}
	
	
	
}