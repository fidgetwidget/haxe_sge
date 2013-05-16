package demos.cameraTest;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Linear;
import com.eclecticdesignstudio.motion.easing.Quad;
import nme.display.DisplayObjectContainer;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.geom.Point;
import nme.ui.Keyboard;
import sge.core.EntityGrid;
import sge.core.EntityManager;

import sge.core.Camera;
import sge.core.Entity;
import sge.core.Engine;
import sge.core.Scene;
import sge.geom.Path;
import sge.io.Input;
import sge.graphics.Draw;
import sge.graphics.Atlas;
import sge.physics.AABB;
import sge.physics.CollisionData;
import sge.physics.Motion;
import sge.physics.CollisionMath;
import sge.random.Random;

#if (!js)
import sge.core.Debug;
#end

/**
 * ...
 * @author fidgetwidget
 */

class CameraTestScene extends Scene
{		
	static var GRID_WIDTH:Int = 1024;
	static var GRID_HEIGHT:Int = 1024;
	
	static var BOX_COUNT:Int = 128;
	
	var grid:EntityGrid;
	
	/*
	 * Properties 
	 */
	var localX:Float;
	var localY:Float;
	var moveCamera:Bool = false;
	var startX:Float;
	var startY:Float;
	var drawingPath:Bool = false;
	
	var player:Player;
	var path:Path;
	var dontRender:Bool = false;
	
	var followPlayer:Bool = false;
	
	var blocks:Array<Block>;
	var aabb:AABB;
	var cdata:CollisionData;
	
	var targetType:Int;
	
	var bg:Sprite;
	var mg:Sprite;
	var fg:Sprite;
	
	public function new() 
	{			
		super ();		
		atlas = new Atlas();
		id = "FlightSpaceScene";
		
		camera = new Camera();
		player = new Player();
		grid = new EntityGrid(GRID_WIDTH, GRID_HEIGHT);
		entities = grid;
		blocks = new Array<Block>();
		cdata = CollisionMath.getCollisionData();
		
		targetType = Camera.TARGET_FIXED;
		bg = atlas.makeLayer(0);
		mg = atlas.makeLayer(1);
		fg = atlas.makeLayer(2);		
		
		var stage = Engine.root.stage;
		var centerX:Float = GRID_WIDTH * 0.5;
		var centerY:Float = GRID_HEIGHT * 0.5;
		
		camera.width = cast(Engine.properties.get("_STAGE_WIDTH"), Int);
		camera.height = cast(Engine.properties.get("_STAGE_HEIGHT"), Int);
		
		camera.sceneBounds.width = GRID_WIDTH + camera.width;
		camera.sceneBounds.height = GRID_HEIGHT + camera.height;
		camera.sceneBounds.cx = centerX;
		camera.sceneBounds.cy = centerY;
		
		camera.moveTo(centerX, centerY, 0);
		camera.motion = new Motion();
		camera.motion.vf = 0.05;
		
		player.x = centerX;
		player.y = centerY;
		player.camera = camera;
		add(player);
		
		mg.addChild(player.mc);
		
		for (i in 0...BOX_COUNT) {
			var block:Block = Block.makeBlock(Random.instance.between(30, GRID_WIDTH - 30), Random.instance.between(30, GRID_HEIGHT - 30));
			block.motion.vf = 0;
			block.motion.vx = Random.instance.between(-50, 50);
			block.motion.vy = Random.instance.between(-50, 50);
			blocks.push( block );
			add( block );
			if (block.transform.z == 0) {
				mg.addChild(block.mc);
			}
			else
			if (block.transform.z < 0) {
				fg.addChild(block.mc);
			}
			else {
				bg.addChild(block.mc);
			}
		}
		for (i in 0...12) {
			var block:Block = Block.makeBlock(Random.instance.between(0, GRID_WIDTH), Random.instance.between(0, GRID_HEIGHT), true);
			block.motion.vf = 0;
			block.motion.vx = Random.instance.between(-50, 50);
			block.motion.vy = Random.instance.between( -50, 50);
			blocks.push( block );
			add( block );
			mg.addChild(block.mc);
		}
		
#if (!js)
		Debug.registerVariable(camera.bounds, "left", "cam_left", true);
		Debug.registerVariable(camera.bounds, "right", "cam_right", true);
		Debug.registerVariable(camera.bounds, "top", "cam_top", true);
		Debug.registerVariable(camera.bounds, "bottom", "cam_bottom", true);
		
		Debug.registerVariable(camera.sceneBounds, "left", "scene_left", true);
		Debug.registerVariable(camera.sceneBounds, "right", "scene_right", true);
		Debug.registerVariable(camera.sceneBounds, "top", "scene_top", true);
		Debug.registerVariable(camera.sceneBounds, "bottom", "scene_bottom", true);
#end

	}
		
	override private function _handleInput(delta:Float):Void 
	{
		localX = Input.mouseX + camera.x;
		localY = Input.mouseY + camera.y;
		
#if (!js)
		if ( !Debug.on ) {
#end
		
			if ( Input.isKeyPressed( Keyboard.SPACE ) ) {
				camera.moveTo(GRID_WIDTH * 0.5, GRID_HEIGHT * 0.5, 0.3);
				followPlayer = false;
				camera.followTarget(null);
				moveCamera = false;
			}
			
			if ( Input.isKeyPressed( Keyboard.F ) ) {
				followPlayer = !followPlayer;				
				if (followPlayer) {
					camera.followTarget( player.transform.position, targetType );
				} 
				else {
					camera.followTarget(null);
				}				
				moveCamera = false;
			}
			
#if (!js)
			if ( Input.isKeyPressed( Keyboard.NUMBER_1 ) ) {			
				targetType = Camera.TARGET_FIXED;
				if (followPlayer) {
					camera.followTarget( player.transform.position, targetType );
				}
			}
			if ( Input.isKeyPressed( Keyboard.NUMBER_2 ) ) {		
				targetType = Camera.TARGET_CLOSE;
				if (followPlayer) {
					camera.followTarget( player.transform.position, targetType );
				}
			}
			if ( Input.isKeyPressed( Keyboard.NUMBER_3 ) ) {
				targetType = Camera.TARGET_LOOSE;
				if (followPlayer) {
					camera.followTarget( player.transform.position, targetType );
				}
			}
#end
			
#if (!js)	
		}
#end
		
		if ( Input.isKeyDown(Keyboard.W) || Input.isKeyDown(Keyboard.UP) ) {
			camera.motion.vy -= 28;
		} 
		else
		if ( Input.isKeyDown(Keyboard.S) || Input.isKeyDown(Keyboard.DOWN) ) {
			camera.motion.vy += 28;
		}		
		if ( Input.isKeyDown(Keyboard.A) || Input.isKeyDown(Keyboard.LEFT) ) {
			camera.motion.vx -= 28;
		}
		else
		if ( Input.isKeyDown(Keyboard.D) || Input.isKeyDown(Keyboard.RIGHT) ) {
			camera.motion.vx += 28;
		}
		
		if ( Input.isMouseReleased() ) {
			moveCamera = false;
			drawingPath = false;
		}
		
		if ( Input.isMouseDown() ) {
			
			if ( !moveCamera && grid.containsPoint(localX, localY) && (player.collider.contains( localX, localY ) || drawingPath) ) {				
				
				drawingPath = true;
				var point = player.path.getLast();
				
				if (point == null) {
					player.addPathPoint( player.transform.position.clone() );
				}
				else 
				if ( player.collider.contains( localX, localY ) ) {
					// don't add a point if we are still in collision space with the player
				}
				else {
					var p = new Point( localX, localY );
					var distance:Float = CollisionMath.distanceBetween_xy(point.x, point.y, p.x, p.y);
					if (distance >= player.radius) {
						player.addPathPoint( p );
					}
				}
			}
			else
			if ( Input.isMousePressed() )
			{
				moveCamera = true;
				startX = localX;
				startY = localY;
			}
		}
		
		if ( moveCamera && !drawingPath ) {
			camera.moveBy( startX - localX, startY - localY, 0.3 );
		}
	}
	
	override private function _update( delta:Float ):Void 
	{		
		for (e in entities) {
			
			e.update( delta );			
			aabb = e.getBounds();
			
			// bounce off the walls
			if ( !grid.containsAabb(aabb) ) {			
				if (e.y - aabb.hHeight < 0 || e.y + aabb.hHeight > GRID_HEIGHT) {
					e.motion.vy *= -1;
					if (e.y - aabb.hHeight < 0) {
						e.y = aabb.hHeight + 1;
					}
					else {
						e.y = GRID_HEIGHT - aabb.hHeight - 1;
					}
				} 
				else {
					e.motion.vx *= -1;
					if (e.x - aabb.hWidth < 0) {
						e.x = aabb.hWidth + 1;
					}
					else {
						e.x = GRID_WIDTH - aabb.hWidth - 1;
					}
				}
			}
			if (e.className != "Player" && e.transform.z == 0) {
				if (player.collider.collideAABB(aabb, cdata)) {
					if (cdata.px > cdata.py) {
						e.y += cdata.py * cdata.oV;					
					} 
					else {
						e.x += cdata.px * cdata.oH;
					}
					e.motion.vx += cdata.dv.x;
					e.motion.vy += cdata.dv.y;
				}	
			}
			
			grid.updateEntityPosition(e);
			
		}
		
		camera.update( delta );
		
		
	}
	
	override public function render():Void 
	{	
		if (dontRender) { return; }	
		
		// draw the grid square
		Draw.graphics.beginFill(0xCCCCCC, 0.3);
		Draw.debug_drawAABB( grid.getBounds(), camera );
		Draw.graphics.endFill();		
		Draw.graphics.lineStyle(0, 0x00000);
		
		for ( e in grid ) {
			e.render( camera );
		}		
	}
	
}