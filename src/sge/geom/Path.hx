package sge.geom;

import flash.display.Graphics;
import flash.geom.Point;
import sge.graphics.Camera;
import sge.math.Vector2D;

/**
 * ...
 * @author fidgetwidget
 */
class Path extends Vertices
{

	/*
	 * Properties
	 */	
	public var currentPosition	( get, never ) : Vector2D;
	public var on_pathComplete	: Dynamic;
	
	/*
	 * Members
	 */
	private var _passedTarget	: Bool = false;
	private var _current		: Vector2D;	
	private var _target			: Vector2D;
	
	/// Memory Savers
	private var _point			: Vector2D;
	private var _ev				: Vector2D;
	private var _dx				: Float;
	private var _dy				: Float;
	private var _xx				: Float;
	private var _yy				: Float;
	private var _m				: Float;
	
	
	
	public function new( points:Array<Point> = null ) 
	{
		super(points);
		_ev = new Vector2D();
		_current = null;
	}
	
	public function move( delta:Float, speed:Float ) :Vector2D {
		
		if (_current == null) {
			if (_verts.length == 0) 
				return null;
			
			_current = _verts[0];
			_verts.splice(0, 1);
		}
		
		if (_verts.length == 0) {
			clear();
			pathComplete();
			return _current;
		}
		
		_target = _verts[0];
		_passedTarget = false;
		
		// this shouldn't happen, but it did once :S
		if (_target == _current ||
		(_target.x == _current.x &&
		 _target.y == _current.y)) {
			 
			_current = _verts[0];
			_verts.splice(0, 1);
			return _current;			
		}
		
		_dx = _target.x - _current.x;
		_dy = _target.y - _current.y;
		
		_ev.x = _dx;
		_ev.y = _dy;
		_ev.normalize();
		
		_xx = _ev.x * speed * delta;
		_yy = _ev.y * speed * delta;
		
		// test for passing the target
		if ( Math.abs(_xx) > Math.abs(_dx) ) {
			_ev.x = _xx - _dx; // save the remaining magnatude
			_xx = _dx;
			_passedTarget = true;
		}
		if ( Math.abs(_yy) > Math.abs(_dy) ) {
			_ev.y = _yy - _dy; // save the remaining magnatude
			_yy = _dy;
			_passedTarget = true;
		}
		
		_current.x += _xx;
		_current.y += _yy;
		
		// don't continue on if we are at the end of the path
		if (_passedTarget && _verts.length > 1) {
			
			_verts.splice(0, 1); // remove current
			_target = _verts[0];
			
			_dx = _target.x - _current.x; 
			_dy = _target.y - _current.y;
			
			// get the remainders magnatude
			_m = Math.sqrt(_ev.x * _ev.x +_ev.y * _ev.y); 
			
			// get the new target direction vector
			_ev.x = _dx;
			_ev.y = _dy;
			_ev.normalize();
			
			// direction vector * remaining magnatudes
			_current.x += _ev.x * _m;
			_current.y += _ev.y * _m;
		} 
		else
		if (_passedTarget && _verts.length == 1) {
			// we've reached the end target
			clear();
			pathComplete();
		}
		
		return _current;
	}
	
	
	public function draw( graphics:Graphics, camera:Camera = null ) :Void
	{
		_point = _current;
		if (_current == null) { return; }
		
		if (camera == null) {
			
			graphics.moveTo(
			 _point.x, 
			 _point.y);
			for (i in 0 ... _verts.length) {
				_point = _verts[i];
				graphics.lineTo(
				 _point.x, 
				 _point.y);
			}
		} else {
			graphics.moveTo(
			 _point.x - camera.x, 
			 _point.y - camera.y);
			for (i in 0 ... _verts.length) {
				_point = _verts[i];
				graphics.lineTo(
				 _point.x - camera.x, 
				 _point.y - camera.y);
			}
		}
	}
	
	private function pathComplete() :Void {
		
		if ( on_pathComplete != null )  {
			on_pathComplete( this );
		}		
	}
	
	override public function clear():Void 
	{
		super.clear();
		_current = null;
	}
	
	
	private function get_currentPosition() :Vector2D {
		
		if (_current == null) {
			if (_verts.length == 0) 
				return null;
			
			_current = _verts[0];			
			_verts.splice(0, 1);
		}
		
		return _current; 
	}
	
}