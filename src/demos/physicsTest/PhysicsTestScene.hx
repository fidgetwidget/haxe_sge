package demos.physicsTest;

import haxe.FastList;
import haxe.Timer;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.errors.Error;
import nme.geom.Point;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.ui.Keyboard;
import sge.core.EntityManager;
import sge.core.EntityTree;
import sge.graphics.Atlas;

import sge.core.Camera;
import sge.core.Entity;
import sge.core.Scene;
import sge.random.Rand;
import sge.geom.Path;
import sge.physics.AABB;
import sge.physics.CircleCollider;
import sge.physics.CollisionData;
import sge.physics.Physics;
import sge.physics.Vec2;
import sge.geom.SplineSegment;
import sge.core.Engine;
import sge.io.Input;
import sge.geom.Box;
import sge.graphics.Draw;

using sge.physics.Vec2;

#if (!js)
import sge.core.Debug;
#end

/**
 * Temporary catch all scene for testing in...
 * 
 * @author fidgetwidget
 */

class PhysicsTestScene extends Scene
{
	
	static var TREE_WIDTH:Int = 1024;
	static var TREE_HEIGHT:Int = 1024;
	
	// TODO: switch to using the EntityTree EntityManager over manually handling the quad tree
	
	var tree:EntityTree;
	/*
	 * Properties 
	 */
	
	var drawQuads:FastList<Box>;
	var player:Player;
	var blocks:Array<Block>;
	var path:Path;
	
	var centerX:Float;
	var centerY:Float;
	var mc:Sprite;
	
	var showQuads:Bool = true;
	var dontRender:Bool = false;
	var drawingPlayerPath:Bool = false;
	var blockCollisions:Bool = false;

	public function new() 
	{
		super();
		atlas = new Atlas();
		id = "DemoScene";
		
		camera = new Camera();
		player = new Player();
		tree = new EntityTree(TREE_WIDTH, TREE_HEIGHT, 8);
		entities = tree;
		blocks = new Array<Block>();
		path = new Path();
		ev = new Vec2();
		ev2 = new Vec2();
		drawQuads = new FastList<Box>();
		
		mc = atlas.makeLayer(0);
		
		camera.width = cast(Engine.properties.get("_STAGE_WIDTH"), Int);
		camera.height = cast(Engine.properties.get("_STAGE_HEIGHT"), Int);
		camera.x = 0;
		camera.y = 0;
		
		#if (!js)
		//Debug.registerVariable(camera, "x", "camera_x", true);
		//Debug.registerVariable(camera, "y", "camera_y", true);		
		//Debug.registerVariable(player, "x", "player_x", true);
		//Debug.registerVariable(player, "y", "player_y", true);
		#end
	}	
	
	override public function free():Void 
	{
		super.free();
		// TODO: free up everything else...
	}
	
	override public function ready():Void 
	{
		super.ready();	
		
		centerX = tree.root.hWidth;
		centerY = tree.root.hHeight;
		
		player.x = centerX;
		player.y = centerY;
		
		add(player);
		mc.addChild(player.mc);
		
		camera.followTarget( player.transform.position );
	}
	
	override private function _handleInput(delta:Float):Void 
	{
		localX = Input.mouseX + camera.x;
		localY = Input.mouseY + camera.y;
		
		if ( Input.isKeyDown( Keyboard.SHIFT ) && Input.isMouseDown() ) {
			
			
			if ( tree.containsPoint( localX, localY ) &&
			(player.collider.contains( localX, localY ) ||
			 drawingPlayerPath) ) {				
				
				drawingPlayerPath = true;	
				if (player.path.getLast() != null) 
					player.path.getLast().toPoint(point);
				
				if (point == null) {
					player.addPathPoint( player.transform.position.clone() );
				}
				else 
				if (player.collider.contains( localX, localY )) {
					// don't add a point if we are still in collision space with the player
				}
				else {
					var p = new Point( localX, localY );
					var distance:Float = Physics.distanceBetween_points(point, p);
					if (distance >= player.radius) {
						player.addPathPoint( p );
					}
				}
				
			}
			else 
			if (!drawingPlayerPath) {
				path.getLast().toPoint(point);
				if (point == null) {
					path.add_Point( Input.getMousePoint().clone() );
				}
				else {
					var distance:Float = Physics.distanceBetween_points(point, Input.getMousePoint());
					if (distance >= 16) {
						path.add_Point( Input.getMousePoint().clone() );
					}
				}	
			}			
			
		}
		else
		if ( Input.isMousePressed() && Input.isKeyDown( Keyboard.CONTROL )  ) {
			
			if ( tree.containsPoint( localX, localY ) ) {				
				block = Block.makeBlock( localX, localY );
				_bounds = block.getBounds();
				if ( tree.intersectsAabb( _bounds ) ) {
					blocks.push( block );
					mc.addChild(block.mc);
					add( block );
				}
			}
			
		}
		else
		if ( Input.isMouseDown() && !Input.isKeyDown( Keyboard.CONTROL ) ) 
		{	
			if ( player.collider.contains( localX, localY ) ) {
				
			}
			else
			if ( tree.containsPoint( localX, localY ) ) {				
				block = Block.makeBlock( localX, localY );
				_bounds = block.getBounds();
				if (tree.intersectsAabb( _bounds )) {
					blocks.push( block );
					mc.addChild(block.mc);
					add( block );
				}
			}
		}
		
#if !html5
		
		if ( Input.isKeyPressed( Keyboard.LEFTBRACKET ) ) {
			player.radius += 1;
			cast(player.collider, CircleCollider).radius += 1;
		} 
		else 
		if ( Input.isKeyPressed( Keyboard.RIGHTBRACKET ) ) {
			player.radius -= 1;
			cast(player.collider, CircleCollider).radius -= 1;	
		}
		
#end		
		
		if ( Input.isKeyReleased( Keyboard.SHIFT ) ) {
			path.clear();
			drawingPlayerPath = false;
		} 
		else
		if ( Input.isKeyUp( Keyboard.SHIFT ) &&
		!player.hasPath) {
			player.path.clear();
		}
		
		if ( Input.isKeyPressed(Keyboard.SPACE) ) {
			showQuads = !showQuads;
		}
		
		if ( Input.isKeyPressed(Keyboard.NUMPAD_DECIMAL) ) {
			dontRender = !dontRender;
		}
	}
	
	override private function _update( delta:Float ):Void 
	{
		
		for (e in entities) {
			
			e.update( delta );
			
			cdata = Physics.getCollisionData();
			_bounds = e.getBounds();
			
			if (e.className == Type.getClassName(Player)) {
				
				/// PLAYER COLLIDES WITH THE WALLS
				smallestQuad = tree.getSmallestFit( _bounds );
				if ( smallestQuad == null &&
				tree.intersectsAabb( _bounds ) ) {
					
					player.collider.collideAABB(tree.root, cdata);
					if (cdata.px > cdata.py) {
						player.motion.vy *= -0.9;
						player.y = Math.floor(player.y + player.radius > tree.root.bottom ? tree.root.bottom - player.radius - 1 : tree.root.top + player.radius);
					} else {
						player.motion.vx *= -0.9;
						player.x = Math.floor(player.x + player.radius > tree.root.right ? tree.root.right - player.radius - 1 : tree.root.left + player.radius + 1);
					}
				}	
				
			}
			else
			{
				smallestQuad = tree.getSmallestFit( _bounds );
				
				/// BLOCK COLLIDES WITH WALL
				if ( smallestQuad == null ) {
					
					if (e.className == "Block") {
						var block:Block = cast(e, Block);
						blocks.remove( block );
					}
					mc.removeChild(e.mc);
					remove(e, true); // this will "free" the item
			
				} else {
					
					if (blockCollisions) {
						/// BLOCK COLLIDES WITH BLOCK
						if ( e.motion.inMotion ) {
							for ( e2 in smallestQuad.iterator() ) {
								if (e2.className == Type.getClassName(Player)) { continue; }
								
								if ( e.collider.collideAABB( e2.collider.getBounds() , cdata) ) {
									if (cdata.px > cdata.py) {
										e.y += (cdata.py * cdata.oV) * 0.5;
										e2.y -= (cdata.py * cdata.oV) * 0.5;
									} else {
										e.x += (cdata.px * cdata.oH) * 0.5;
										e2.x -= (cdata.px * cdata.oH) * 0.5;
									}
									cdata.dv.scale( 0.5 );
									e.motion.v.add(cdata.dv);
									e2.motion.v.subtract(cdata.dv);
								}
							}	
						}					
					}
					/// BLOCK COLLIDES WITH PLAYER	
					playerBounds = player.getBounds();
					smallestQuad = tree.getSmallestFit( playerBounds );					
					if ( smallestQuad != null &&
					smallestQuad.intersectsAabb( _bounds ) ) {
						
						if ( player.collider.collideAABB( _bounds, cdata ) ) {
							if (cdata.px > cdata.py) {
								e.y += cdata.py * cdata.oV;
							} else {
								e.x += cdata.px * cdata.oH;
							}
							e.motion.v.add( cdata.dv );
						}
						
					}
				}
			}
				
			if (e.motion.inMotion && e.state == Entity.DYNAMIC) {
				tree.updateEntityPosition(e);
			}	
			
		} // end of for (e in entities)
		
		camera.update( delta );
		
	}
	
	override public function render():Void 
	{	
		if (dontRender) { return; }		
		
		// draw the outer quad tree square
		Draw.graphics.beginFill(0xCCCCCC, 0.3);
		Draw.debug_drawAABB( tree.root, camera );
		Draw.graphics.endFill();		

		for (e in tree.root.iterator() ) {
			drawEntity( e );
		}
		
		// draw the path		
		if (path.length > 1) {
			Draw.graphics.lineStyle(2, 0x992255);
			path.render( camera, Draw.graphics );
		}
	}
	
	private function drawEntity( e:Entity ) :Void {
		Draw.graphics.lineStyle(0, 0x00000);
		e.render( camera );
		
		if (showQuads) {
			quad = tree.getNode( e );
			if (quad != null) {
				Draw.graphics.lineStyle(1, 0x5566FF);
				Draw.debug_drawAABB( quad, camera );
			}	
		}
	}
	
	override private function _exit():Void 
	{
		
	}
	
	private var ev:Vec2;
	private var ev2:Vec2;
	private var dp:Float;
	private var cdata:CollisionData;
	private var playerBounds:AABB;
	private var smallestQuad:QuadNode;
	private var quad:AABB;	
	private var block:Block;
	private var point:Point;
	private var localX:Float;
	private var localY:Float;
	
	private var _bounds:AABB;
	private var _quad:QuadNode;
	
}