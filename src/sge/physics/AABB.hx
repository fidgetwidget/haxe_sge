package sge.physics;

import nme.display.Graphics;

/**
 * ...
 * @author fidget_widthidget
 */

class AABB
{
	
	/*
	 * Properties
	 */
	public var x(get_minX, set_left):Float;
	public var y(get_minY, set_top):Float;
	public var cx(get_cx, set_cx):Float;
	public var cy(get_cy, set_cy):Float;
	public var center(get_c, set_c) :Vec2;
	public var width(get_width, set_width) :Float;
	public var height(get_height, set_height) :Float;
	public var hWidth(get_hw, never):Float;
	public var hHeight(get_hh, never):Float;	
	public var minX(get_minX, set_left) :Float; // Left
	public var maxX(get_maxX, set_right) :Float; // Right
	public var minY(get_minY, set_top) :Float; // Top
	public var maxY(get_maxY, set_bottom) :Float; // Bottom
	public var left(get_minX, set_left) :Float;
	public var right(get_maxX, set_right) :Float;
	public var top(get_minY, set_top) :Float;
	public var bottom(get_maxY, set_bottom) :Float;
	
	/*
	 * Members
	 */
	private var _center:Vec2;
	private var _extents:Vec2;
		
	public function new()  
	{
		_center = new Vec2(); 
		_extents = new Vec2();
	}
	
	public function free() :Void 
	{
		_center.free();
		_extents.free();
	}
	
	public function setRect(x:Float, y:Float, width:Float, height:Float, fromCenter:Bool = false ) :AABB
	{		
		_extents.x = width * 0.5;
		_extents.y = height * 0.5;
		_center.x = x + (fromCenter ? 0 : _extents.x);
		_center.y = y + (fromCenter ? 0 : _extents.y);
		
		return this;
	}
	public function set_centerHalfs( cx:Float, cy:Float, halfWidth:Float, halfHeight:Float ) :AABB
	{
		_center.x = cx;
		_center.y = cy;
		_extents.x = halfWidth;
		_extents.y = halfHeight;
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
		var l:Float 	= Math.min(aabb.left, left);
		var r:Float 	= Math.max(aabb.right, right);
		var t:Float 	= Math.min(aabb.top, top);
		var b:Float 	= Math.max(aabb.bottom, bottom); 
		_extents.x = (r - l) * 0.5;
		_extents.y = (b - t) * 0.5;
		_center.x = l + _extents.x;
		_center.y = t + _extents.y;
	}
	
	// adjust the size and center from the given new side position
	public function expandLeft( l:Float ) 	{ _extents.x = ((_center.x + _extents.x) - l) * 0.5; _center.x = l + _extents.x; }
	public function expandRight( r:Float ) 	{ _extents.x = (r - (_center.x - _extents.x)) * 0.5; _center.x = r - _extents.x; }
	public function expandTop( t:Float ) 	{ _extents.y = ((_center.y + _extents.y) - t) * 0.5; _center.y = t + _extents.x; }
	public function expandBottom( b:Float ) { _extents.y = (b - (_center.y - _extents.y)) * 0.5; _center.y = b - _extents.y; }
	
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
	
	public function draw( graphics:Graphics ) :Void 
	{
		graphics.drawRect(x, y, width, height);
	}
	
	
	/*
	 * Getters & Setters
	 */		
	private inline function get_cx() :Float 				{ return _center.x; }
	private inline function get_cy() :Float 				{ return _center.y; }
	private inline function get_c() :Vec2 					{ return _center; }
	private inline function get_width() :Float 				{ return _extents.x * 2; }
	private inline function get_height() :Float 			{ return _extents.y * 2; }
	private inline function get_hw() :Float 				{ return _extents.x; }
	private inline function get_hh() :Float 				{ return _extents.y; }
	private inline function get_minX() :Float 				{ return _center.x - _extents.x; }
	private inline function get_maxX() :Float 				{ return _center.x + _extents.x; }
	private inline function get_minY() :Float 				{ return _center.y - _extents.y; }
	private inline function get_maxY() :Float 				{ return _center.y + _extents.y; }
	
	private inline function set_cx( x:Float ) :Float  		{ return _center.x = x; }	
	private inline function set_cy( y:Float ) :Float 		{ return _center.y = y; }
	private inline function set_c( pos:Vec2 ) :Vec2 		{ _center.x = pos.x; _center.y = pos.y; return _center; }
	private inline function set_width( w:Float ) :Float 	{ return _extents.x = w * 0.5; }
	private inline function set_height( h:Float ) :Float 	{ return _extents.y = h * 0.5; }
	
	// adjusts the position based on the new min/max
	private inline function set_left( x:Float ) :Float 		{ return _center.x = x + _extents.x; }
	private inline function set_right( x:Float ) :Float 	{ return _center.x = x - _extents.x; }
	private inline function set_top( y:Float ) :Float 		{ return _center.y = y + _extents.y; }
	private inline function set_bottom( y:Float ) :Float 	{ return _center.y = y - _extents.y; }

	
	
	// AABB Collisions
	public static inline function aabbContainsPoint( 
		aabb:AABB, 
		x:Float, y:Float ) :Bool
	{
		return ((x <= aabb.right && x >= aabb.left) && 
				(y <= aabb.bottom && y >= aabb.top) );
	}

	public static inline function aabbIntersectsRect( 
		aabb:AABB, 
		x:Float, y:Float, width:Float, height:Float ) :Bool
	{
		var dx = Math.abs(aabb._center.x - x + width * 0.5);
		var dy = Math.abs(aabb._center.y - y + height * 0.5);
		var xx = ( (aabb.width + width) * 0.5);
		var yy = ( (aabb.height + height) * 0.5);
		return ( xx >= dx && yy >= dy );
	}
}