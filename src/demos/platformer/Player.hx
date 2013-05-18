package demos.platformer;

import nme.display.Shape;
import nme.ui.Keyboard;
import sge.lib.World;
import sge.physics.CollisionMath;
import sge.physics.Vec2;

import sge.core.Camera;
import sge.core.Entity;
import sge.core.Engine;
import sge.graphics.Draw;
import sge.geom.Box;
import sge.physics.AABB;
import sge.physics.BoxCollider;
import sge.physics.CollisionData;
import sge.physics.Motion;
import sge.random.Random;
import sge.io.Input;


/**
 * ...
 * @author fidgetwidget
 */

class Player extends Entity
{
	private static var WIDTH:Int = 16;
	private static var HEIGHT:Int = 40;	
	private static var JUMP_HEIGHT:Int = 36;
	private static var CROUCH_HEIGHT:Int = 32;
	private static var SPEED:Float = 600;
	private static var MAX_SPEED:Float = SPEED * 3;
	private static var JUMP_THRUST:Float = SPEED * 5;
	private static var FALL_SPEED:Float = SPEED * 1.8;
	
	/*
	 * Properties 
	 */	
	public var paused:Bool = true;
	public var jumping:Bool = false;
	public var falling:Bool = true;
	public var crouching:Bool = false;
	public var world:World;
	
	/*
	 * Members
	 */
	private var jumpspeed:Float;
	private var cur_jumpTime:Float = 0;
	
	private var _madeVisible:Bool = false;
	private var _shape:Shape;
	private var _box:Box;
	private var _boxCollider:BoxCollider;
	
	/// Memory Saving (reused floats)
	private var _mv:Float;
	private var _m2:Float;
	private var _nx:Float;
	private var _ny:Float;

	public function new() 
	{
		super();
		className = Type.getClassName(demos.platformer.Player);
		
		_box = new Box(WIDTH * 0.5, -HEIGHT * 0.5, WIDTH, HEIGHT);
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
		_m2 = MAX_SPEED * MAX_SPEED;
		
	}
	
	override public function update(delta:Float):Void 
	{
		if (!active) { return; }
		
		var cdata = CollisionMath.getCollisionData();
		_input( delta );
		_update( delta );		
		_updateTransform( delta );
		doWorldCollisions(world, cdata);		
		CollisionMath.freeCollisionData(cdata);
	}
	
		
	override private function _input(delta:Float):Void 
	{
		if ( Input.isKeyPressed(Keyboard.W) || Input.isKeyPressed(Keyboard.UP) ) {
			if (!jumping && !falling) {
				jumpspeed = JUMP_THRUST;
				cur_jumpTime = 0;
				jumping = true;	
			}
		} else 
		if ( !Input.isKeyDown(Keyboard.W) && !Input.isKeyDown(Keyboard.UP) ) {
			jumping = false;
			jumpspeed = 0;
			falling = true;
		} 
		
		if ( Input.isKeyDown(Keyboard.S) || Input.isKeyDown(Keyboard.DOWN) ) {
			crouching = true;
		} else {
			crouching = false;
		}
		
		if (jumping && jumpspeed > 0) {
			cur_jumpTime += delta;
			jumpspeed -= FALL_SPEED * cur_jumpTime;
			motion.vy -= jumpspeed * delta;
			
		} else { 
			jumping = false; 
		}		
		if (falling) {
			motion.vy += FALL_SPEED * delta;
		}
		
		if ( Input.isKeyDown(Keyboard.A) || Input.isKeyDown(Keyboard.LEFT) ) {
			motion.vx -= SPEED * delta;
		}
		else
		if ( Input.isKeyDown(Keyboard.D) || Input.isKeyDown(Keyboard.RIGHT) ) {
			motion.vx += SPEED * delta;
		}
		
		if (crouching) {
			_box.height = CROUCH_HEIGHT;
			_box.y = -CROUCH_HEIGHT * 0.5;
		} else 
		if (jumpspeed > 0) {
			_box.height = JUMP_HEIGHT;
			_box.y = -JUMP_HEIGHT * 0.5;
		} else {
			_box.height = HEIGHT;
			_box.y = -HEIGHT * 0.5;
		}
		
		
	}

	override private function _update( delta:Float ):Void 
	{		
		_mv = motion.vx * motion.vx + motion.vy * motion.vy;
		if (_mv > _m2) {
			_mv = Math.sqrt(_mv);
			_nx = motion.vx / _mv;
			_ny = motion.vy / _mv;
			motion.vx = _nx * MAX_SPEED;
			motion.vy = _ny * MAX_SPEED;
		}
	}	
	
	public function doWorldCollisions( world:World, cdata:CollisionData ) :Void {
		var aabb:AABB;
		if (p == null) {
			p = new Vec2();
		}
		p.x = 0;
		p.y = 0;
		
		CollisionData.getFirst(cdata);
		aabb = getBounds();
		aabb.width -= 2; /// this is to prevent wall grabbing		
		
		// do top/bottom collision
		if (world.collideAabb( aabb, 0, cdata )) {
			p = CollisionData.getSmallest(cdata, p);			
			if (p.y != 0) {
				motion.vy = 0;
				
				if (p.y > 0) {
					falling = false;			
				} else {
					jumping = false;
					falling = true; 
				}
				y -= p.y;
			}
		} else {
			falling = true;
		}
		
		aabb = getBounds();		
		aabb.height -= 2; /// this is to prevent floor/cieling snagging
		if (world.collideAabb( aabb, 0, cdata )) {
			p = CollisionData.getSmallest(cdata, p);
			if (p.x != 0) {
				motion.vx = 0;
				x -= p.x;
			}
		}
	}
	private var p:Vec2;
	
	
	override public function _render( camera:Camera ):Void 
	{
		 // set the draw position to be fixed to the bottom center
		mc.x = Math.round(x - camera.x);
		mc.y = Math.round(y - camera.y) - HEIGHT;
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
		_shape.graphics.drawRect(0, 0, WIDTH, HEIGHT);
		
		_madeVisible = true;
	}
	
	
}