package demos.randomBodies;

import flash.display.Sprite;
import flash.ui.Keyboard;
import sge.collision.AABB;
import sge.collision.CollisionData;
import sge.core.Entity;
import sge.math.Vector2D;

import sge.core.Engine;
import sge.core.EntityTree;
import sge.core.Scene;
import sge.collision.CollisionMath;
import sge.graphics.Atlas;
import sge.graphics.Camera;
import sge.graphics.Draw;
import sge.io.Input;
import sge.math.Dice;
import sge.math.Random;

/**
 * Draw a number of basic shapes in a space, and allow dragging of the scene
 * @author fidgetwidget
 */
class TestScene extends Scene
{
	
	static var TREE_WIDTH:Int = 1024;
	static var TREE_HEIGHT:Int = 1024;
	
	static var SHAPE_COUNT:Int = 100;
	
	var drawQuads:Bool = false;
	var drawBounds:Bool = false;
	var paused:Bool = false;
	
	var tree:EntityTree;
	var localX:Float;
	var localY:Float;	
	var startX:Float;
	var startY:Float;
	var moveCamera:Bool = false;
	
	var mc:Sprite;
	var bg:Sprite;
	var mg:Sprite;
	var fg:Sprite;
	

	public function new() 
	{
		super();		
		id = "Test1";		
		atlas = new Atlas();
		
		// Setup the Entity Manager
		tree = new EntityTree(TREE_WIDTH, TREE_HEIGHT);
		entities = tree;
		
		// Setup the camera
		camera = new Camera();
		camera.width = cast(Engine.properties.getValue("_STAGE_WIDTH"), Int);
		camera.height = cast(Engine.properties.getValue("_STAGE_HEIGHT"), Int);
		camera.x = 0;
		camera.y = 0;
		
		camera.sceneBounds.width = TREE_WIDTH + camera.width;
		camera.sceneBounds.height = TREE_HEIGHT + camera.height;
		camera.sceneBounds.cx = TREE_WIDTH * 0.5;
		camera.sceneBounds.cy = TREE_HEIGHT * 0.5;		
	}
	
	
	override public function ready() : Void 
	{
		super.ready();
		
		mc = atlas.makeLayer(0);
		
		bg = atlas.makeLayer(1);
		mg = atlas.makeLayer(2);
		fg = atlas.makeLayer(3);
		
		var d:Int;
		var x:Float;
		var y:Float;
		var shape:ShapeEntity;
		var v:Vector2D;
		
		for (i in 0...SHAPE_COUNT) {
			d = Dice.rollSum();
			x = Random.instance.between( 90, TREE_WIDTH - 90 );
			y = Random.instance.between( 90, TREE_HEIGHT - 90 );
			shape = new ShapeEntity();
			shape.x = x;
			shape.y = y;
			v = Random.instance.randomDir();
			shape.motion.vx = v.x;
			shape.motion.vy = v.y;
			shape.motion.velocity.scale( Random.instance.between(10, 50) );
			add(shape);
			if (shape.transform.z < 0) {
				bg.addChild( shape.mc );
			} else
			if (shape.transform.z > 0) {
				fg.addChild( shape.mc );
			} else {
				mg.addChild( shape.mc );
			}
		}
		
	}
	
	
	override private function _handleInput(delta:Float) : Void 
	{
		/// Move the Camera by Dragging
		localX = Input.mouseX + camera.x;
		localY = Input.mouseY + camera.y;		

		if ( Input.isMouseDown() ) {
			
			if ( Input.isMousePressed() )
			{
				moveCamera = true;
				startX = localX;
				startY = localY;
			}
			
		} else {
			moveCamera = false;
		}		
		if ( moveCamera ) {
			camera.moveBy( startX - localX, startY - localY, 0.3 );
		}
		
		/// Switch Draw Modes
		#if (!js)
		if ( Input.isKeyPressed(Keyboard.NUMBER_1) ) {
			drawBounds = !drawBounds;
		} else
		if ( Input.isKeyPressed(Keyboard.NUMBER_2) ) {
			drawQuads = !drawQuads;
		}
		#end	
		
		if ( Input.isKeyPressed(Keyboard.P) ) {
			camera.shake(1);
		}
	}
	
	
	override private function _update( delta:Float ) : Void 
	{
		cdata = CollisionMath.getCollisionData();
		
		for (e in entities) {
			
			e.update( delta );
			
			_bounds = e.get_bounds();	
			smallestQuad = tree.getSmallestFit( _bounds );
			
			/// BLOCK COLLIDES WITH WALL
			if ( smallestQuad == null ) {
				
				// BOUNCE (a fiddly solution, but it works...)
				if (_bounds.left <= 0 || _bounds.right >= TREE_WIDTH) {
					e.x -= e.motion.vx * (delta * 2);
					e.motion.vx *= -1;
				} else
				if (_bounds.top <= 0 || _bounds.bottom >= TREE_HEIGHT) {
					e.y -= e.motion.vy * (delta * 2);
					e.motion.vy *= -1;
				}
				
			} else {
				
				// only update the tree's entity position if it won't throw an error...
				// kind of a bad way to handle it, but again, it works...
				if (e.motion.inMotion && e.state == Entity.DYNAMIC) {
					tree.updateEntityPosition(e);
				}
				
			}			
			
		} // end of for (e in entities)
		
		CollisionMath.freeCollisionData(cdata);	
	}
	private var smallestQuad:QuadNode;
	private var cdata:CollisionData;
	private var _bounds:AABB;
	
	
	override public function render() : Void 
	{		
		// draw the outer quad tree square
		Draw.graphics.beginFill(0xFFFFFF, 1);
		Draw.debug_drawAABB( tree.root, camera );
		Draw.graphics.endFill();
		
		for (e in tree) {
			// draw the entity
			e.render( camera );
			
			if (drawBounds) {
				_bounds = e.get_bounds();			
				Draw.graphics.lineStyle(1, 0x5566FF);
				Draw.debug_drawAABB( _bounds, camera );	
			}
			
			if (drawQuads) {
				// draw the quad that the entity is in (this is wasteful, as it will draw the same quad multiple times
				// when there are many entities in it... but this is just a demo)
				quad = tree.getNode( e );
				if (quad != null) {
					Draw.graphics.lineStyle(1, 0x5566FF);
					Draw.debug_drawAABB( quad, camera );
				}	
			}				
			
		}
		
		Draw.graphics.lineStyle(1, 0x000000 );
		Draw.debug_drawAABB( tree.root, camera );
	}
	private var quad:AABB;
	
}