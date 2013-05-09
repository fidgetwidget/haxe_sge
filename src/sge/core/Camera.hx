package sge.core;

import com.eclecticdesignstudio.motion.easing.Quad;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.IEasing;
import com.eclecticdesignstudio.motion.easing.Linear;
import nme.geom.Point;

import sge.physics.Vec2;
import sge.physics.Motion;
import sge.physics.AABB;
import sge.physics.Physics;

/**
 * ...
 * @author fidgetwidget
 */

 // TODO: need to add handling for world bounds (prevent the camera bounds from going out of bounds)
 // TODO: create additional Camera types - eg. top down zelda camera (room based)
 // TODO: add elements that allow for camera effects (shake, etc)
 
class Camera
{
	
	public static inline var TARGET_GOTO :Int = 0; // move to point, then stop
	public static inline var TARGET_FIXED:Int = 1; // fixed point follow
	public static inline var TARGET_CLOSE:Int = 2; // follow tight square
	public static inline var TARGET_LOOSE:Int = 4; // follow large square
	
	//* amount in % of the camera bounds
	public static inline var CLOSE_DISTANCE:Float = 0.2;
	public static inline var LOOSE_DISTANCE:Float = 0.5;
	
	/*
	 * Properties
	 */
	public var useParalax:Bool;
	public var sceneBounds:AABB;
	public var bounds:AABB;
	public var center(get_center, never) :Vec2;
	public var x(get_x, set_x):Float;
	public var y(get_y, set_y):Float;
	public var cx(get_cx, set_cx):Float;
	public var cy(get_cy, set_cy):Float;
	public var width(get_width, set_width):Float;
	public var height(get_height, set_height):Float;
	public var motion:Motion;
	
	/*
	 * Members
	 */
	private var _target:Point;
	private var _targetType:Int = 0;
	private var _targetBounds:AABB;
	private var _targetEase:IEasing;
	private var _moveDuration:Float;
	private var _currDuration:Float;
	private var _targetZoom:Float;
	private var _zoom:Float;	
	private var _dx:Float;
	private var _dy:Float;
	
	 
	public function new() {	
		useParalax = false;
		_zoom = 1;	
		sceneBounds = new AABB();
		sceneBounds.width = Math.POSITIVE_INFINITY;
		sceneBounds.height = Math.POSITIVE_INFINITY;
		bounds = new AABB();
		_targetBounds = new AABB();
	}	
	
	public function update( delta:Float ) :Void
	{
		if (_target != null)
			_updatePosition( delta );
		else 
		if (motion != null && motion.inMotion) {
			x += motion.vx * delta;
			y += motion.vy * delta;
			motion.apply(null, delta);
		}
		
		_correctPosition();
		
		if (_zoom != _targetZoom) 
			_updateZoom( delta );
	}
	
	private function _updatePosition( delta:Float ) :Void 
	{		
		if (_target == null) { return; }
		if (_targetType == TARGET_FIXED) {
			bounds.cx = _target.x;
			bounds.cy = _target.y;
		}
		else
		if (_targetType == TARGET_CLOSE ||
		 _targetType == TARGET_LOOSE) {
			_targetBounds.cx = bounds.cx;
			_targetBounds.cy = bounds.cy;
			
			if (!_targetBounds.containsPoint(_target.x, _target.y)) {
				bounds.cx -= (bounds.cx - _target.x) * _targetEase.calculate(delta);
				bounds.cy -= (bounds.cy - _target.y) * _targetEase.calculate(delta);
			}
		}
	}
	
	private function _updateZoom( delta:Float ) :Void
	{
		// TODO: move the zoom value towards the target
	}
	
	//* Note: set target to null to cancel the follow
	public function followTarget( target:Point, targetType:Int = TARGET_FIXED, easeType:IEasing = null ) :Void 
	{
		// Special Cases
		if (target == null) {
			_target = null;
			return;
		}
		
		if (targetType == TARGET_GOTO) {
			_target = null;
			moveTo(target.x, target.y, Physics.distanceBetween_xy(center.x, center.y, target.x, target.y), easeType );
			return;
		}
		
		_target = target;
		_targetType = targetType;
		_targetBounds.width = bounds.width;
		_targetBounds.height = bounds.height;
		switch (targetType) {
			case 2:
				_targetBounds.width *=  CLOSE_DISTANCE;
				_targetBounds.height *= CLOSE_DISTANCE;
			case 4:
				_targetBounds.width *=  LOOSE_DISTANCE;
				_targetBounds.height *= LOOSE_DISTANCE;			
		}
		_targetEase = easeType == null ? Linear.easeNone : easeType;
	}	
	
	// move the camear to a position
	public function moveBy( x:Float = 0, y:Float = 0, t:Float = 1, easeType:IEasing = null ) :Void
	{
		moveTo( bounds.cx + x, bounds.cy + y, t, easeType );
	}
	
	public function moveTo( x:Float, y:Float, t:Float, easeType:IEasing = null ) :Void
	{
		if (t == 0) {
			bounds.cx = x;
			bounds.cy = y;
			return;
		}
		if (easeType == null) { easeType = Linear.easeNone; }
		Actuate.tween( bounds, t, { cx: x, cy: y } ).ease( easeType ).onUpdate( _tweenUpdate );
	}
	
	// adjust the camear to a zoom
	public function zoomTo( zoom:Float ) :Void
	{
		_targetZoom = zoom;
	}
	
	private function _tweenUpdate():Void 
	{
		if (!sceneBounds.containsAabb(bounds)) {
			Actuate.stop(bounds);
			_correctPosition();
		}
	}
	
	private function _correctPosition() :Void {
		
		if (bounds.left < sceneBounds.left) { 
			bounds.left = sceneBounds.left; 
		}
		else if (bounds.right > sceneBounds.right) { 
			bounds.right = sceneBounds.right;
		}
		
		if (bounds.top < sceneBounds.top) { 
			bounds.top = sceneBounds.top; 
		}
		else if (bounds.bottom > sceneBounds.bottom) { 
			bounds.bottom = sceneBounds.bottom;
		}
	}
	
	private function get_center() :Vec2				{ return bounds.center; }
	private function get_x() :Float 				{ return bounds.left; }
	private function get_y() :Float 				{ return bounds.top; }
	private function get_cx() :Float 				{ return bounds.cx; }
	private function get_cy() :Float 				{ return bounds.cy; }
	private function get_width() :Float				{ return bounds.width; }
	private function get_height() :Float			{ return bounds.height; }
	
	private function set_x( x:Float ) :Float 		{ return bounds.left = x; }
	private function set_y( y:Float ) :Float 		{ return bounds.top = y; }
	private function set_cx( x:Float ) :Float 		{ return bounds.cx = x; }
	private function set_cy( y:Float ) :Float 		{ return bounds.cy = y; }
	private function set_width( w:Float ) :Float	{ return bounds.width = w; }
	private function set_height( h:Float ) :Float	{ return bounds.height = h; }
	
	
	
	
}