package sge.collision;

import sge.math.Vector2D;
import sge.geom.Vertices;

// for use in get closest
typedef Edge = {
	sx:Float,
	sy:Float,
	ex:Float,
	ey:Float
} 

/**
 * ...
 * @author fidgetwidget
 */
class CollisionMath 
{
	
	/**
	 * Math Helpers
	 */
	
	/**
	 * @return the value clamped between the min and max 
	 */
	public static function clamp( value:Float, min:Float, max:Float ) :Float 
	{
		return ( value < min ? min : (value > max ? max : value) );
	}
	
	public static inline function distanceBetween( x1:Float, y1:Float, x2:Float, y2:Float ) :Float
	{
		return Math.sqrt( ((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)) );
	}	
	
	public static inline function rectContainsRect( 
	 x1:Float, y1:Float, width1:Float, height1:Float,
	 x2:Float, y2:Float, width2:Float, height2:Float ) :Bool
	{
		var dx:Float;
		var dy:Float;
		var xx:Float;
		var yy:Float;
		dx = Math.abs(x1 + width1 * 0.5 - x2 + width2 * 0.5);
		dy = Math.abs(y1 + height1 * 0.5 - y2 + height2 * 0.5);
		xx = (width1 * 0.5 + width2 * 0.5);
		yy = (height1 * 0.5 + height2 * 0.5);
		return ( xx >= dx && yy >= dy );
	}
	
	/**
	 * Get Closest Helpers
	 */
	
	public static function getClosest( edge:Edge, 
	 pointX:Float, pointY:Float, closest:Vector2D = null ) :Vector2D
	{
		if (closest == null) { closest = new Vector2D(); }
		
		// segment vector (uses length)
		var segmentVector:Vector2D = new Vector2D();
		segmentVector.x = edge.ex - edge.sx;
		segmentVector.y = edge.ey - edge.sy;
		
		if (segmentVector.length <= 0) { throw "Invalid Segment Length"; }
		var distance:Float = segmentVector.length;
		
		// point vector (uses dotProduct)
		var pointVector:Vector2D = new Vector2D();
		pointVector.x = pointX - edge.sx;
		pointVector.y = pointY - edge.sy;
		
		// segment unit vector		
		var unitVector_x:Float = segmentVector.x / distance;
		var unitVector_y:Float = segmentVector.y / distance;
		
		// projection value/distance
		var dotProduct:Float = pointVector.dotProduct(unitVector_x, unitVector_y);
		
		// check for less then start and more then end exceptions
		if (dotProduct <= 0) {
			closest.x = edge.sx;
			closest.y = edge.sy;
			return closest;
		}
		if (dotProduct >= distance) {
			closest.x = edge.ex;
			closest.y = edge.ey;
			return closest;
		}
		
		// projection vector
		var projection_x:Float = unitVector_x * dotProduct;
		var projection_y:Float = unitVector_y * dotProduct;
		
		// closest point
		closest.x = projection_x + edge.sx;
		closest.y = projection_y + edge.sy;
		return closest;
	}
	
	public static inline function linesIntersect_fast( startA:Vector2D, endA:Vector2D, startB:Vector2D, endB:Vector2D ) :Bool 
	{		
		var s1_x:Float = endA.x - startA.x;
		var s1_y:Float = endA.y - startA.y;
		var s2_x:Float = endB.x - startB.x;
		var s2_y:Float = endB.y - startB.y;
		
		var s:Float = (-s1_y * (startA.x - startB.x) + s1_x * (startA.y - startB.y)) / (-s2_x * s1_y + s1_x * s2_y);
        var t:Float = ( s2_x * (startA.y - startB.y) - s2_y * (startA.x - startB.x)) / (-s2_x * s1_y + s1_x * s2_y);

        return (s >= 0 && s <= 1 && t >= 0 && t <= 1);
	}
	
	public static inline function linesIntersect( startA:Vector2D, endA:Vector2D, startB:Vector2D, endB:Vector2D, hitPoint:Vector2D = null ) :Vector2D
	{
		if (hitPoint == null) { hitPoint = new Vector2D(); }
		
		var s1_x:Float = endA.x - startA.x;
		var s1_y:Float = endA.y - startA.y;
		var s2_x:Float = endB.x - startB.x;
		var s2_y:Float = endB.y - startB.y;
		
		var s:Float = (-s1_y * (startA.x - startB.x) + s1_x * (startA.y - startB.y)) / (-s2_x * s1_y + s1_x * s2_y);
        var t:Float = ( s2_x * (startA.y - startB.y) - s2_y * (startA.x - startB.x)) / (-s2_x * s1_y + s1_x * s2_y);

        if (s >= 0 && s <= 1 && t >= 0 && t <= 1) 
		{
			hitPoint.x = startA.x + (t * s1_x);
			hitPoint.y = startA.y + (t * s1_y);			
		}
		else
		{			
			hitPoint.x = hitPoint.y = 0;
		}
			
		return hitPoint;
	}
	
	
	/** -------------------------------------------------------------------------
	 * Collision Functions
	 ------------------------------------------------------------------------- */
	
	/// -------------------------------------------------------------------------
	//  Circle Collisions
	/// -------------------------------------------------------------------------
	
	// Circle Circle Collision (early exit method)
	public static function circleCircleCollision( 
	 c1:CircleCollider, c2:CircleCollider, 
	 cdata:CollisionData = null ) :Bool 
	{		
		var distance = distanceBetween(c1.x, c1.y, c2.x, c2.y);
		var radii = (c1.radius + c2.radius);
		if (distance > radii) { return false; }
		
		if (cdata != null) {
			
			cdata.intersects = true;
			var dx = c1.x - c2.x;
			var dy = c1.y - c2.y;
			var nx = dx / distance;
			var ny = dy / distance;
			
			cdata.dv.x = dx;
			cdata.dv.y = dy;
			cdata.oH = dx < 0 ? -1 : 1;
			cdata.oV = dy < 0 ? -1 : 1;
			// get the penetration
			var penetration:Float = radii - distance;
			cdata.px = Math.abs(nx * penetration);
			cdata.py = Math.abs(ny * penetration);
		
		}
		return true;			
		
	}
	
	// Circle AABB Collision
	public static function circleBoxCollision( 
	 c:CircleCollider, b:AABB, 
	 cdata:CollisionData = null ) :Bool 
	{
		
		var dx:Float = b.cx - c.x;
		var px:Float = (b.hWidth + c.radius) - Math.abs(dx);
		if (px > 0) {
			
			var dy:Float = b.cy - c.y;
			var py:Float = (b.hHeight + c.radius) - Math.abs(dy);
			if (py > 0) {
				
				dx = c.x - clamp(c.x, b.left, b.right);
				dy = c.y - clamp(c.y, b.top, b.bottom);
				
				if (dx * dx + dy * dy > c.radius * c.radius) { return false; }
				
				if ( cdata != null ) { 	
					
					cdata.intersects = true;
					cdata.dv.x = dx;
					cdata.dv.y = dy;
					
					cdata.px = px;
					cdata.py = py;
					cdata.oH = dx < 0 ? -1 : 1;
					cdata.oV = dy < 0 ? -1 : 1;
					if (px > py) {
						cdata.oH = 0;
					} else {
						cdata.oV = 0;
					}
					
				}
				return true;
			}
		}
		
		return false;
	}
	
	// Circle Poly Collision
	public static function circlePolyCollision(
	 c:CircleCollider, p:PolygonCollider,
	 cdata:CollisionData = null) :Bool
	{
		// TODO: finish this.
		
		return false;
	}
	
	// Circle Line Collision (using projection)
	public static function circleLineCollision( 
	 c:CircleCollider, 
	 startX:Float, startY:Float, 
	 endX:Float, endY:Float,
	 cdata:CollisionData = null ) :Bool	
	{
		
		// get the closest point along the line to the circle center
		var point:Vector2D = getClosest( { sx:startX, sy:startY, ex:endX, ey:endY }, c.x, c.y); 
		// distance vector
		var dx = c.x - point.x;
		var dy = c.y - point.y;
		// distance
		var distance:Float = Math.sqrt((dx * dx) + (dy * dy));
		
		if (distance >= c.radius) { 			
			
			if ( cdata != null ) {
				cdata.intersects = true;
				var px:Float = dx / distance * (c.radius - distance);
				var py:Float = dy / distance * (c.radius - distance);
				cdata.dv.x = dx;
				cdata.dv.y = dy;
				cdata.px = px;
				cdata.py = py;
				cdata.oH = dx < 0 ? -1 : 1;
				cdata.oV = dy < 0 ? -1 : 1;
				if (px > py) {
					cdata.oH = 0;
				} else {
					cdata.oV = 0;
				}
				
			}
			
			return true;
		}
			
		return false;
	}
	
	// Circle Point Collision (early exit version)
	public static function circlePointCollision( 
	 c:CircleCollider, pointX:Float, pointY:Float, 
	 cdata:CollisionData = null ) :Bool 
	{
		
		var dx:Float = pointX - c.x;
		var px:Float = c.radius - Math.abs(dx);
		if (_px > 0)
		{
			var dy:Float = pointY - c.y;
			var py:Float = c.radius - Math.abs(dy);
			if (py > 0) {
				
				if ( cdata != null ) { 
					
					cdata.intersects = true;
					cdata.dv.x = dx;
					cdata.dv.y = dy;
					cdata.px = px;
					cdata.py = py;					
					cdata.oH = dx < 0 ? -1 : 1;
					cdata.oV = dy < 0 ? -1 : 1;
					if (px > py) {
						cdata.oH = 0;
					} else {
						cdata.oV = 0;
					}
				}
				return true;
			}
		}
		return false;
	}
	
	/// -------------------------------------------------------------------------
	//  AABB/Box Collider Collisions
	/// -------------------------------------------------------------------------	
	
	// AABB AABB Collision
	public static function boxBoxCollision( 
	 b1:AABB, b2:AABB, 
	 cdata:CollisionData = null ) :Bool 
	{
		
		var dx = b1.center.x - b2.center.x;
		var px = (b1.hWidth + b2.hWidth) - Math.abs(dx);
		if (px > 0) {
			
			var dy = b1.center.y - b2.center.y;
			var py = (b1.hHeight + b2.hHeight) - Math.abs(dy);
			if (py > 0) {
				
				if ( cdata != null ) {					
					cdata.intersects = true;					
					cdata.dv.x = dx;
					cdata.dv.y = dy;					
					cdata.px = px;
					cdata.py = py;
					cdata.oH = dx < 0 ? -1 : 1;
					cdata.oV = dy < 0 ? -1 : 1;
					if (px > py) {
						cdata.oH = 0;
					} else {
						cdata.oV = 0;
					}
				}
				return true;
			}
		}
		return false;
	}
	
	// AABB Circle Collision
	public static function boxCircleCollision(
	 b:AABB, c:CircleCollider,
	 cdata:CollisionData = null ) :Bool 
	{
			
		var dx:Float = b.cx - c.x;
		var px:Float = (b.hWidth + c.radius) - Math.abs(dx);
		if (px > 0) {
			
			var dy:Float = b.cy - c.y;
			var py:Float = (b.hHeight + c.radius) - Math.abs(dy);
			if (py > 0) {
				
				dx = c.x - clamp(c.x, b.left, b.right);
				dy = c.y - clamp(c.y, b.top, b.bottom);
				
				if (dx * dx + dy * dy > c.radius * c.radius) { return false; }
				
				if ( cdata != null ) { 	
					
					cdata.intersects = true;
					cdata.dv.x = -dx; // reverse of circleBox collision
					cdata.dv.y = -dy;					
					cdata.px = px;
					cdata.py = py;
					cdata.oH = dx < 0 ? 1 : -1; // reverse of circleBox collision
					cdata.oV = dy < 0 ? 1 : -1;
					if (px > py) {
						cdata.oH = 0;
					} else {
						cdata.oV = 0;
					}
					
				}
				return true;
			}
		}
		
		return false;
	}
	
	public static function boxPolyCollision(
	 b:AABB, p:PolygonCollider,
	 cdata:CollisionData = null) :Bool
	{
		// TODO: finish this.
		
		return false;
	}
	
	// AABB Line Collision
	public static function boxLineCollision( 
	 box:AABB, 
	 startX:Float, startY:Float, 
	 endX:Float, endY:Float, 
	 cdata:CollisionData = null ) :Bool 
	{		
		// TODO: finish this.
		
		return false;
	}
	
	// AABB.collidePoint function (w/ optional collision data)
	public static function boxPointCollision( 
	 box:AABB, pointX:Float, pointY:Float, 
	 cdata:CollisionData = null ) :Bool 
	{		
		// if we don't need to do the cdata check, we can just use the AABB containsXY function
		if ( cdata == null ) {
			return box.containsPoint(pointX, pointY);
		}
		
		var dx = box.cx - pointX;
		var px = box.hWidth - Math.abs(dx);
		if (px >= 0) {
			var dy = box.cy - pointY;
			var py = box.hHeight - Math.abs(dy);
			if (py >= 0) {
				
				 // we don't have to check if cdata is null, we already did that
				cdata.intersects = true;
				cdata.oH = 0;
				cdata.oV = 0;
				cdata.dv.x = dx;
				cdata.dv.y = dy;
				cdata.px = px;
				cdata.py = py;
				// project in the lesser depth
				cdata.oH = dx < 0 ? -1 : 1;
				cdata.oV = dy < 0 ? -1 : 1;
				
				return true;
			}
		}
		
		return false;
	}
	
	/// -------------------------------------------------------------------------
	//  Polygon Collider Collisions
	/// -------------------------------------------------------------------------
	
	// Poly Poly Collision
	
	
	// Poly Circle Collision (WIP)
	public static function polyCircleCollision(
	 p:PolygonCollider, c:CircleCollider, 
	 cdata:CollisionData = null) :Bool 
	{
		// fast outside of bounds check
		var bounds:AABB = p.get_bounds();
		if ( !c.collideAABB(bounds) ) { return false; }
		
		var vert:Vector2D;
		var dotProduct:Float;
		var closestVector:Vector2D = new Vector2D();
		var normalAxis:Vector2D = new Vector2D();		
		var closest:Float = 0;
		var verts:Vertices = p.vertices;		
		var dx:Float = p.x - c.x;
		var dy:Float = p.y - c.y;
		var min:Float = 0;
		var max:Float = 0x3FFFFFFF;
		var min2:Float = 0;
		var max2:Float = 0x3FFFFFFF;
		
		for (i in 0...verts.length) 
		{
			vert = verts.get(i);
			var distance:Float = (c.x - (p.x + vert.x)) * (c.x - (p.x + vert.x)) + (c.y - (p.y + vert.y)) * (c.y - (p.y + vert.y));
			if (distance < closest) { // closest has the lowest distance
				closest = distance;
				closestVector.x = p.x + vert.x;
				closestVector.y = p.y + vert.y;
			}
		}
		
		normalAxis.x = closestVector.x - c.x;
		normalAxis.y = closestVector.y - c.y;
		normalAxis.normalize();
		
		// project the polygon's points
		vert = verts.get(0);
		min = normalAxis.dotProduct(vert.x, vert.y);
		max = min; //set max and min
		
		for (j in 1...verts.length) 
		{
			vert = verts.get(j);
			dotProduct = normalAxis.dotProduct(vert.x, vert.y);
			if (dotProduct < min) {
				min = dotProduct;
			} //smallest min is wanted
			if (dotProduct > max) {
				max = dotProduct;
			} //largest max is wanted
		}		
		
		// project the circle
		min2 = c.transformedRadius; //max is radius
		max2 -= c.transformedRadius; //min is negative radius
		
		// offset the polygon's max/min
		var offset:Float = normalAxis.dotProduct(dx, dy);
		min += offset;
		max += offset;
		
		// do the big test
		var t1:Float = min - max2;
		var t2:Float = min2 - max;
		
		if(t1 > 0 || t2 > 0) { //if either test is greater than 0, there is a gap, we can give up now.
			return false;
		}
		
		// find the normal axis for each point and project
		for (i in 0...verts.length) {
			
			normalAxis = findNormalAxis(verts, i, normalAxis);
			vert = verts.get(0);
			// project the polygon(again? yes, circles vs. polygon require more testing...)
			min = normalAxis.dotProduct(vert.x, vert.y); //project
			max = min; //set max and min
			
			//project all the other points(see, cirlces v. polygons use lots of this...)
			for (j in 1 ... verts.length) {
				vert = verts.get(j);
				dotProduct = normalAxis.dotProduct(vert.x, vert.y); //more projection
				if(dotProduct < min) {
					min = dotProduct;
				} //smallest min
				if(dotProduct > max) {
					max = dotProduct;
				} //largest max
			}
			
			// project the circle(again)
			max2 = c.transformedRadius; //max is radius
			min2 = -c.transformedRadius; //min is negative radius
			
			//offset points
			offset = normalAxis.dotProduct(dx, dy);
			min += offset;
			max += offset;
			
			// do the test, again
			t1 = min - max2;
			t2 = min2 - max;
			
			if(t1 > 0 || t2 > 0) {
				//failed.. quit now
				return false;
			}
		}
		
		if (cdata != null) {
			cdata.intersects = true;
			cdata.dv.x = dx;
			cdata.dv.y = dy;
			cdata.px = normalAxis.x * (max2 - min) * -1;
			cdata.py = normalAxis.y * (max2 - min) * -1;
			cdata.oH = dx < 0 ? -1 : 1;
			cdata.oV = dy < 0 ? -1 : 1;
		}
		
		return true;
	}
	
	// Poly Box Collision
	
	
	// Poly Line Collision
	
	
	// Poly Point Collision
	
	
	
	/**
	 * Factory Methods
	 */
	public static function getCollisionData() :CollisionData 
	{
		if (_cdatas == null) {
			_cdatas = new Array<CollisionData>();			
		}
		if (_cdatas.length == 0) { // if we are empty, add one
			_cdatas.push( new CollisionData( false, 0, 0, new Vector2D(), 0, 0, null) );
		}		
		return _cdatas.pop();
	}	
	private static var _cdatas:Array<CollisionData>;
	
	public static function freeCollisionData( cdata:CollisionData ) :Void 
	{
		if (_cdatas == null) {
			_cdatas = new Array<CollisionData>();
		}
		// start at the first
		CollisionData.getFirst( cdata );
		// add all of them to the pool
		_cdatas.push(cdata);
		while ( cdata.hasNext() ) {
			cdata = cdata.getNext();
			_cdatas.push( cdata );
		}
		// free all of them
		cdata.free();
	}
	
	/**
	 * Static Helpers
	 */	
	
	private static function findNormalAxis( verts:Vertices, index:Int, result:Vector2D = null ) :Vector2D 
	{
		if (result == null) { result = new Vector2D(); }
		
		
		return result;
	}
	
	// TODO: are there any?
	
	// commonly used variables for functions
	private static var _distance:Float;	// distance	
	private static var _d2		:Float;
	private static var _px 		:Float;	// penetration depth
	private static var _py 		:Float;	
	private static var _dx 		:Float;	// delta
	private static var _dy 		:Float;
	private static var _xx 		:Float; // multi-use x and y
	private static var _yy 		:Float;	 
	private static var _dp 		:Float;	// dot product
	private static var _cp 		:Float;	// cross product	
	private static var _max 	:Float; // max value
	private static var _min 	:Float; // min value
	private static var _s		:Float;
	private static var _t		:Float;
	private static var _s1		:Vector2D;
	private static var _s2		:Vector2D;
	private static var _ev		:Vector2D;
	private static var _ev2		:Vector2D;
	private static var _ev3		:Vector2D;
	private static var _ev4		:Vector2D;		
	//private static var _point 	:Point;
	//private static var _point2 	:Point;
	
	private static var _top		:Int;
	private static var _left	:Int;
	private static var _bottom	:Int;
	private static var _right	:Int;	
	private static var _x		:Int;
	private static var _y		:Int;
	private static var _aabb	:AABB;
	
}