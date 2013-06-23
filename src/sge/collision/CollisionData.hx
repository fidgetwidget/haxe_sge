package sge.collision;

import sge.lib.IRecyclable;
import sge.math.Vector2D;

/**
 * 
 * A Linked list of Collision Details
 * @author fidgetwidget
 */

class CollisionData implements IRecyclable
{	
	
	/*
	 * Properties
	 */
	public var intersects	: Bool 	= false;	// objects do intersect	
	public var px			: Float	= 0.0;		// penetration
	public var py			: Float = 0.0;	
	public var dv			: Vector2D;			// difference vector ( distance between center points )	
	public var oH			: Int 	= 0;		// horizontal/vertical directions [ -1 == left/top, 1 == right/bottom ]
	public var oV			: Int 	= 0;	
	
	/*
	 * Members
	 */
	private var _next		: CollisionData = null;	// if there are multiple collisions
	private var _prev		: CollisionData = null;
	
	
	public function new ( intersects:Bool = false, px:Float = 0, py:Float = 0, dv:Vector2D = null, oH:Int = 0, oV:Int = 0, next:CollisionData = null) {
		this.intersects = intersects;
		this.px = px;
		this.py = py;
		if (dv == null) { dv = new Vector2D(); }
		this.dv = dv;
		this.oH = oV;
		
		_next = next;
		_prev = null;
		
		// if we have a next, make this it's prev
		if (this._next != null) { next._prev = this; }
	}
	
	/// Returns the collisions parent (or return null if there isn't one)
	public function getPrev() :CollisionData 	{ return _prev; }	
	public function hasNext() :Bool 			{ return _next != null; }
	public function getNext() :CollisionData 	{ return _next; }
	
	/// Add another collision set, return it.
	public function setNext( cdata:CollisionData = null ) :CollisionData {
		if (cdata == null) {
			cdata = CollisionMath.getCollisionData();
		}
		this._next = cdata;
		cdata._prev = this;
		return cdata;
	}		
	
	/*
	 * IRecycleable 
	 */
	public function free() :Void 
	{		
		// Make sure we start at the beginning
		if (_prev != null) { return _prev.free(); }
		
		intersects = false;
		px = 0;
		py = 0;
		dv.x = dv.y = 0;
		oH = 0;
		oV = 0;	
		
		if (_next != null) {
			_next._prev = null; // make sure the next doesn't return to us
			// free all children
			_next.free();
			_next = null;
		}	
		return;
	}
	public function get_free() :Bool { return _free; }
	public function set_free( free:Bool ) :Bool { return _free = free; }
	private var _free:Bool = false;
	
	
	/// Return the first collision in the set (or return this if this is the first)
	public static function getFirst( cdata:CollisionData ) :CollisionData
	{
		if (cdata._prev != null)
		{
			return cdata = getFirst( cdata._prev );
		}
		return cdata;
	}
	
	public static function getSmallest( cdata:CollisionData, result:Vector2D = null ) :Vector2D
	{
		if (result == null) { result = new Vector2D(); }
		result.x = 0;
		result.y = 0;
		_cdata = cdata;
		while (_cdata != null) {
			if ( (_cdata.px < Math.abs(result.x) || result.x == 0) && _cdata.px != 0) { result.x = _cdata.px * _cdata.oH; }
			if ( (_cdata.py < Math.abs(result.y) || result.y == 0) && _cdata.py != 0) { result.y = _cdata.py * _cdata.oV; }
			_cdata = _cdata._next;
		}
		return result;
	}
	private static var _cdata:CollisionData;
	
}