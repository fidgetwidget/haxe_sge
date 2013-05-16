package demos.cameraTest;

import nme.display.Graphics;
import nme.display.Shape;
import nme.display.Sprite;
import nme.geom.Point;
import nme.ui.Keyboard;
import sge.geom.Circle;

import sge.core.Camera;
import sge.core.Entity;
import sge.core.Engine;
import sge.graphics.Draw;
import sge.io.Input;
import sge.geom.Path;
import sge.random.Random;
import sge.physics.CircleCollider;
import sge.physics.CollisionMath;
import sge.physics.Motion;

/**
 * ...
 * @author fidgetwidget
 */

class Player extends Entity
{
	
	static inline var speed:Float = 200;
	static inline var maxspeed:Float = 200;
	public var radius:Float = 16;
	
	/*
	 * Properties
	 */
	public var path:Path;
	public var hasPath(get_hasPath, never):Bool;
	public var drawingPath:Bool = false;
	public var camera:Camera;
	
	/*
	 * Members
	 */
	private var localX:Float;
	private var localY:Float;
	private var _circle:Circle;
	private var _circleCollider:CircleCollider;
	private var _shape:Shape;

	public function new() 
	{
		super();
		className = Type.getClassName(Player);	
		_circle = new Circle(0, 0, radius);
		_circleCollider = new CircleCollider(_circle, this);
		collider = _circleCollider;
		_visible = true;
		_active = true;
		
		motion = new Motion();
		motion.vf = 1;
		
		_m2 = maxspeed * maxspeed;	
		
		state = Entity.DYNAMIC;
		path = new Path();
		
		_shape = new Shape();
		mc = _shape;
	}
	
	
	override private function _update( delta:Float ):Void 
	{		
		_l = motion.vx * motion.vx + motion.vy * motion.vy;
		if (_l > _m2) {
			_l = Math.sqrt(_l);
			_nx = motion.vx / _l;
			_ny = motion.vy / _l;
			motion.vx = _nx * maxspeed;
			motion.vy = _ny * maxspeed;
		}		
	}
	
	override private function _updateTransform( delta:Float ):Void 
	{
		if (hasPath && 
		 motion.vx == 0 && 
		 motion.vy == 0 ) {
			path.move( delta, speed );			
			
			_t.position.x = path.currentPosition.x;
			_t.position.y = path.currentPosition.y;
		} 
		else
		if (hasPath && 
		 (motion.vx != 0 ||
		  motion.vy != 0)) {
			path.clear();
		}
		else 
		{
			super._updateTransform( delta );
		}
	}
	
	public function addPathPoint( point:Point ) :Void {
		path.add_Point( point );
		motion.vx = 0;
		motion.vy = 0;
	}
	
	//TODO: change this, because this means you will never reach the end point
	private function get_hasPath() :Bool { return path.length > 1;  }
	
	private var _nx:Float;
	private var _ny:Float;
	private var _l:Float;
	private var _m2:Float; // maxspeed squared;
	
	override public function _render( camera:Camera ):Void 
	{
		mc.x = x - camera.x;
		mc.y = y - camera.y;
		
		if (hasPath) {
			Draw.graphics.lineStyle(2, 0x2332CF);
			path.render( camera, Draw.graphics );
		}
	}
	
	override private function get_visible():Bool 
	{
		if (_visible && !madeVisible) { makeVisible(); }
		if (!_visible) { _shape.graphics.clear(); }
		return _visible;
	}
	
	private function makeVisible() :Void {
		
		if (mc == null) { return; }		
		if (_shape.graphics == null) { return; }
		
		_shape.graphics.clear();		
		_shape.graphics.lineStyle(1, 0x2332CF);
		_shape.graphics.beginFill(0x2332CF);
		_shape.graphics.drawCircle(0, 0, radius);
		
		_shape.graphics.endFill();
		madeVisible = true;
	}
	private var madeVisible:Bool = false;
	
}