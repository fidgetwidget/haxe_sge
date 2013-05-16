package sge.physics;

import sge.core.Entity;
import sge.geom.Circle;

/**
 * ...
 * @author fidgetwidget
 */

class CircleCollider extends Collider
{
	
	/*
	 * Properties
	 */	
	public var x(get_x, never):Float;
	public var y(get_y, never):Float;
	public var rotation(get_rotation, set_rotation):Float;
	public var scaleX(get_scaleX, set_scaleX):Float;
	public var scaleY(get_scaleY, set_scaleY):Float;
	
	public var xOffset(get_xOffset, set_xOffset):Float;
	public var yOffset(get_yOffset, set_yOffset):Float;
	public var radius(get_radius, set_radius):Float;
	public var transformedRadius(get_transformedRadius, never):Float;
	
	public var circle(get_circle, set_circle):Circle;

	/**
	 * Members
	 */	
	private var _circle:Circle;
	
	/**
	 * Constructor
	 */
	public function new( circle:Circle, e:Entity ) 
	{
		super(e);
		_type = Type.getClassName( Type.getClass( this ) );	
		
		_circle = circle;	
		_bounds = new AABB();
		
		_check.set( Type.getClassName(BoxCollider), collideBox );
		_check.set( Type.getClassName(CircleCollider), collideCircle );
		_check.set( Type.getClassName(PolygonCollider), collidePoly );
	}	
	
	
	
	/**
	 * Collision Methods
	 */
	
	public override function collidePoint( x:Float, y:Float, cdata:CollisionData = null ) :Bool {
		
		return CollisionMath.circlePointCollision( this, x, y, cdata );
	}
	
	public override function collideLine( x1:Float, y1:Float, x2:Float, y2:Float, cdata:CollisionData = null ) :Bool {
		
		return CollisionMath.circleLineCollision( this, x1, y1, x2, y2, cdata );
	}
	
	public override function collideAABB( target:AABB, cdata:CollisionData = null ) :Bool {
		
		return CollisionMath.circleBoxCollision( this, target, cdata );
	}
	
	public override function collideBox( b:BoxCollider, cdata:CollisionData = null ) :Bool {
		return CollisionMath.circleBoxCollision( this, b.getBounds(), cdata );
	}
	
	public override function collideCircle( c:CircleCollider, cdata:CollisionData = null ) :Bool {
		
		return CollisionMath.circleCircleCollision( this, c, cdata );
	}
	
	// TODO: ----------------------
	public override function collidePoly( p:PolygonCollider, cdata:CollisionData = null) :Bool { 
		return false;
	}
	// ----------------------------
	
	/**
	 * Helpers
	 */
	
	public override function contains( x:Float, y:Float ) :Bool {
		
		if (_e != null) {
			return CollisionMath.distanceBetween_xy( _e.x + _circle.x, _e.y + _circle.y, x, y ) <= _circle.radius;
		} else {
			return CollisionMath.distanceBetween_xy( _circle.x, _circle.y, x, y ) <= _circle.radius;
		}		
	}
	
	
	/*
	 * Getters & Setters
	 */	
	private function get_x():Float 					{ if (_e != null) { return _circle.x + _e.x; } else { return _circle.x; } }
	private function get_y():Float 					{ if (_e != null) { return _circle.y + _e.y; } else { return _circle.y; } }
	private function get_rotation() :Float 			{ return 0; }
	private function get_scaleX() :Float 			{ return _circle.scaleX; }
	private function get_scaleY() :Float 			{ return _circle.scaleY; }
	private function get_xOffset() :Float 			{ return _circle.x; }
	private function get_yOffset() :Float 			{ return _circle.y; }
	private function get_radius() :Float			{ return _circle.radius; }	
	private function get_transformedRadius() :Float { return _circle.transformedRadius; }
	private function get_circle() :Circle			{ return _circle; }	
	
	private function set_rotation( r:Float ) :Float { return 0; }
	private function set_scaleX( x:Float ) :Float 	{ return _circle.scaleX = x; } 
	private function set_scaleY( y:Float ) :Float 	{ return _circle.scaleY = y; } 
	private function set_xOffset( x:Float ) :Float 	{ return _circle.x = x; }
	private function set_yOffset( y:Float ) :Float 	{ return _circle.y = y; }
	private function set_radius( r:Float ) :Float	{ return _circle.radius = r; }
	private function set_circle( c:Circle ) :Circle	{ return _circle = c; }
	
	
	/* -- hasBounds -- */
	public override function getBounds() :AABB 
	{		
		_bounds.cx = x;
		_bounds.cy = y;
		_bounds.width = radius * 2;
		_bounds.height = radius * 2;
		return _bounds;
	}
	
}