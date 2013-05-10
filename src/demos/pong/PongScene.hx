package demos.pong;

import nme.display.Sprite;
import nme.geom.Point;
import nme.ui.Keyboard;
import sge.core.Camera;
import sge.core.Engine;
import sge.core.EntityManager;
import sge.core.Scene;
import sge.core.Entity;
import sge.graphics.Atlas;
import sge.graphics.Draw;
import sge.io.Input;
import sge.physics.AABB;
import sge.physics.CollisionData;
import sge.physics.Physics;
import sge.random.Rand;

/**
 * ...
 * @author fidgetwidget
 */
class PongScene extends Scene
{
	
	static inline var MOVESPEED:Float = 5000;
	static inline var PADDLEFRICTION:Float = 0.1;

	var WIDTH:Int;
	var HEIGHT:Int;
	
	var screenBounds:AABB;
	var cdata:CollisionData;
	var paddle1:Paddle;
	var paddle2:Paddle;
	var ball:Ball;
	var aabb:AABB;
	var aabb1:AABB;
	var aabb2:AABB;
	var paused:Bool;
	
	var oldPos:Point;
	var mc:Sprite;
	
	public function new() 
	{
		super();
		atlas = new Atlas();
		id = "PongScene";
		
		WIDTH = cast(Engine.properties.get("_STAGE_WIDTH"), Int);
		HEIGHT = cast(Engine.properties.get("_STAGE_HEIGHT"), Int);
		
		paddle1 = new Paddle();
		paddle2 = new Paddle();
		ball = new Ball();
		oldPos = new Point();
		entities = new EntityManager();
		camera = new Camera();
		mc = atlas.makeLayer(0);
		screenBounds = new AABB();
		screenBounds.setRect( 
		 (WIDTH - 512) * 0.5, 
		 (HEIGHT - 512) * 0.5, 
		 512, 512);
		paused = false;
	}
	
	override public function ready():Void 
	{
		super.ready();		
		
		cdata = Physics.getCollisionData();
		camera.width = 800;
		camera.height = 600;
		camera.x = 0;
		camera.y = 0;
		
		var centerY:Float = 512 * 0.5;
		
		paddle1.x = screenBounds.left + 50;
		paddle2.x = screenBounds.right - 50;
		paddle1.y = screenBounds.cy;
		paddle2.y = screenBounds.cy;
		paddle1.motion.vf = paddle2.motion.vf = PADDLEFRICTION;
		
		resetBall();
		
		add(paddle1);
		mc.addChild(paddle1.mc);
		add(paddle2);
		mc.addChild(paddle2.mc);
		add(ball);
		mc.addChild(ball.mc);
	}
	
	override public function render():Void 
	{
		Draw.graphics.beginFill(0xcccccc, 0.4);
		Draw.debug_drawAABB(screenBounds, camera);
		Draw.graphics.endFill();
		super.render();
	}
	
	override private function _handleInput(delta:Float):Void 
	{
		if ( Input.isKeyPressed( Keyboard.SPACE ) ) {
			paused = !paused;
		}
		
		if (paused) { return; }
		
		if ( Input.isKeyPressed( Keyboard.R ) ) {
			resetBall();
		}
		
		if ( Input.isKeyDown( Keyboard.UP ) ) {
			paddle2.motion.vy -= MOVESPEED * delta;
		} 
		else 
		if ( Input.isKeyDown( Keyboard.DOWN) ) {
			paddle2.motion.vy += MOVESPEED * delta;
		}
		
		if ( Input.isKeyDown( Keyboard.W ) ) {
			paddle1.motion.vy -= MOVESPEED * delta;
		} 
		else 
		if ( Input.isKeyDown( Keyboard.S ) ) {
			paddle1.motion.vy += MOVESPEED * delta;
		}
		
		if ( Input.isKeyDown( Keyboard.SHIFT ) ) {
			
			if ( Input.isKeyDown( Keyboard.LEFT ) ||
			Input.isKeyDown( Keyboard.A ) ) {
				ball.motion.vx -= 6.8;
			}
			else
			if ( Input.isKeyDown( Keyboard.RIGHT ) ||
			Input.isKeyDown( Keyboard.D ) ) {
				ball.motion.vx += 6.8;
			}
			
		}
		
	}
	
	override private function _update(delta:Float):Void 
	{
		if (paused) { return; }
		
		paddle1.update(delta);
		paddle2.update(delta);
		oldPos.x = ball.x;
		oldPos.y = ball.y;
		ball.update(delta);
		
		aabb1 = paddle1.collider.getBounds();
		aabb2 = paddle2.collider.getBounds();
		if ( aabb1.top < screenBounds.top || 
		 aabb1.bottom > screenBounds.bottom ) {
			paddle1.motion.vy *= -0.5;
			if ( aabb1.top < screenBounds.top ) {
				paddle1.y = screenBounds.top + aabb1.hHeight;
			} else {
				paddle1.y = screenBounds.bottom - aabb1.hHeight;
			}
		}
		
		if ( aabb2.top < screenBounds.top || 
		 aabb2.bottom > screenBounds.bottom ) {
			paddle2.motion.vy *= -0.5;
			if ( aabb2.top < screenBounds.top ) {
				paddle2.y = screenBounds.top + aabb2.hHeight;
			} else {
				paddle2.y = screenBounds.bottom - aabb2.hHeight;
			}
		}
		
		if ( aabb1.intersectsLine(oldPos.x, oldPos.y, ball.x, ball.y) ||
		 aabb2.intersectsLine(oldPos.x, oldPos.y, ball.x, ball.y) ||
		 aabb1.containsPoint(ball.x, ball.y) ||
		 aabb2.containsPoint(ball.x, ball.y) ) {
			
			if (aabb1.intersectsLine(oldPos.x, oldPos.y, ball.x, ball.y)) {
				ball.x = aabb1.right + 6;
				if (ball.y > aabb1.center.y) {
					ball.motion.vy -= 10;
				} else {
					ball.motion.vy += 10;
				}
			} else {
				if (ball.y > aabb2.center.y) {
					ball.motion.vy -= 10;
				} else {
					ball.motion.vy += 10;
				}
				ball.x = aabb2.left - 6;
			}
			ball.motion.vx *= -1;
			ball.motion.v.scale( 1.1 );
		}
		
		// Ball Hits top or bottom
		if ( ball.y < screenBounds.top || 
		 ball.y > screenBounds.bottom ) {
			ball.motion.vy *= -1;
			if (ball.y < screenBounds.top) {
				ball.y = screenBounds.top + 6;
			} else {
				ball.y = screenBounds.bottom - 6;
			}
		}
		
		// Ball Hits sides (reset)
		if ( ball.x < screenBounds.left || ball.x > screenBounds.right ) {
			resetBall();
		}
		
		camera.update( delta );
	}
	
	private function resetBall() :Void 
	{
		ball.x = screenBounds.center.x;
		ball.y = screenBounds.center.y;
		ball.motion.vf = 0;
		
		ball.motion.v.x = Rand.instance.between( -100, 100);
		ball.motion.v.y = Rand.instance.between( -100, 100);
		ball.motion.v.normalize();
		ball.motion.v.scale( 128);
		
	}
	
}