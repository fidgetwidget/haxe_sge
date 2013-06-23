package sge.collision;

import sge.core.Entity;
import sge.geom.Polygon;
import sge.geom.Vertices;
import sge.math.Vector2D;
import sge.math.Projection;

/**
 * ***INCOMPLETE*** * 
 * Polygon Collider
 * 
 * @author fidgetwidget
 */

class PolygonCollider extends Collider
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
	
	public var polygon(get_polygon, set_polygon):Polygon;
	public var vertices(get_vertices, never):Vertices; // the untransformed vertices
	public var transformed(get_transformed, never):Vertices; // the transformed vertices
	
	/*
	 * Members
	 */
	private var _polygon:Polygon;
	private var _origin:Vector2D;
	
	
	/**
	 * Constructor
	 * @param	polygon
	 * @param	e
	 */
	public function new( polygon:Polygon, e:Entity = null ) 
	{
		super(e);
		_type = Type.getClassName( Type.getClass( this ) );	
				
		_polygon = polygon;
		_origin = polygon.get_center();
		_bounds = new AABB();
			
		_check.set( Type.getClassName(BoxCollider), collideBox );
		_check.set( Type.getClassName(CircleCollider), collideCircle );
		_check.set( Type.getClassName(PolygonCollider), collidePoly );		
	}
	
	// get the polygons projection for the given axis
	public override function project( axis:Vector2D, result:Projection = null ) :Projection
	{
		if (result == null) { result = new Projection(); }
		//_point = vertices.get(0);
		//_min = axis.dotProduct( _point.x, _point.y );
		//_max = _min;
		//_i = 1;
		//while ( _i < vertices.length )
		//{
			//_point = vertices.get(_i);
			//_dp = axis.dotProduct(_point.x, _point.y);
			//if (_dp < _min) {
				//_min = _dp;
			//} else if (_dp > _max) {
				//_max = _dp;
			//}
			//_i++;
		//}		
		//result.min = _min;
		//result.max = _max;
		return result;
	}
	
	// TODO: ----------------------
	public override function contains( x:Float, y:Float ) :Bool {
		
		return false;
	}
	
	public override function collidePoint( x:Float, y:Float, cdata:CollisionData = null ) :Bool {
		
		return false;
	}
	
	public override function collideLine( x1:Float, y1:Float, x2:Float, y2:Float, cdata:CollisionData = null ) :Bool {
		
		return false;
	}
	
	public override function collideAABB( target:AABB, cdata:CollisionData = null ) :Bool {
		
		return false;
	}
	
	public override function collideBox( b:BoxCollider, cdata:CollisionData = null ) :Bool {
		
		return false;
	}
	
	public override function collideCircle( c:CircleCollider, cdata:CollisionData = null ) :Bool {
		
		return false;
	}
	
	
	public override function collidePoly( p:PolygonCollider, cdata:CollisionData = null) :Bool { 
		
		return false;
	}
	// ----------------------------
	
	/*
	 * Getters & Setters
	 */	
	private function get_x			() :Float { if (_e != null) { return _polygon.x + _e.x; } else { return _polygon.x; } }
	private function get_y			() :Float { if (_e != null) { return _polygon.y + _e.y; } else { return _polygon.y; } }
	private function get_rotation	() :Float { return _polygon.rotation; }
	private function get_scaleX		() :Float { return _polygon.scaleX; }
	private function get_scaleY		() :Float { return _polygon.scaleY; }
	private function get_xOffset	() :Float { return _polygon.x; }
	private function get_yOffset	() :Float { return _polygon.y; }
	private function get_polygon	() :Polygon  { return _polygon; }
	private function get_vertices	() :Vertices { return _polygon.vertices; }
	private function get_transformed() :Vertices { return _polygon.transformed; }
	
	private function set_rotation	( r:Float ) :Float { return _polygon.rotation = r; }
	private function set_scaleX		( x:Float )	:Float { return _polygon.scaleX = x; } 
	private function set_scaleY		( y:Float )	:Float { return _polygon.scaleY = y; } 
	private function set_xOffset	( x:Float )	:Float { return _polygon.x = x; }
	private function set_yOffset	( y:Float )	:Float { return _polygon.y = y; }
	private function set_polygon	( p:Polygon ) :Polygon { return _polygon = p; }
	
	
	/* -- hasBounds -- */
	public override function get_bounds() :AABB {
		_bounds = _polygon.get_bounds();
		_bounds.cx = x;
		_bounds.cy = y;
		return _bounds;
	}
	
}