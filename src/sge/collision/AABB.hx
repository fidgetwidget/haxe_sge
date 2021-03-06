package sge.collision;

import flash.display.Graphics;

import sge.lib.IRecyclable;
import sge.math.Vector2D;

/**
 * Axis Aligned Bounding Box 
 * meant to be used for FAST collision detection  
 * TODO: improve performance
 *       create a AABB Factory for recycling these
 * 
 * @author fidgetwidget
 */

class AABB implements IRecyclable
{
	
	/*
	 * Properties
	 */
	public var x(get, set)			: Float;	// Left
	public var y(get, set)			: Float;	// Top
	public var width(get, set) 		: Float;
	public var height(get, set) 	: Float;
	
	public var cx(get, set)			: Float;
	public var cy(get, set)			: Float;
	public var center(get, set) 	: Vector2D;
	public var hWidth(get, never)	: Float;
	public var hHeight(get, never)	: Float;	
	public var minX(get, set) 		: Float; 	// Left
	public var maxX(get, set) 		: Float; 	// Right
	public var minY(get, set)		: Float; 	// Top
	public var maxY(get, set) 		: Float; 	// Bottom
	public var left(get, set) 		: Float;
	public var right(get, set) 		: Float;
	public var top(get, set) 		: Float;
	public var bottom(get, set) 	: Float;
	
	/*
	 * Members
	 */
	private var _center		: Vector2D;
	private var _extents	: Vector2D;
		
	public function new()  
	{
		_center = new Vector2D(); 
		_extents = new Vector2D();
	}

	public function set( x:Float, y:Float, halfWidth:Float, halfHeight:Float ) :AABB
	{
		_center.x = x;
		_center.y = y;
		_extents.x = halfWidth;
		_extents.y = halfHeight;
		return this;
	}
	
	public function setRect( x:Float, y:Float, width:Float, height:Float, fromCenter:Bool = false ) :AABB
	{		
		_extents.x = width * 0.5;
		_extents.y = height * 0.5;
		_center.x = x + (fromCenter ? 0 : _extents.x);
		_center.y = y + (fromCenter ? 0 : _extents.y);
		
		return this;
	}
	public function setMinMax( minX:Float, minY:Float, maxX:Float, maxY:Float ) :AABB
	{
		_extents.x = (maxX - minX) * 0.5;
		_extents.y = (maxY - minY) * 0.5;
		_center.x = minX + _extents.x;
		_center.y = minY + _extents.y;
		return this;
	}
	
	public function combine( aabb:AABB ) :Void
	{
		var l:Float = Math.min(aabb.left, left);
		var r:Float = Math.max(aabb.right, right);
		var t:Float = Math.min(aabb.top, top);
		var b:Float = Math.max(aabb.bottom, bottom); 
		_extents.x = (r - l) * 0.5;
		_extents.y = (b - t) * 0.5;
		_center.x = l + _extents.x;
		_center.y = t + _extents.y;
	}
	
	// adjust the size and center from the given new side position
	public function expandLeft( l:Float ) 	
	{ 
		_extents.x = ((_center.x + _extents.x) - l) * 0.5; 
		_center.x = l + _extents.x; 
	}
	public function expandRight( r:Float ) 	
	{ 
		_extents.x = (r - (_center.x - _extents.x)) * 0.5; 
		_center.x = r - _extents.x; 
	}
	public function expandTop( t:Float ) 	
	{ 
		_extents.y = ((_center.y + _extents.y) - t) * 0.5; 
		_center.y = t + _extents.y; 
	}
	public function expandBottom( b:Float ) 
	{ 
		_extents.y = (b - (_center.y - _extents.y)) * 0.5; 
		_center.y = b - _extents.y; 
	}
	
	/* Contains Functions */
	public function containsPoint( x:Float, y:Float) :Bool
	{
		return aabbContainsPoint(this, x, y);
	}
	
	public function containsAabb( aabb:AABB ) :Bool
	{
		return 	aabbContainsPoint(this, aabb.left, aabb.top) &&
				aabbContainsPoint(this, aabb.right, aabb.bottom);
	}
	
	public function containsRectXYWidthHeight( x:Float, y:Float, width:Float, height:Float ) :Bool 
	{
		return 	aabbContainsPoint(this, x, y) &&
				aabbContainsPoint(this, x + width, y + height);
	}
	
	public function containsLine( x1:Float, y1:Float, x2:Float, y2:Float ) :Bool
	{
		return 	aabbContainsPoint(this, x1, y1) &&
				aabbContainsPoint(this, x2, y2);
	}
	
	/* Intersects Functions */
	public function intersectsAabb( aabb:AABB ) :Bool
	{		
		if ( Math.abs(this.cx - aabb.cx) > ((width + aabb.width) * 0.5)) return false;
		if ( Math.abs(this.cy - aabb.cy) > ((height + aabb.height) * 0.5)) return false;
		return true;
	}
	
	public function intersectsRect( x:Float, y:Float, width:Float, height:Float ) :Bool
	{
		return aabbIntersectsRect(this, x, y, width, height);
	}
	
	public function intersectsLine( x1:Float, y1:Float, x2:Float, y2:Float ) :Bool
	{
		// early exit
		if (x1 < minX && x2 < minX) { return false; }
		if (x1 > maxX && x2 > maxX) { return false; }
		if (y1 < minY && y2 < minY) { return false; }
		if (y1 > maxY && y2 > maxY) { return false; }
		// check for contains (either end of the line)
		if (containsPoint(x1, y1) || containsPoint(x2, y2)) { return true; }
		
		// TODO: check other collision possibilities
		
		return false;
	}
	
	/// Render
	public function draw( graphics:Graphics ) :Void 
	{
		graphics.drawRect(x, y, width, height);
	}
	
	
	/*
	 * Getters & Setters
	 */		
	private inline function get_cx() 				: Float 	{ return _center.x; }
	private inline function get_cy() 				: Float 	{ return _center.y; }
	private inline function get_center()			: Vector2D	{ return _center; }
	private inline function get_width() 			: Float 	{ return _extents.x * 2; }
	private inline function get_height() 			: Float 	{ return _extents.y * 2; }
	private inline function get_hWidth() 			: Float 	{ return _extents.x; }
	private inline function get_hHeight() 			: Float 	{ return _extents.y; }
	private inline function get_x()					: Float 	{ return _center.x - _extents.x; }
	private inline function get_y()					: Float 	{ return _center.y - _extents.y; }
	private inline function get_minX() 				: Float 	{ return _center.x - _extents.x; }
	private inline function get_maxX() 				: Float 	{ return _center.x + _extents.x; }
	private inline function get_minY() 				: Float 	{ return _center.y - _extents.y; }
	private inline function get_maxY() 				: Float		{ return _center.y + _extents.y; }
	private inline function get_left() 				: Float 	{ return _center.x - _extents.x; }
	private inline function get_right()				: Float 	{ return _center.x + _extents.x; }
	private inline function get_top() 				: Float 	{ return _center.y - _extents.y; }
	private inline function get_bottom()			: Float		{ return _center.y + _extents.y; }
	
	private inline function set_cx( x:Float ) 		: Float		{ return _center.x = x; }	
	private inline function set_cy( y:Float ) 		: Float		{ return _center.y = y; }
	private inline function set_center( c:Vector2D ) : Vector2D	
	{ 
		_center.x = c.x; 
		_center.y = c.y; 
		return _center; 
	}
	private inline function set_width( w:Float ) 	: Float		{ return _extents.x = w * 0.5; }
	private inline function set_height( h:Float )	: Float		{ return _extents.y = h * 0.5; }
	
	// adjusts the position based on the new min/max
	private inline function set_x( x:Float ) 		: Float 	{ return _center.x = x + _extents.x; }
	private inline function set_y( y:Float ) 		: Float 	{ return _center.y = y + _extents.y; }
	private inline function set_minX( x:Float ) 	: Float 	{ return _center.x = x + _extents.x; }
	private inline function set_maxX( x:Float ) 	: Float 	{ return _center.x = x - _extents.x; }
	private inline function set_minY( y:Float ) 	: Float 	{ return _center.y = y + _extents.y; }
	private inline function set_maxY( y:Float ) 	: Float 	{ return _center.y = y - _extents.y; }
	private inline function set_left( x:Float ) 	: Float 	{ return _center.x = x + _extents.x; }
	private inline function set_right( x:Float ) 	: Float 	{ return _center.x = x - _extents.x; }
	private inline function set_top( y:Float ) 		: Float 	{ return _center.y = y + _extents.y; }
	private inline function set_bottom( y:Float ) 	: Float 	{ return _center.y = y - _extents.y; }
	
	/*
	 * IRecycleable 
	 */
	public function free() :Void 
	{		
		_center.free();
		_extents.free();
		_free = true;
	}
	public function get_free() :Bool { return _free; }
	public function set_free( free:Bool ) :Bool { return _free = free; }
	private var _free:Bool = false;
	
	// static AABB Collisions
	public static inline function aabbContainsPoint( 
		aabb:AABB, 
		x:Float, y:Float ) :Bool
	{
		return ((x <= aabb.right && x >= aabb.left) && 
				(y <= aabb.bottom && y >= aabb.top) );
	}

	public static inline function aabbIntersectsRect( 
		aabb:AABB, 
		x:Float, y:Float, 
		width:Float, height:Float ) :Bool
	{
		var dx = Math.abs(aabb._center.x - x + width * 0.5);
		var dy = Math.abs(aabb._center.y - y + height * 0.5);
		var xx = ( (aabb.width + width) * 0.5);		var yy = ( (aabb.height + height) * 0.5);
		return ( xx >= dx && yy >= dy );
	}
}