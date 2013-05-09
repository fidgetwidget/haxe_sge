package sge.physics;

import haxe.FastList;
import nme.geom.Point;
import sge.core.Entity;
import sge.geom.Vec2;

/**
 * ...
 * @author fidgetwidget
 */

class GroupCollider extends Collider
{
	/*
	 * Properties
	 */
	public var children(get_children, set_children) :FastList<Collider>;

	
	/**
	 * Constructor
	 * @param	children
	 * @param	e
	 */
	public function new( children:FastList<Collider> = null, e:Entity = null ) 
	{
		super( e );
		_type = Type.getClassName( Type.getClass( this ) );
		
		if (children == null) { 
			_children = new FastList<Collider>(); 
		} 
		else { 
			_children = children; 
		}
		
		_check.set( Type.getClassName(BoxCollider), collideBox );
		_check.set( Type.getClassName(CircleCollider), collideCircle );
		_check.set( Type.getClassName(PolygonCollider), collidePoly );
		_check.set( Type.getClassName(GridCollider), collideMap );
	}
	
	
	public override function collidePoint( x:Float, y:Float, cdata:CollisionData = null ) :Bool {
		
		var result:Bool = false;
		
		for ( child in _children ) {
			if ( child.collidePoint( x, y, cdata ) ) { result = true; }
		}
		
		return result;
		
	}
	
	public override function collideLine( x1:Float, y1:Float, x2:Float, y2:Float, cdata:CollisionData = null ) :Bool {
		
		var result:Bool = false;
		
		for ( child in _children ) {
			if ( child.collideLine(x1, y1, x2, y2, cdata) ) { result = true; }
		}
		
		return result;
	}
	
	public override function collideAABB( target:AABB, cdata:CollisionData = null ) :Bool {
		
		var result:Bool = false;
		
		for ( child in _children ) {
			if ( child.collideAABB( target, cdata ) ) { result = true; }
		}
		
		return result;
	}
	
	public override function collideBox( b:BoxCollider, cdata:CollisionData = null ) :Bool {
		
		var result:Bool = false;
		
		for ( child in _children ) {
			if ( child.collideBox( b, cdata ) ) { result = true; }
		}
		
		return result;
	}
	
	public override function collideCircle( c:CircleCollider, cdata:CollisionData = null ) :Bool {
		
		var result:Bool = false;
		
		for ( child in _children ) {
			if ( child.collideCircle( c, cdata ) ) { result = true; }
		}
		
		return result;
	}
	
	
	public override function collideMap( m:GridCollider, cdata:CollisionData = null) :Bool { 
		
		var result:Bool = false;
		
		for ( child in _children ) {
			if ( child.collideMap( m, cdata ) ) { result = true; }
		}
		
		return result;
	}
	
	// TODO: ----------------------
	public override function collidePoly( p:PolygonCollider, cdata:CollisionData = null) :Bool { 
		
		var result:Bool = false;
		
		for ( child in _children ) {
			if ( child.collidePoly( p, cdata ) ) { result = true; }
		}
		
		return result;
	}
	// ----------------------------
	
	/*
	 * Getters & Setters
	 */
	
	private function get_children() :FastList<Collider>	{ return _children; }
	private function set_children( children:FastList<Collider> ) :FastList<Collider> { return _children = children; }
	
	
}