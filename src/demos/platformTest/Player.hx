package demos.platformTest;

import flash.display.Shape;
import flash.ui.Keyboard;

import sge.core.Entity;
import sge.core.Engine;
import sge.collision.AABB;
import sge.collision.BoxCollider;
import sge.collision.CollisionData;
import sge.collision.CollisionMath;
import sge.graphics.Camera;
import sge.graphics.Draw;
import sge.geom.Box;
import sge.io.Input;
import sge.math.Motion;
import sge.math.Vector2D;
import sge.math.Random;
import sge.world.World;


/**
 * ...
 * @author ...
 */
class Player extends Entity
{
	
	private static var WIDTH:Int = 10;
	private static var HEIGHT:Int = 24;	
	private static var WALLGRAB_HEIGHT:Int = 20;
	private static var CROUCH_HEIGHT:Int = 16;
	private static var SPEED:Float = 450;
	private static var RUN_SPEED:Float = 600;
	private static var CROUCH_SPEED:Float = 200;
	private static var JUMP_THRUST:Float = 2280; /// 2280:2 tiles | 2560:3 tiles | 2800:4 tiles  
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
	public var wall_slide:Bool = false;
	public var crouching:Bool = false;
	public var on_wall:Bool = false;
	public var running:Bool = false;
	public var wall_side:Int = 0;
	public var on_ledge:Bool = false;
	public var world:World;
	
	/*
	 * Members
	 */
	private var jumpspeed:Float;
	private var cur_jumpTime:Float = 0;
	private var updateShape:Bool = false;	
	private var _madeVisible:Bool = false;
	private var _shape:Shape;
	private var _box:Box;
	private var _boxCollider:BoxCollider;
	private var cdata:CollisionData;
	
	// Memory Savers
	private var p:Vector2D;
	private var aabb:AABB;
	private var tests:Int = 0;
	private var MAX_TESTS:Int = 3;

	public function new() 
	{
		super();
		className = Type.getClassName(Player);
		
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
		on_ledge = false;
		
		motion.fx = WALK_FRICTION;
		motion.fy = FALL_FRICTION;
		p = new Vector2D();
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
		
		
		// Press Up (or space) for jumping
		if ( Input.isKeyPressed(Keyboard.W) || Input.isKeyPressed(Keyboard.UP) || Input.isKeyPressed(Keyboard.SPACE) ) {
			if (!jumping && !falling) {
				jumpspeed = JUMP_THRUST;
				cur_jumpTime = 0;
				jumping = true;	
			} else
			if (on_wall && on_ledge) {
				jumpspeed = JUMP_THRUST;
				cur_jumpTime = 0;
				jumping = true;	
				wall_jumping = true;
				on_wall = false;
				on_ledge = false;
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
		if ( !Input.isKeyDown(Keyboard.W) && !Input.isKeyDown(Keyboard.UP) && !Input.isKeyDown(Keyboard.SPACE) ) {
			jumping = false;
			jumpspeed = 0;
		} 
		
		// Down/Crouching
		if ( Input.isKeyDown(Keyboard.S) || Input.isKeyDown(Keyboard.DOWN) ) {	
			
			// Pressing down when on a ledge has us let go of the ledge
			if (on_wall && on_ledge) {
				if (wall_side > 0) {
					on_wall = false;
					x -= 1;
				} else
				if (wall_side < 0) {
					on_wall = false;
					x += 1;
				}
			} else 
			if (on_wall) {
				wall_slide = true;
			} else {			
				crouching = true;
				crouching_released = false;
				wall_slide = false;
			}
			
		} else {
			
			// check if this is when crouch is released
			if (crouching) {
				crouching_released = true;
			} else {
				crouching_released = false;
			}			
			
			wall_slide = false;
			crouching = false;
		}
		
		// Left & Right Movement (don't support both left & right keys at the same time)
		if ( Input.isKeyDown(Keyboard.A) || Input.isKeyDown(Keyboard.LEFT) ) {
			
			// unstick from wall if we are on a wall to the right
			if (on_wall && wall_side > 0) {
				on_wall = false;
				x -= 1;
			}
			
			// move
			if (crouching && !jumping && !running) {
				motion.vx -= CROUCH_SPEED * delta;
			} else
			if (running && !crouching) {
				motion.vx -= RUN_SPEED * delta;
			} else {
				motion.vx -= SPEED * delta;
			}
			
		}
		else
		if ( Input.isKeyDown(Keyboard.D) || Input.isKeyDown(Keyboard.RIGHT) ) {
			
			// unstick from wall if we are on a wall to the left
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
		
		if (on_wall && on_ledge && motion.vy >= 0) {
			if (!jumping && !crouching) {
				motion.vy = 0;
			}
		}
		
		if (falling) {
			// falling motion
			if (on_wall && motion.vy > 0 && !wall_slide && !on_ledge) {
				// when on the wall (and not crouching), fall slower
				motion.vy += FALL_SPEED * delta * 0.33;
			} else 
			if (!on_ledge || (on_ledge && wall_slide) ) {
				motion.vy += FALL_SPEED * delta;
			}
		}
		
		// state managed bounding box
		if (crouching) {
			_box.height = CROUCH_HEIGHT;
			_box.y = -CROUCH_HEIGHT * 0.5;
		} else 
		if (on_wall && motion.vy >= 0) {
			_box.height = WALLGRAB_HEIGHT;
			_box.y = -WALLGRAB_HEIGHT * 0.5;
		} else {
			_box.height = HEIGHT;
			_box.y = -HEIGHT * 0.5;
		}
		
		// Special Case: release crouching when you would hit your head - force crouching to prevent crazy collisions
		// NOTE: there is a bug that has you move at walking speed while crouched in this special case...
		if (crouching_released) {
			aabb = get_bounds();
			if (world.collideAabb(aabb)) {
				// test if crouching would not collide
				_box.height = CROUCH_HEIGHT;
				_box.y = -CROUCH_HEIGHT * 0.5;
				aabb = get_bounds();
				if (!world.collideAabb(aabb)) {
					crouching = true;
				} else {
					_box.height = HEIGHT;
					_box.y = -HEIGHT * 0.5;
				}
			} else {
				_box.height = HEIGHT;
				_box.y = -HEIGHT * 0.5;
			}
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
	var crouching_released:Bool = false;
	
	public function doWorldCollisions( world:World, cdata:CollisionData ) :Void 
	{
		p.x = 0;
		p.y = 0;
		
		// test for world(tile) collisions & resolve them
		_collideWorld( world, cdata );	
		
		// update wall and ground checks
		on_wall = wallCheck() && motion.vy >= 0;
		on_ledge = ledgeCheck();
		falling = !floorCheck();
		
	}	
	
	private function _collideWorld( world:World, cdata:CollisionData ) :Void 
	{
		aabb = get_bounds();
		tests = 0;
		while (world.collideAabb( aabb, 0, cdata ) && tests < MAX_TESTS) {
			
			p = CollisionData.getSmallest(cdata, p);
			
			// Resolve the collision (smallest first)
			if ( p.y != 0 && ( (Math.abs(p.y) < Math.abs(p.x)) || p.x == 0 ) ) {
				motion.vy = 0;				
				if (p.y < 0) {
					// if we hit our head, set falling to true (but keep jumping)
					falling = true;
				}
				y -= p.y;
				#if (debug)
				trace("py = " + p.y);
				#end
			} else 
			if ( p.x != 0 && ( (Math.abs(p.x) < Math.abs(p.y)) || p.y == 0 ) ) {
				motion.vx = 0;
				x -= p.x;	
				#if (debug)
				trace("px = " + p.x);
				#end
			}	
			// get new bounds for next test			
			aabb = get_bounds();
			// update for fallback exit (prevent infinite looping)
			tests++;
		}
		
	}	
	
	override public function _render( camera:Camera ):Void 
	{		
		// set the draw position to be fixed to the bottom center
		//mc.x = x - camera.x;
		//mc.y = y - camera.y - HEIGHT;
		// don't draw the shape right now, the bounding box is better
		mc.x = -1000;
		mc.y = -1000;
		
		aabb = get_bounds();
		
		Draw.graphics.lineStyle(1, 0x2332CF);
		Draw.debug_drawAABB(aabb, camera);
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
		aabb = get_bounds();
		_shape.graphics.clear();		
		_shape.graphics.lineStyle(1, 0x2332CF);
		_shape.graphics.drawRect(0, 0, _box.width, _box.height);
		
		_madeVisible = true;
	}
	
	
	// TODO: make the wall and floor check private
	
	public function wallCheck( exitOnFloorTests:Bool = true ) :Bool {
		
		aabb = get_bounds();		
		// prevent on wall in the corner scenarios
		if (exitOnFloorTests && world.collidePoint(aabb.cx, aabb.bottom + 1)) {
			return false;
		}
		
		// check middle first
		if (world.collidePoint(aabb.left - 1, aabb.cy)) {
			wall_side = -1;
			return true;
		} else
		if (world.collidePoint(aabb.right + 1, aabb.cy)) {
			wall_side = 1;
			return true;
		}		
		
		return false;
	}
	
	public function ledgeCheck() :Bool {
		aabb = get_bounds();
		
		if (world.collidePoint(aabb.right + 1, aabb.cy) || 
		world.collidePoint(aabb.left - 1, aabb.cy)) {
			if (world.collidePoint(aabb.right + 1, aabb.top) ||
			world.collidePoint(aabb.left - 1, aabb.top)) {
				return false;
			} else {
				return true;
			}
		}
		return false;
	}
	
	public function floorCheck() :Bool {
		
		aabb = get_bounds();		
		// check center first (will be true in most true cases)
		if (world.collidePoint(aabb.cx, aabb.bottom + 1)) {
			return true;
		}
		// then check near the sides
		if (world.collidePoint(aabb.left + 0.5, aabb.bottom + 1) ||
		world.collidePoint(aabb.right - 0.5, aabb.bottom + 1)) {
			return true;
		}
		
		// we aren't on the ground
		return false;
	}
	
	
}