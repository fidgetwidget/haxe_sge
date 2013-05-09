package sge.physics;
import sge.core.Entity;
import sge.geom.Box;

/**
 * AABB Collider Type
 * @author fidgetwidget
 */

class BoxCollider extends Collider
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
	public var width(get_width, set_width):Float;
	public var height(get_height, set_height):Float;
	
	/*
	 * Members
	 */
	private var _box:Box; // xoffset, yoffset, width, height
	
	/**
	 * Constructor
	 * @param	box
	 * @param	e
	 */
	public function new( box:Box, e:Entity = null ) 
	{
		super(e);
		_type = Type.getClassName( Type.getClass( this ) );	
				
		_box = box;
		_bounds = new AABB();
			
		_check.set( Type.getClassName(BoxCollider), collideBox );
		_check.set( Type.getClassName(CircleCollider), collideCircle );
		_check.set( Type.getClassName(PolygonCollider), collidePoly );
	}
	
	
	public override function contains( x:Float, y:Float ) :Bool {
		
		return AABB.aabbContainsPoint( getBounds(), x, y);
	}
	
	public override function collidePoint( x:Float, y:Float, cdata:CollisionData = null ) :Bool {
		
		return Physics.boxPointCollision( getBounds(), x, y, cdata );
	}
	
	public override function collideLine( x1:Float, y1:Float, x2:Float, y2:Float, cdata:CollisionData = null ) :Bool {
		
		return Physics.boxLineCollision( getBounds(), x1, y1, x2, y2, cdata );
	}
	
	public override function collideAABB( target:AABB, cdata:CollisionData = null ) :Bool {
		
		return Physics.boxBoxCollision( getBounds(), target, cdata );
	}
	
	public override function collideBox( b:BoxCollider, cdata:CollisionData = null ) :Bool {

		return Physics.boxBoxCollision( getBounds(), b.getBounds(), cdata );
	}
	
	public override function collideCircle( c:CircleCollider, cdata:CollisionData = null ) :Bool {
		
		return Physics.boxCircleCollision( getBounds(), c, cdata );
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
	public override function getBounds() :AABB {
		_bounds.cx = x;
		_bounds.cy = y;
		_bounds.width = _box.width;
		_bounds.height = _box.height;
		return _bounds;
	}
	
}