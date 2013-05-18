package sge.physics;

/**
 * A Linked list of Collision Details
 * @author fidgetwidget
 */

class CollisionData
{	
	
	/*
	 * Properties
	 */
	public var intersects:Bool = false;		// objects do intersect	
	public var px:Float = 0.0;				// penetration
	public var py:Float = 0.0;	
	public var dv:Vec2;						// difference vector	
	public var oH:Int = 0;					// horizontal/vertical offset [ -1 == left/top, 1 == right/bottom ]
	public var oV:Int = 0;	
	
	/*
	 * Members
	 */
	private var next:CollisionData = null;	// if there are multiple collisions
	private var prev:CollisionData = null;
	
	
	public function new (intersects, px, py, dv, oH, oV, next) {
		this.intersects = intersects;
		this.px = px;
		this.py = py;
		this.dv = dv;
		this.oH = oV;
		this.next = next;
		prev = null;
		
		// if we have a next, make this it's prev
		if (this.next != null) { next.prev = this; }
	}
	
	/// Returns the collisions parent (or return null if there isn't one)
	public function getPrev() :CollisionData 	{ return prev; }	
	public function hasNext() :Bool 			{ return next != null; }	
	public function getNext() :CollisionData 	{ return next; }
	
	/// Add another collision set, return it.
	public function setNext( cdata:CollisionData = null ) :CollisionData {
		if (cdata == null) {
			cdata = CollisionMath.getCollisionData();
		}
		this.next = cdata;
		cdata.prev = this;
		return cdata;
	}	 
	
	/// Recycle the data (and all of its children/parents)
	public function free() :Void {
		// Make sure we start at the beginning
		if (prev != null) { return prev.free(); }
		
		intersects = false;
		px = 0;
		py = 0;
		dv.x = dv.y = 0;
		oH = 0;
		oV = 0;	
		
		if (next != null) {
			next.prev = null; // make sure the next doesn't return to us
			// free all children
			next.free();
			next = null;
		}	
		return;
	}
	
	
	/// Return the first collision in the set (or return this if this is the first)
	public static function getFirst( cdata:CollisionData ) :CollisionData
	{
		if (cdata.prev != null)
		{
			return cdata = getFirst( cdata.prev );
		}
		return cdata;
	}
	
	public static function getSmallest( cdata:CollisionData, result:Vec2 = null ) :Vec2
	{
		if (result == null) { result = new Vec2(); }
		result.x = 0;
		result.y = 0;
		_cdata = cdata;
		while (_cdata != null) {
			if ( (_cdata.px < Math.abs(result.x) || result.x == 0) && _cdata.px != 0) { result.x = _cdata.px * _cdata.oH; }
			if ( (_cdata.py < Math.abs(result.y) || result.y == 0) && _cdata.py != 0) { result.y = _cdata.py * _cdata.oV; }
			_cdata = _cdata.next;
		}
		return result;
	}
	private static var _cdata:CollisionData;
	
}