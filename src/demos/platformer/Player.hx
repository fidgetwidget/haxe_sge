package demos.platformer;

import nme.display.Shape;
import nme.ui.Keyboard;

import sge.core.Camera;
import sge.core.Entity;
import sge.core.Engine;
import sge.graphics.Draw;
import sge.geom.Box;
import sge.io.Input;
import sge.physics.AABB;
import sge.physics.BoxCollider;
import sge.physics.CollisionData;
import sge.physics.Motion;
import sge.physics.CollisionMath;
import sge.physics.Vec2;
import sge.random.Random;
import sge.world.World;


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
	private static var SPEED:Float = 450;
	private static var RUN_SPEED:Float = 600;
	private static var CROUCH_SPEED:Float = 200;
	private static var JUMP_THRUST:Float = 3000;
	private static var FALL_SPEED:Float = 1000;
	private static var FALL_FRICTION:Float = 0.01;
	private static var WALK_FRICTION:Float = 0.0333;
	private static var RUN_FRICTION:Float = 0.025;
	private static var CROUCH_FRICTION:Float = 0.05;
	private static var WALL_FRICTION:Float = 0.06;
	
	/*
	 * Properties 
	 */	
	public var paused:Bool = true;
	public var jumping:Bool = false;
	public var falling:Bool = true;
	public var wall_jumping:Bool = false;
	public var crouching:Bool = false;
	public var on_wall:Bool = false;
	public var running:Bool = false;
	public var wall_side:Int = 0;
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
	private var cdata:CollisionData;

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
		
		on_wall = false;
		wall_side = 0;
		
		motion.fx = WALK_FRICTION;
		motion.fy = FALL_FRICTION;
		
	}
	
	override public function update(delta:Float):Void 
	{
		if (!active) { return; }
		
		_input( delta );
		_update( delta );		
		_updateTransform( delta );
		
		cdata = CollisionMath.getCollisionData();
		
		doWorldCollisions(world, cdata);
		
		CollisionMath.freeCollisionData(cdata);
	}
	
		
	override private function _input(delta:Float):Void 
	{
		if ( Input.isKeyDown(Keyboard.SHIFT) ) {
			running = true;
		} else {
			running = false;
		}
		
		if ( Input.isKeyPressed(Keyboard.W) || Input.isKeyPressed(Keyboard.UP) ) {
			if (!jumping && !falling) {
				jumpspeed = JUMP_THRUST;
				cur_jumpTime = 0;
				jumping = true;	
			} else
			if (on_wall) {
				motion.vx += JUMP_THRUST * 0.1 * -wall_side;
				motion.vy = 0; // start from 0
				jumpspeed = JUMP_THRUST;
				cur_jumpTime = 0;
				jumping = true;
				wall_jumping = true;
				on_wall = false;
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
		
		if ( Input.isKeyDown(Keyboard.A) || Input.isKeyDown(Keyboard.LEFT) ) {
			// unstick from wall
			if (on_wall && wall_side > 0) {
				on_wall = false;
				x -= 1;
			}
			// move
			if (crouching && !jumping) {
				motion.vx -= CROUCH_SPEED * delta;
			} else
			if (running) {
				motion.vx -= RUN_SPEED * delta;
			} else {
				motion.vx -= SPEED * delta;
			}
		}
		else
		if ( Input.isKeyDown(Keyboard.D) || Input.isKeyDown(Keyboard.RIGHT) ) {
			// unstick from wall
			if (on_wall && wall_side < 0) {
				on_wall = false;
				x += 1;
			}
			// move
			if (crouching && !jumping && !running) {
				motion.vx += CROUCH_SPEED * delta;
			} else
			if (running && !crouching) {
				motion.vx += RUN_SPEED * delta;
			} else {
				motion.vx += SPEED * delta;
			}
		}
		
		
		
		
	}

	override private function _update( delta:Float ):Void 
	{		
		// jumping/falling 
		if (jumping && jumpspeed > 0) {
			cur_jumpTime += delta;
			jumpspeed -= FALL_SPEED * cur_jumpTime;
			// jumping motion
			motion.vy -= jumpspeed * delta;
		} else { 
			wall_jumping = false;
			jumping = false; 
		}				
		
		if (falling) {			
			// falling motion
			if (on_wall && motion.vy > 0 && !crouching) {
				// when on the wall (and not crouching), fall slower
				motion.vy += FALL_SPEED * delta * 0.33;
			} else {
				motion.vy += FALL_SPEED * delta;
			}
		}
		
		
		// state managed bounding box
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
		
		// state managed friction
		if (on_wall) {
			motion.fy = WALL_FRICTION;
		} else {
			motion.fy = FALL_FRICTION;
		}
		
		if (crouching && !jumping && !running) {
			motion.fx = CROUCH_FRICTION;
		} else
		if (running && !crouching) {
			motion.fx = RUN_FRICTION;
		} else {
			motion.fx = WALK_FRICTION;
		}
		
		
	}	
	
	public function doWorldCollisions( world:World, cdata:CollisionData ) :Void {
		if (p == null) {
			p = new Vec2();
		}
		p.x = 0;
		p.y = 0;
		
		if ( Math.abs(motion.vx) > Math.abs(motion.vy) || falling ) {
			collideVertical( world, cdata );
			collideHorizontal( world, cdata );
		} else {			
			collideHorizontal( world, cdata );
			collideVertical( world, cdata );
		}
		
	}
	private var p:Vec2;
	private var aabb:AABB;
	
	private function collideVertical( world:World, cdata:CollisionData ) :Void 
	{
		aabb = getBounds();
		aabb.width -= 2; /// this is to prevent snagging
		
		// do top/bottom collision
		if (world.collideAabb( aabb, 0, cdata )) {
			p = CollisionData.getSmallest(cdata, p);			
			if (p.y != 0) {
				motion.vy = 0;
				
				if (p.y > 0) {
					falling = false;
					// prevent on wall and on ground at the same time
					if (on_wall) {				
						on_wall = false;
						wall_side = 0;
					}
				} else {
					// if we hit our head, set falling to true (but keep jumping)
					falling = true; 
				}
				y -= p.y;
			}			
		} else {
			falling = true;
		}
	}
	
	private function collideHorizontal( world:World, cdata:CollisionData ) :Void 
	{
		aabb = getBounds();	
		aabb.height -= 2; /// this is to prevent snagging
		
		if (world.collideAabb( aabb, 0, cdata )) {
			p = CollisionData.getSmallest(cdata, p);
			if (p.x != 0) {
				motion.vx = 0;
				on_wall = true;
				if (p.x < 0) {
					wall_side = -1;
				} else
				if (p.x > 0) {
					wall_side = 1;
				}
				x -= p.x;
			}
		}
	}
	
	override public function _render( camera:Camera ):Void 
	{
		 // set the draw position to be fixed to the bottom center
		mc.x = x - camera.x;
		mc.y = y - camera.y - HEIGHT;
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