package sge.graphics;

import motion.Actuate;
import motion.easing.IEasing;
import motion.easing.Linear;
import motion.easing.Quad;
import sge.math.Random;

import sge.collision.AABB;
import sge.math.Vector2D;

/**
 * ...
 * @author fidgetwidget
 */

// TODO: improve the camera
 
class Camera
{
	
	/*
	 * Properties
	 */

	public var sceneBounds:AABB;
	public var bounds:AABB;
	
	public var x(get_x, set_x):Float;
	public var y(get_y, set_y):Float;
	public var ix(get_ix, never):Int;
	public var iy(get_iy, never):Int;
	public var center(get_center, never) :Vector2D;
	public var cx(get_cx, set_cx):Float;
	public var cy(get_cy, set_cy):Float;
	public var width(get_width, set_width):Float;
	public var height(get_height, set_height):Float;
	
	public var useParalax:Bool;
	
	/*
	 * Members
	 */
	private var _offset:Vector2D;
	private var _shakeDuration:Float;
	private var _shakeIntensity:Float;	
	private var _shakeFrequency:Int;
	private var _shakeTarget:Vector2D;
	private var _shakeCount:Int;
	
	private var _target:Vector2D;
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
		
		bounds = new AABB();		
		sceneBounds = new AABB();
		sceneBounds.width = Math.POSITIVE_INFINITY;
		sceneBounds.height = Math.POSITIVE_INFINITY;
		
		_offset = new Vector2D();
		_shakeTarget = new Vector2D();
		
		_targetBounds = new AABB();
		_zoom = 1;	
	}	
	
	public function update( delta:Float ) :Void
	{
		_updatePosition( delta );
		_correctPosition();
		_updateZoom( delta );			
	}
	
	private function _updatePosition( delta:Float ) :Void 
	{	
		if (_target != null)
			moveTo(_target.x, _target.y, 0.33, _targetEase);
	}
	
	private function _updateZoom( delta:Float ) :Void
	{
		// TODO: move the zoom value towards the target
	}
	
	
	// move the camear to a position
	public function moveBy( x:Float = 0, y:Float = 0, t:Float = 1, easeType:IEasing = null ) :Void
	{
		moveTo( bounds.cx + x, bounds.cy + y, t, easeType );
	}
	
	public function moveTo( x:Float, y:Float, time:Float, easeType:IEasing = null ) :Void
	{
		if (time == 0) {
			bounds.cx = x;
			bounds.cy = y;
			return;
		}
		if (easeType == null) { easeType = Linear.easeNone; }
		Actuate.tween( bounds, time, { cx: x, cy: y } ).ease( easeType ).onUpdate( _tweenUpdate );
	}
	
	// adjust the camear to a zoom
	public function zoomTo( zoom:Float ) :Void
	{
		_targetZoom = zoom;
	}
	
	/**
	 * Shake the Camera
	 * @param	duration	the length of time to shake the camera for
	 * @param	intensity	the distance from the center each shake should move out
	 * @param	frequency	the number of shakes per second
	 */
	public function shake( duration:Float = 0.33, intensity:Float = 5, frequency:Int = 20 ) :Void 
	{		
		_offset.x = 0;
		_offset.y = 0;
		_shakeDuration = duration;
		_shakeIntensity = intensity;
		_shakeFrequency = Math.floor(frequency * duration);
		_shakeCount = _shakeFrequency;
		
		Random.instance.randomDir(_shakeTarget);
		_shakeTarget.scale( _shakeIntensity );
		
		_shake();
	}
	
	private function _shake() :Void {
		Actuate.stop( _offset );
		_offset.x = 0;
		_offset.y = 0;
		Actuate.tween( _offset, (_shakeDuration / _shakeFrequency) * 0.5, { x:_shakeTarget.x, y:_shakeTarget.y } ).onComplete( _shakeComplete );
	}
	
	private function _shakeComplete() :Void 
	{
		if (_shakeCount <= 0) {
			_shakeDuration = 0;
			_shakeFrequency = 0;
			_shakeIntensity = 0;
			_offset.x = 0;
			_offset.y = 0;
			return;
		}		
		
		if (_shakeTarget.x != 0 || _shakeTarget.y != 0) {
			Random.instance.randomDir(_shakeTarget);
			_shakeTarget.scale( _shakeIntensity );
		} else {
			_shakeTarget.set(0, 0);
		}
		
		_shake();
		
		_shakeCount--;
	}
	
	
	private function _tweenUpdate():Void 
	{
		if (!sceneBounds.containsAabb(bounds)) {
			//Actuate.stop(bounds);
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
	
	/*
	 * Getters & Setters
	 */
	
	private function get_center() 			:Vector2D	{ return bounds.center; }
	private function get_x() 				:Float 		{ return bounds.left + _offset.x; }
	private function get_y() 				:Float 		{ return bounds.top + _offset.y; }
	private function get_ix() 				:Int		{ return Std.int(bounds.left + _offset.x); }
	private function get_iy() 				:Int		{ return Std.int(bounds.top + _offset.y); }
	private function get_cx() 				:Float 		{ return bounds.cx + _offset.x; }
	private function get_cy() 				:Float 		{ return bounds.cy + _offset.y; }
	private function get_width() 			:Float		{ return bounds.width; }
	private function get_height() 			:Float		{ return bounds.height; }
	
	private function set_x( x:Float ) 		:Float 		{ return bounds.left = x; }
	private function set_y( y:Float ) 		:Float 		{ return bounds.top = y; }
	private function set_cx( x:Float ) 		:Float 		{ return bounds.cx = x; }
	private function set_cy( y:Float ) 		:Float 		{ return bounds.cy = y; }
	private function set_width( w:Float )	:Float		{ return bounds.width = w; }
	private function set_height( h:Float )	:Float		{ return bounds.height = h; }
	
	
	
	
}