package sge.collision;

import sge.core.Entity;
import sge.geom.Box;

/**
 * ...
 * @author fidgetwidget
 */
class BoxCollider extends Collider
{
	
	/*
	 * Properties
	 */	
	public var x(get, never)		:Float;
	public var y(get, never)		:Float;
	public var rotation(get, set)	:Float;
	public var scaleX(get, set)		:Float;
	public var scaleY(get, set)		:Float;
	
	public var xOffset(get, set)	:Float;
	public var yOffset(get, set)	:Float;
	public var width(get, set)		:Float;
	public var height(get, set)		:Float;
	
	public var useCenterPosition(default, default):Bool = true;
	public var useBottomCenterPosition(default, default):Bool = false;
	
	/*
	 * Members
	 */
	private var _box				:Box; // xoffset, yoffset, width, height
	
	/**
	 * Constructor
	 * @param	box
	 * @param	e
	 */
	public function new( box:Box, e:Entity = null, centered:Bool = true ) 
	{
		super(e);
		_type = Type.getClassName( Type.getClass( this ) );	
				
		_box = box;
		_bounds = new AABB();
		useCenterPosition = centered;
			
		_check.set( Type.getClassName(BoxCollider), collideBox );
		_check.set( Type.getClassName(CircleCollider), collideCircle );
		_check.set( Type.getClassName(PolygonCollider), collidePoly );
	}
	
	
	public override function contains( x:Float, y:Float ) :Bool {
		
		return AABB.aabbContainsPoint( get_bounds(), x, y);
	}
	
	public override function collidePoint( x:Float, y:Float, cdata:CollisionData = null ) :Bool {
		
		return CollisionMath.boxPointCollision( get_bounds(), x, y, cdata );
	}
	
	public override function collideLine( x1:Float, y1:Float, x2:Float, y2:Float, cdata:CollisionData = null ) :Bool {
		
		return CollisionMath.boxLineCollision( get_bounds(), x1, y1, x2, y2, cdata );
	}
	
	public override function collideAABB( target:AABB, cdata:CollisionData = null ) :Bool {
		
		return CollisionMath.boxBoxCollision( get_bounds(), target, cdata );
	}
	
	public override function collideBox( b:BoxCollider, cdata:CollisionData = null ) :Bool {

		return CollisionMath.boxBoxCollision( get_bounds(), b.get_bounds(), cdata );
	}
	
	public override function collideCircle( c:CircleCollider, cdata:CollisionData = null ) :Bool {
		
		return CollisionMath.boxCircleCollision( get_bounds(), c, cdata );
	}
	
	
	// TODO: ----------------------	
	public override function collidePoly( p:PolygonCollider, cdata:CollisionData = null) :Bool { 
		return false;
	}
	// ----------------------------
	
	/*
	 * Getters & Setters
	 */	
	private function get_x():Float 					{ if (_e != null) { return _box.x + _e.x; } else { return _box.x; } }
	private function get_y():Float 					{ if (_e != null) { return _box.y + _e.y; } else { return _box.y; } }
	private function get_rotation() :Float 			{ return _box.rotation; }
	private function get_scaleX() :Float 			{ return _box.scaleX; }
	private function get_scaleY() :Float 			{ return _box.scaleY; }
	private function get_xOffset() :Float 			{ return _box.x; }
	private function get_yOffset() :Float 			{ return _box.y; }
	private function get_width() :Float				{ return _box.width; }	
	private function get_height() :Float			{ return _box.height; }	
	
	private function set_rotation( r:Float ) :Float { return _box.rotation = r; }
	private function set_scaleX( x:Float ) :Float 	{ return _box.scaleX = x; } 
	private function set_scaleY( y:Float ) :Float 	{ return _box.scaleY = y; } 
	private function set_xOffset( x:Float ) :Float 	{ return _box.x = x; }
	private function set_yOffset( y:Float ) :Float 	{ return _box.y = y; }
	private function set_width( w:Float ) :Float	{ return _box.width = w; }
	private function set_height( h:Float ) :Float	{ return _box.height = h; }
	
	
	/* -- hasBounds -- */
	public override function get_bounds() :AABB {
		if (useCenterPosition) {
			_bounds.cx = x;
			_bounds.cy = y;
		} else {
			_bounds.x = x;
			_bounds.y = y;
		}		
		_bounds.width = _box.width;
		_bounds.height = _box.height;
		return _bounds;
	}
	
}