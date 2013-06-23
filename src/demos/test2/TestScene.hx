package demos.test2;

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
import sge.collision.CollisionData;
import sge.graphics.Atlas;
import sge.graphics.Camera;
import sge.graphics.Draw;
import sge.io.Input;
import sge.math.Dice;
import sge.math.Random;

/**
 * ...
 * @author fidgetwidget
 */
class TestScene extends Scene
{
	
	static var TREE_WIDTH:Int = 1024;
	static var TREE_HEIGHT:Int = 1024;
	
	var drawQuads:Bool = false;
	var drawBounds:Bool = false;
	var paused:Bool = false;
	
	var tree:EntityTree;
	var localX:Float;
	var localY:Float;	
	var startX:Float;
	var startY:Float;
	var moveCamera:Bool = false;
	
	var followplayer:Bool = true;
	
	var player:Player;
	var _playerBounds:AABB;
	
	var mc:Sprite;
	

	public function new() 
	{
		super();		
		id = "Test2";		
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
		camera.cx = TREE_WIDTH * 0.5;
		camera.cy = TREE_HEIGHT * 0.5;
		
		player = new Player();
		player.x = TREE_WIDTH * 0.5;
		player.y = TREE_HEIGHT * 0.5;
	}
	
	
	override public function ready() : Void 
	{
		super.ready();
		
		mc = atlas.makeLayer(0);
		
		add( player );
		mc.addChild( player.mc );
		
	}
	
	
	override private function _handleInput(delta:Float) : Void 
	{		
		/// Move the Camera by Dragging
		localX = Input.mouseX + camera.x;
		localY = Input.mouseY + camera.y;		

		if ( Input.isMouseDown() && Input.isKeyDown( Keyboard.SPACE ) ) {
			
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
		
		if ( Input.isMouseDown() && !Input.isKeyDown( Keyboard.SPACE ) ) {
			
			// if we can, add a block at the cursor position
			if (tree.containsPoint(localX, localY)) {
				
				var block:Block;
				if ( Input.isKeyDown( Keyboard.CONTROL ) ) {
					block = Block.makeBlock( localX, localY, false );
				} else {
					block = Block.makeBlock( localX, localY );
				}
				_bounds = block.get_bounds();
				if (tree.containsAabb( _bounds )) {
					
					add( block );
					mc.addChild( block.mc );
					
				} else {
					
					Engine.free( block );
					
				}
				
			}
			
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
		
		if ( Input.isKeyPressed( Keyboard.F ) ) {
			followplayer = !followplayer;
		}
	}
	
	
	override private function _update( delta:Float ) : Void 
	{
		cdata = CollisionMath.getCollisionData();
		
		for (e in entities) {
			
			e.update( delta );
			_bounds = e.get_bounds();
			
			if (e.className == Type.getClassName(Player)) {
				
				/// PLAYER COLLIDES WITH THE WALLS
				smallestQuad = tree.getSmallestFit( _bounds );
				if ( smallestQuad == null && tree.intersectsAabb( _bounds ) ) {
					
					player.collider.collideAABB(tree.root, cdata);
					if (cdata.px > cdata.py) {
						player.motion.vy *= -0.9;
						player.y = Math.floor(player.y + player.SIZE > tree.root.bottom ? tree.root.bottom - player.SIZE - 1 : tree.root.top + player.SIZE);
					} else {
						player.motion.vx *= -0.9;
						player.x = Math.floor(player.x + player.SIZE > tree.root.right ? tree.root.right - player.SIZE - 1 : tree.root.left + player.SIZE + 1);
					}
					
				} else {
					if (e.motion.inMotion && e.state == Entity.DYNAMIC) {
						tree.updateEntityPosition(e);
					}
				}
				
			}
			else 
			{				
				
				/// BLOCK COLLIDES WITH WALL
				smallestQuad = tree.getSmallestFit( _bounds );
				if ( smallestQuad == null ) {
					
					mc.removeChild( e.mc );
					remove( e, true );
					camera.shake();
					
				} else {
					
					// only update the tree's entity position if it won't throw an error...
					// kind of a bad way to handle it, but again, it works...
					if (e.motion.inMotion && e.state == Entity.DYNAMIC) {
						tree.updateEntityPosition(e);
					}
					
					/// BLOCK COLLIDES WITH PLAYER	
					_playerBounds = player.get_bounds();
					smallestQuad = tree.getSmallestFit( _playerBounds );
					
					// test if the quad the player is in collides with the entities bounds
					if ( smallestQuad != null && smallestQuad.intersectsAabb( _bounds ) ) {
						
						if ( player.collider.collide( e.collider, cdata ) ) {							
							e.y -= cdata.py * cdata.oV;
							e.x -= cdata.px * cdata.oH;
							// this is more or less an arbitrary collision response
							e.motion.vx -= cdata.dv.x * 0.33;
							e.motion.vy -= cdata.dv.y * 0.33;
						}
						
					}					
				}
				
			}	
			
		} // end of for (e in entities)
		
		CollisionMath.freeCollisionData(cdata);	
		
		if (followplayer) {
			camera.moveTo( player.x, player.y, 0 );			
		}
	}
	private var smallestQuad:QuadNode;
	private var cdata:CollisionData;
	private var _bounds:AABB;
	
	
	override public function render() : Void 
	{		
		// draw the outer quad tree square
		Draw.graphics.beginFill(0xFFFFFF, 1);
		Draw.graphics.lineStyle(1, 0x000000);
		Draw.debug_drawAABB( tree.root, camera );
		Draw.graphics.endFill();
		
		for (e in tree) {
			// draw the entity
			e.render( camera );
			
			if (drawBounds) {
				_bounds = e.get_bounds();			
				Draw.graphics.lineStyle(1, 0x5566FF);
				Draw.debug_drawAABB( _bounds, camera );	
				
				Draw.graphics.lineStyle(1, 0xFF0000);
				Draw.debug_drawVelocity(_bounds.cx, _bounds.cy, e.motion, 1, camera );
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
		
	}
	private var quad:AABB;
	
}