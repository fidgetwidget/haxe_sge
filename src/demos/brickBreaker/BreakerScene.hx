package demos.brickBreaker;

import nme.display.Sprite;
import nme.ui.Keyboard;

import sge.core.Camera;
import sge.core.Engine;
import sge.core.Entity;
import sge.core.EntityManager;
import sge.core.Scene;
import sge.graphics.Atlas;
import sge.graphics.Draw;
import sge.io.Input;
import sge.physics.AABB;
import sge.physics.CircleCollider;
import sge.physics.CollisionData;
import sge.physics.Physics;
import sge.random.Rand;

/**
 * ...
 * @author fidgetwidget
 */

class BreakerScene extends Scene
{
	static var WIDTH:Int = 512;
	static var HEIGHT:Int = 512;
	
	static var BRICK_HEIGHT:Int = 24;
	static var BRICK_WIDTH:Int = 48;
	
	static var BALLCONTROLE:Float = 0.25;
	
	static var GRID_XOFFSET:Int = 40;
	static var GRID_YOFFSET:Int = 40;
	
	var BRICK_ROWS:Int;
	var BRICK_COLS:Int;
	var GRID_WIDTH:Int;
	var GRID_HEIGHT:Int;
	
	var brickGrid:Array<Array<Brick>>;
	var player:Paddle;
	var ball:Ball;
	
	var mc:Sprite;
	
	var cdata:CollisionData;
	var aabb:AABB;
	
	var ballControleTime:Float = 0;
	

	public function new() 
	{
		super();
		atlas = new Atlas();
		id = "BreakerScene";
		
		camera = new Camera();
		entities = new EntityManager();
		brickGrid = new Array<Array<Brick>>();
		player = new Paddle();
		ball = new Ball();
		cdata = Physics.getCollisionData();
		mc = atlas.makeLayer(0);
		
		WIDTH = cast(Engine.properties.get("_STAGE_WIDTH"), Int);
		HEIGHT = cast(Engine.properties.get("_STAGE_HEIGHT"), Int);
		
		camera.width = WIDTH;
		camera.height = HEIGHT;
		camera.cx = WIDTH * 0.5;
		camera.cy = HEIGHT * 0.5;
		
		resetBall();
		resetPlayer();
		initBrickGrid();
		
		add(player);
		add(ball);
	}
	
	override public function ready():Void 
	{
		super.ready();		

		Engine.stage.addChild(mc);
		mc.addChild(player.mc);
		mc.addChild(ball.mc);
	}
	
	override private function _exit():Void 
	{
		Engine.stage.removeChild(mc);
	}
	
	override private function _handleInput(delta:Float):Void 
	{
		if ( Input.isKeyPressed( Keyboard.R ) ) {
			resetGame();
		}
		if ( Input.isKeyPressed( Keyboard.SPACE ) ) {
			resetBall();
			resetPlayer();
		}
		
		if ( Input.isKeyDown( Keyboard.A ) ) {
			player.motion.vx -= 3000 * delta;
			if (ballControleTime > 0) {
				ball.motion.vx -= 300 * delta;
			}
		} else if ( Input.isKeyDown( Keyboard.D ) ) {
			player.motion.vx += 3000 * delta;
			if (ballControleTime > 0) {
				ball.motion.vx += 300 * delta;
			}
		}
		
		if (ballControleTime > 0) {
			ballControleTime -= delta;
		}
	}
	
	override private function _update(delta:Float):Void 
	{
		player.update( delta );
		ball.update( delta );
		
		aabb = player.getBounds();
		if (aabb.left < 0 || aabb.right > WIDTH) {
			player.motion.vx *= -1;
			
			if (aabb.left < 0) {
				player.x = player.WIDTH * 0.5;				
			} else {
				player.x = WIDTH - player.WIDTH * 0.5;
			}
		}
		
		if (ball.collider.collideAABB(aabb)) {
			ball.y = player.y - player.HEIGHT * 0.5 - ball.RADIUS;
			ball.motion.vy *= -1;
			ball.motion.v.scale(1.1);
			ball.motion.vx += player.motion.vx * 0.5;
			ballControleTime = BALLCONTROLE;
		}
		
		aabb = ball.getBounds(); 
		if (aabb.left < 0 || aabb.right > WIDTH) {
			ball.motion.vx *= -1;
			if (aabb.left < 0) {
				ball.x = ball.RADIUS;
			} else {
				ball.x = WIDTH - ball.RADIUS;
			}
		} else 
		if (aabb.top < 0) {
			ball.motion.vy *= -1;
			ball.y = ball.RADIUS;
		} else 
		if (aabb.bottom > HEIGHT) {
			resetBall();
			resetPlayer();
		}
		
		if (ball.y < (brickGrid.length * BRICK_HEIGHT) + GRID_YOFFSET * 2) {
			var brick:Brick;
			var bounds:AABB;
			var cCollider = cast(ball.collider, CircleCollider);
			for (r in 0...BRICK_ROWS) {
				for (c in 0...BRICK_COLS) {
					brick = brickGrid[r][c];
					if (brick != null) {
						if (brick.collider.collide(ball.collider, cdata)) {
							mc.removeChild(brick.mc);
							remove(brick);
							brick.free();
							brickGrid[r][c] = null;
							if (cdata.px > cdata.py) {
								ball.y -= cdata.py * cdata.oV;
								ball.motion.vy *= -1;
							} else {
								ball.x -= cdata.px * cdata.oH;
								ball.motion.vx *= -1;
							}	
						}						
					}
				}
			}
			
		}
		
		camera.update( delta );
	}
	
	function resetGame() :Void {
		resetBall();
		resetPlayer();
		clearBrickGrid();
		initBrickGrid();
	}
	
	function clearBrickGrid() :Void {
		var brick:Brick;
		for (r in 0...BRICK_ROWS) {
			for (c in 0...BRICK_COLS) {
				brick = brickGrid[r][c];
				
				if (brick != null) {					
					remove(brick);
					mc.removeChild(brick.mc);
					brickGrid[r][c] = null;
				}
			}
		}
	}
	
	function initBrickGrid() :Void {
		var brick:Brick;
		GRID_WIDTH = (WIDTH - GRID_XOFFSET * 2);
		GRID_HEIGHT = Math.floor(HEIGHT * 0.5);
		BRICK_ROWS = Math.floor(GRID_HEIGHT / BRICK_HEIGHT);
		BRICK_COLS = Math.floor(GRID_WIDTH / BRICK_WIDTH);
		var x:Int;
		var y:Int;
		var make:Bool = false;
		
		for (r in 0...BRICK_ROWS) {
			if (brickGrid[r] == null) { brickGrid[r] = new Array<Brick>(); }
			
			for (c in 0...BRICK_COLS) {
				if (make) {
					x = c * BRICK_WIDTH + GRID_XOFFSET;
					y = r * BRICK_HEIGHT + GRID_YOFFSET;
					brick = Brick.make(x, y, BRICK_WIDTH, BRICK_HEIGHT);					
					add(brick);
					mc.addChild(brick.mc);
					brickGrid[r][c] = brick;
				}
			}
			make = !make;
		}
	}
	
	function resetBall() :Void {
		ball.x = WIDTH * 0.5;
		ball.y = HEIGHT * 0.5 + 64;
		ball.motion.vy = 1;
		ball.motion.vx = Rand.instance.between( -1, 1);
		ball.motion.v.normalize();
		ball.motion.v.scale(100);
	}
	function resetPlayer() :Void {
		player.x = WIDTH * 0.5;
		player.y = HEIGHT - 64;
		player.motion.vf = 0.05;
		player.motion.max_v = 120;
	}
	
	
}