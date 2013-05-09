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
	
	/// Return the first collision in the set (or return this if this is the first)
	public function getFirst() :CollisionData
	{
		if (prev != null)
		{
			return prev.getFirst();
		}
		return this;
	}
	
	/// Returns the collisions parent (or return null if there isn't one)
	public function getPrev() :CollisionData
	{
		return prev;
	}
	
	/// Add another collision set, return it.
	public function setNext( cdata:CollisionData ) :CollisionData {
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
	
}