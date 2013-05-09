package sge.physics;

import haxe.FastList;
import nme.geom.Point;
import sge.core.Entity;
import sge.geom.Shape;
import sge.lib.Properties;
import sge.interfaces.IHasBounds;

// define the callback function for collisions
typedef ColliderCallback = Dynamic -> CollisionData -> Bool;

/**
 * ...
 * @author fidgetwidget
 */

class Collider implements IHasBounds
{
	/**
	 * Properties
	 */	
	public var properties:Properties;
	public var axes(get_axes, never):Array<Vec2>;
	
	/**
	 * Members
	 */
	private var _type :String;
	private var _check :Hash<ColliderCallback>;
	private var _e:Entity;
	private var _parent:Collider;
	private var _children:FastList<Collider>;
	private var _axes:Array<Vec2>;
	private var _bounds:AABB;
	
	/**
	 * Constructor
	 * @param	e
	 */
	public function new( e:Entity = null ) 
	{		
		_e = e;
		_type = Type.getClassName( Type.getClass( this ) );
		_check = new Hash<ColliderCallback>();
	}
	
	
	public function project( axis:Vec2, result:Projection = null ) :Projection
	{
		if (result == null) { result = new Projection(); }
		return result;
	}
	
	public function collide( target:Collider, cdata:CollisionData = null ) :Bool {
		
		var func:ColliderCallback;
		func = _check.get( target._type );
		if ( func != null ) {
			return func( target, cdata );
		}
		
		func = target._check.get( this._type );
		if ( func != null ) {
			return func( this, cdata );
		}
		
		return false; // we don't have a valid collider type collisions
	}	
	
	// returns whether or not the children contain the point
	public function contains( x:Float, y:Float ) :Bool {
		if (_children != null) {
			for ( child in _children )
			{
				if (child.contains(x, y)) return true;
			}
		}
		return false;
	}	
	
	/* ------------------ *
	 * The collisions checks that all colliders should support:
	 * 
	 *  - used by the other collider types -
	 *  collidePoint( x:Float, y:Float, cData:CollisionData = null ) :Bool
	 *   collideLine( x1:Float, y1:Float, x2:Float, y2:Float, cData:CollisionData = null ) :Bool
	 *   collideAabb( aabb:AABB, cData:CollisionData = null ) :Bool
	 *  - collider types -
	 *    collideBox( b:BoxCollider, cData:CollisionData = null ) :Bool
	 * collideCircle( c:CircleCollider, cData:CollisionData = null ) :Bool
	 *   collidePoly( p:PolygonCollider, cData:CollisionData = null ) :Bool
	 *    collideMap( g:GridCollider, cData:CollisionData = null ) :Bool
	 * 
	 * ------------------ */
	
	// psudo abstract classes
	public function collidePoint( x:Float, y:Float, cdata:CollisionData = null ) :Bool { return false; }
	public function collideLine( x1:Float, y1:Float, x2:Float, y2:Float, cdata:CollisionData = null ) :Bool { return false; }
	public function collideAABB( target:AABB, cdata:CollisionData = null ) :Bool { return false; }
	public function collideBox( b:BoxCollider, cdata:CollisionData = null ) :Bool { return false; }
	public function collideCircle( c:CircleCollider, cdata:CollisionData = null ) :Bool { return false; }
	public function collidePoly( p:PolygonCollider, cdata:CollisionData = null ) :Bool { return false; }
	 
	/**
	 * Getters & Setters
	 */
	private function get_axes() :Array<Vec2>
	{
		if (_axes == null) { _axes = new Array<Vec2>(); }
		return _axes;
	}
	
	/* -- hasBounds -- */
	
	public function getBounds() :AABB {
		_bounds = null;
		if (_children != null) {
			for ( child in _children )
			{
				if (_bounds == null) { _bounds = child.getBounds(); continue; }
				_bounds.combine( child.getBounds() );
			}
		}
		return _bounds;
	}
	
}