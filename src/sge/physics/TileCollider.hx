package sge.physics;
import sge.geom.Box;

/**
 * ...
 * @author fidgetwidget
 */
class Directions
{
	
}
 
class TileCollider extends BoxCollider
{
	
	inline public static var NONE		:Int = 0;
	inline public static var UP			:Int = 1 << 00; // 1 << 00 (0x00000001) 
	inline public static var DOWN		:Int = 1 << 01; // 1 << 01 (0x00000002) 
	inline public static var LEFT		:Int = 1 << 02; // 1 << 02 (0x00000004) 
	inline public static var RIGHT		:Int = 1 << 03; // 1 << 03 (0x00000008) 
	inline public static var HORIZONTAL	:Int = LEFT | RIGHT;
	inline public static var VERTICAL	:Int = UP | DOWN;
	inline public static var ALL		:Int = UP | DOWN | LEFT | RIGHT;
	
	/*
	 * Properties 
	 */
	/// the Valid Directions a tile can be intersected
	/// eg. HORIZONTAL will only have x value penetration, where as LEFT will only have -x values
	public var directions:Int; 
	
	/*
	 * Members	 
	 */
	private var _results:Bool = false;

	public function new( box:Box ) 
	{
		super( box );
		_type = Type.getClassName( Type.getClass( this ) );	
		
		directions = ALL;
		
		_check.set( Type.getClassName(BoxCollider), collideBox );
		_check.set( Type.getClassName(CircleCollider), collideCircle );
		_check.set( Type.getClassName(PolygonCollider), collidePoly );
	}
	
	
	public override function contains( x:Float, y:Float ) :Bool {
		
		return AABB.aabbContainsPoint( getBounds(), x, y);
	}
	
	
	// TODO: optmize these - don't just alter the cdata
	
	public override function collidePoint( x:Float, y:Float, cdata:CollisionData = null ) :Bool {
		
		if (directions == NONE) { return false; }
		
		_results = CollisionMath.boxPointCollision( getBounds(), x, y, cdata );
		if (cdata != null) {
			_correctData( cdata );
			if (cdata.px == 0 && cdata.py == 0) {
				_results = false;
			}
		} 
		return _results;
	}
	
	public override function collideLine( x1:Float, y1:Float, x2:Float, y2:Float, cdata:CollisionData = null ) :Bool {
		
		if (directions == NONE) { return false; }
		
		_results = CollisionMath.boxLineCollision( getBounds(), x1, y1, x2, y2, cdata );
		if (cdata != null) {
			_correctData( cdata );
			if (cdata.px == 0 && cdata.py == 0) {
				_results = false;
			}
		} 
		return _results;
	}
	
	public override function collideAABB( target:AABB, cdata:CollisionData = null ) :Bool {
		
		if (directions == NONE) { return false; }
		
		_results = CollisionMath.boxBoxCollision( getBounds(), target, cdata );
		if (_results && cdata != null) {
			_correctData( cdata );
			if (cdata.px == 0 && cdata.py == 0) {
				_results = false;
			}
		} 
		return _results;
	}
	
	public override function collideBox( b:BoxCollider, cdata:CollisionData = null ) :Bool {

		if (directions == NONE) { return false; }
		
		_results = CollisionMath.boxBoxCollision( getBounds(), b.getBounds(), cdata );
		if (_results && cdata != null) {
			_correctData( cdata );
			if (cdata.px == 0 && cdata.py == 0) {
				_results = false;
			}
		} 
		return _results;
	}
	
	public override function collideCircle( c:CircleCollider, cdata:CollisionData = null ) :Bool {
		
		if (directions == NONE) { return false; }
		
		_results = CollisionMath.boxCircleCollision( getBounds(), c, cdata );
		if (_results && cdata != null) {
			_correctData( cdata );
			if (cdata.px == 0 && cdata.py == 0) {
				_results = false;
			}
		} 
		return _results;
	}
	
	
	// TODO: ----------------------	
	public override function collidePoly( p:PolygonCollider, cdata:CollisionData = null) :Bool { 
		return false;
	}
	// ----------------------------
	
	private function _correctData( cdata:CollisionData ) :Void
	{		
		
		if (directions == ALL) {
			return; // No correction nessesary
		} else
		if (directions & HORIZONTAL != 0) {
			
			// LEFT & RIGHT are fine, but it won't have both UP & DOWN
			if (directions & UP != 0) {				
				if (cdata.oV == -1) {
					cdata.oV = 1;
					cdata.py = Math.abs(cdata.py - height); // flip the value
					trace("py flipped");
				}
			} else
			if (directions & DOWN != 0) {
				if (cdata.oV == 1) {
					cdata.oV = -1;
					cdata.py = Math.abs(cdata.py - height); // flip the value
					trace("py flipped");
				}
			} else {
				cdata.oV = 0;
				cdata.py = 0;
			}
			
		} else 
		if (directions & VERTICAL != 0) {
			
			// UP and DOWN are fine, but it won't have both LEFT & RIGHT
			if (directions & LEFT != 0) {
				if (cdata.oH == 1) {
					cdata.oH = -1;
					cdata.px = Math.abs(cdata.px - width); // flip the value
					trace("px flipped");
				}
			} else
			if (directions & RIGHT != 0) {
				if (cdata.oH == -1) {
					cdata.oH = 1;
					cdata.px = Math.abs(cdata.px - width); // flip the value
					trace("px flipped");
				}
			} else {
				cdata.oH = 0;
				cdata.px = 0;
			}
			
		} else {
			
			// It won't have both UP & DOWN
			if (directions & UP != 0) {				
				if (cdata.oV == -1) {
					cdata.oV = 1;
					cdata.py = Math.abs(cdata.py - height); // flip the value
					trace("py flipped");
				}
			} else
			if (directions & DOWN != 0) {
				if (cdata.oV == 1) {
					cdata.oV = -1;
					cdata.py = Math.abs(cdata.py - height); // flip the value
					trace("py flipped");
				}
			} else {
				cdata.oV = 0;
				cdata.py = 0;
			}
			// It won't have both LEFT & RIGHT
			if (directions & LEFT != 0) {
				if (cdata.oH == 1) {
					cdata.oH = -1;
					cdata.px = Math.abs(cdata.px - width); // flip the value
					trace("px flipped");
				}
			} else
			if (directions & RIGHT != 0) {
				if (cdata.oH == -1) {
					cdata.oH = 1;
					cdata.px = Math.abs(cdata.px - width); // flip the value
					trace("px flipped");
				}
			} else {
				cdata.oH = 0;
				cdata.px = 0;
			}
			
		}
	}
	
	private override function get_x():Float { return _box.x; }
	private override function get_y():Float { return _box.y; }
	
}