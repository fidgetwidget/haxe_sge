package sge.physics;

import haxe.FastList;
import nme.errors.Error;
import nme.geom.Point;

import sge.geom.LineSegment;
import sge.geom.Vertices;

/** *INCOMPLETE*
 * ...
 * // TODO: move the collision checking of entities into here
 * // TODO: fix the circle aabb collision detection (right now its acting like aabb aabb collisions
 * 
 * @author fidgetwidget
 */

// for use in get closest
typedef Edge = {
	sx:Float,
	sy:Float,
	ex:Float,
	ey:Float
}  

class CollisionMath 
{
	
	/**
	 * Math Helpers
	 */
	
	public static function clamp( value:Float, min:Float, max:Float ) :Float 
	{
		return ( value < min ? min : (value > max ? max : value) );
	}
	
	public static inline function distanceBetween_xy( x1:Float, y1:Float, x2:Float, y2:Float ) :Float
	{
		return Math.sqrt( ((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)) );
	}
	
	public static inline function distanceBetween_points( p1:Point, p2:Point ) :Float
	{
		return (p1 == p2 ? 0 : distanceBetween_xy( p1.x, p1.y, p2.x, p2.y ));
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
	
	public static function getClosest_point( edge:Edge, 
	 pointX:Float, pointY:Float, closest:Point = null ) :Point
	{
		if (closest == null) { closest = new Point(); }
		
		// segment vector (uses length)
		var segmentVector:Vec2 = new Vec2();
		segmentVector.x = edge.ex - edge.sx;
		segmentVector.y = edge.ey - edge.sy;
		
		if (segmentVector.length <= 0) { throw new Error("Invalid Segment Length"); }
		var distance:Float = segmentVector.length;
		
		// point vector (uses dotProduct)
		var pointVector:Vec2 = new Vec2();
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
	
	public static inline function linesIntersect_fast( startA:Vec2, endA:Vec2, startB:Vec2, endB:Vec2 ) :Bool 
	{		
		var s1_x:Float = endA.x - startA.x;
		var s1_y:Float = endA.y - startA.y;
		var s2_x:Float = endB.x - startB.x;
		var s2_y:Float = endB.y - startB.y;
		
		var s:Float = (-s1_y * (startA.x - startB.x) + s1_x * (startA.y - startB.y)) / (-s2_x * s1_y + s1_x * s2_y);
        var t:Float = ( s2_x * (startA.y - startB.y) - s2_y * (startA.x - startB.x)) / (-s2_x * s1_y + s1_x * s2_y);

        return (s >= 0 && s <= 1 && t >= 0 && t <= 1);
	}
	
	public static inline function linesIntersect( startA:Vec2, endA:Vec2, startB:Vec2, endB:Vec2, hitPoint:Vec2 = null ) :Vec2
	{
		if (hitPoint == null) { hitPoint = new Vec2(); }
		
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
		// distance between the two circles (x)
		var dx:Float = c2.x - c1.x;
		// the x depth
		var px:Float = (c1.radius + c2.radius) - Math.abs(dx);
		if (px > 0) {
			// distance between the two circles (y)
			var dy:Float = c2.y - c1.y;
			// the y depth
			var py:Float = (c1.radius + c2.radius) - Math.abs(dy);
			if (py > 0) {
				
				if (cdata != null) {
					
					cdata.intersects = true;
					cdata.oH = 0;
					cdata.oV = 0;
					
					cdata.dv.x = dx;
					cdata.dv.y = dy;
					
					var distance:Float = Math.sqrt( (dx * dx) + (dy * dy) );	// normalize the difference vector
					dx = dx / distance;
					dy = dy / distance;
					var penetration:Float = Math.sqrt( (px *px) + (py * py) ); 	// get the penetration depth
					cdata.px = penetration * dx;								// apply the normalized penetration depth
					cdata.py = penetration * dy;
				}
				return true;
			}
		}
		return false;
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
					cdata.px = px;
					cdata.py = py;
					cdata.dv.x = -dx;
					cdata.dv.y = -dy;
					
					cdata.oH = 0;
					cdata.oV = 0;
					
					if ( b.cx - c.x < -b.width ) { 
						
						cdata.oH = -1; 
					} 
					else 
					if ( b.width < b.cx - c.x ) { 
						
						cdata.oH = 1; 
					}
					
					if ( b.cy - c.y < -b.height ) { 
						
						cdata.oV = -1; 
					} 
					else 
					if ( b.height < b.cy - c.y ) { 
						
						cdata.oV = 1; 
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
		var point:Point = getClosest_point( { sx:startX, sy:startY, ex:endX, ey:endY }, c.x, c.y); 
		// distance vector
		var dv:Vec2 = new Vec2();
		dv.x = c.x - point.x;
		dv.y = c.y - point.y;
		// distance
		var distance:Float = dv.length;
		
		if (distance >= c.radius) { 			
			
			if ( cdata != null ) {
				cdata.intersects = true;
				var px:Float = dv.x / distance * (c.radius - distance);
				var py:Float = dv.y / distance * (c.radius - distance);
				cdata.oH = (point.x > c.x) ? 1 : -1;
				cdata.oH = (point.y > c.y) ? 1 : -1;
				cdata.px = px;
				cdata.py = py;
				cdata.dv.x = dv.x;
				cdata.dv.y = dv.y;
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
					
					cdata.px = px;
					cdata.py = py;
					cdata.dv.x = dx;
					cdata.dv.y = dy;
					cdata.oH = dx > 0 ? 1 : -1;
					cdata.oV = dy > 0 ? 1 : -1;
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
					// project in the lesser depth
					cdata.oH = dx < 0 ? -1 : 1;
					cdata.oV = dy < 0 ? -1 : 1;
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
			
		// TODO: we should adjust the cdata to be from the perspective of the box, 
		// instead of the circle (reverse the oH and oV?)
		return circleBoxCollision(c, b, cdata);
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
		var bounds:AABB = p.getBounds();
		if ( !c.collideAABB(bounds) ) { return false; }
		
		var vert:Vec2;
		var dotProduct:Float;
		var closestVector:Vec2 = new Vec2();
		var normalAxis:Vec2 = new Vec2();		
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
			var px:Float = normalAxis.x * (max2 - min) * -1;
			var py:Float = normalAxis.y * (max2 - min) * -1;
			cdata.px = px;
			cdata.py = py;
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
			_cdatas = new FastList<CollisionData>();			
		}
		if (_cdatas.head == null) { // if we are empty, add one
			_cdatas.add( new CollisionData( false, 0, 0, new Vec2(), 0, 0, null) );
		}		
		return _cdatas.pop();
	}	
	private static var _cdatas:FastList<CollisionData>;
	
	public static function freeCollisionData( cdata:CollisionData ) :Void 
	{
		if (_cdatas == null) {
			_cdatas = new FastList<CollisionData>();
		}
		// start at the first
		CollisionData.getFirst( cdata );
		// add all of them to the pool
		_cdatas.add(cdata);
		while ( cdata.hasNext() ) {
			cdata = cdata.getNext();
			_cdatas.add( cdata );
		}
		// free all of them
		cdata.free();
	}
	
	/**
	 * Static Helpers
	 */	
	
	private static function findNormalAxis( verts:Vertices, index:Int, result:Vec2 = null ) :Vec2 
	{
		if (result == null) { result = new Vec2(); }
		
		
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
	private static var _s1		:Vec2;
	private static var _s2		:Vec2;
	private static var _ev		:Vec2;
	private static var _ev2		:Vec2;
	private static var _ev3		:Vec2;
	private static var _ev4		:Vec2;		
	private static var _point 	:Point;
	private static var _point2 	:Point;
	
	private static var _top		:Int;
	private static var _left	:Int;
	private static var _bottom	:Int;
	private static var _right	:Int;	
	private static var _x		:Int;
	private static var _y		:Int;
	private static var _aabb	:AABB;
	
}