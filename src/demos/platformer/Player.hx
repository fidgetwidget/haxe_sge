package demos.platformer;

import nme.display.Shape;
import nme.ui.Keyboard;

import sge.core.Camera;
import sge.core.Entity;
import sge.core.Engine;
import sge.graphics.Draw;
import sge.geom.Box;
import sge.physics.AABB;
import sge.physics.BoxCollider;
import sge.physics.Motion;
import sge.random.Random;
import sge.io.Input;


/**
 * ...
 * @author fidgetwidget
 */

class Player extends Entity
{
	
	public var WIDTH:Int = 18;
	public var HEIGHT:Int = 42;	
	public var paused:Bool = true;
	
	var speed:Float = 320;
	var max_speed:Float = 800;
	var jump_thrust:Float = 1200;
	
	public var jumping:Bool = false;
	var jumpspeed:Float;
	var cur_jumpTime:Float = 0;
	var jumpTime:Float = 0.4;	
	public var falling:Bool = true;
	var fall_speed:Float = 400;	
	
	private var _madeVisible:Bool = false;
	private var _shape:Shape;
	private var _box:Box;
	private var _boxCollider:BoxCollider;
	private var _mv:Float;
	private var _m2:Float;
	private var _nx:Float;
	private var _ny:Float;

	public function new() 
	{
		super();
		className = Type.getClassName(demos.platformer.Player);
		
		_box = new Box(WIDTH * 0.5, HEIGHT * 0.5, WIDTH, HEIGHT);
		_boxCollider = new BoxCollider(_box, this);	
		_shape = new Shape();		
		motion = new Motion();
		mc = _shape;
		collider = _boxCollider;
		
		_visible = true;
		_active = true;
		state = Entity.DYNAMIC;
		
		motion.fx = 0.025;
		motion.fy = 0.01;
		_m2 = max_speed * max_speed;
		
	}
	
	override private function _input(delta:Float):Void 
	{
		if ( Input.isKeyDown(Keyboard.W) || Input.isKeyDown(Keyboard.UP) ) {
			if (!jumping && !falling) {
				jumpspeed = jump_thrust;
				cur_jumpTime = 0;
				jumping = true;	
			}
		} else {
			jumping = false;
			falling = true;
		}
		if (jumping && cur_jumpTime < jumpTime && jumpspeed > 0) {
			cur_jumpTime += delta;
			motion.vy -= jumpspeed * delta;
			jumpspeed -= fall_speed * cur_jumpTime;
		} else
		{
			jumping = false;
			falling = true;
			motion.vy += fall_speed * delta;			
		}
		
		if ( Input.isKeyDown(Keyboard.A) || Input.isKeyDown(Keyboard.LEFT) ) {
			motion.vx -= speed * delta;
		}
		else
		if ( Input.isKeyDown(Keyboard.D) || Input.isKeyDown(Keyboard.RIGHT) ) {
			motion.vx += speed * delta;
		}
		
		if (cur_jumpTime > jumpTime) {
			falling = true;
		}		
	}	
	
	override private function _update( delta:Float ):Void 
	{		
		_mv = motion.vx * motion.vx + motion.vy * motion.vy;
		if (_mv > _m2) {
			_mv = Math.sqrt(_mv);
			_nx = motion.vx / _mv;
			_ny = motion.vy / _mv;
			motion.vx = _nx * max_speed;
			motion.vy = _ny * max_speed;
		}
	}	
	
	override public function _render( camera:Camera ):Void 
	{
		mc.x = x - camera.x;
		mc.y = y - camera.y;
	}
	
	override private function get_visible():Bool 
	{
		if (_visible && !_madeVisible) { makeVisible(); }
		if (!_visible) { _shape.graphics.clear(); }
		return _visible;
	}
	
	private function makeVisible() :Void {
		
		if (mc == null) { return; }		
		if (_shape.graphics == null) { return; }
		
		_shape.graphics.clear();		
		_shape.graphics.lineStyle(1, 0x2332CF);
		_shape.graphics.beginFill(0x2332CF);
		_shape.graphics.drawRect(0, 0, WIDTH, HEIGHT);		
		_shape.graphics.endFill();
		
		_madeVisible = true;
	}
	
	
}