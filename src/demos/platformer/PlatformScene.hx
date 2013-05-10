package demos.platformer;

import nme.geom.Point;
import nme.ui.Keyboard;

import sge.core.Camera;
import sge.core.Engine;
import sge.core.Scene;
import sge.core.Entity;
import sge.graphics.Draw;
import sge.io.Input;
import sge.lib.World;
import sge.physics.AABB;
import sge.physics.CollisionData;
import sge.physics.Physics;
import sge.physics.Motion;
import sge.random.Rand;

#if (!js) 
import sge.core.Debug;
#end

/**
 * ...
 * @author fidgetwidget
 */

class PlatformScene extends Scene
{	

	static inline var WIDTH:Int = 16384;
	static inline var HEIGHT:Int = 16384;
	
	var localX:Float;
	var localY:Float;
	
	var mouseDrag:Bool = false;
	var dragX:Float;
	var dragY:Float;
	
	//var gd:Grid<Entity>; // the grid of entities
	//var egh:IntHash<List<Int>>; // the entity id -> grid id's hash map
	var world:World;	
	var worldBounds:AABB;
	var currTileType:Int = 1;
	
	public function new() 
	{		
		var rows:Int = Math.floor( HEIGHT / World.tile_height );
		var cols:Int = Math.floor( WIDTH / World.tile_width  );
		
		super();
		
		id = "PlatformScene";
		//gd = new Grid<Entity>(WIDTH, HEIGHT, rows, cols);
		//egh = new IntHash<List<Int>>();
		
		camera = new Camera();
		world = new World(rows, cols);
		
		world.loadAssets();
		
		var stage = Engine.root.stage;
		camera.width = 800;
		camera.height = 800;
		
		var centerX:Float = WIDTH * 0.5;
		var centerY:Float = HEIGHT * 0.5;
		
		camera.sceneBounds.width = WIDTH + camera.width;
		camera.sceneBounds.height = HEIGHT + camera.height;
		camera.sceneBounds.cx = centerX;
		camera.sceneBounds.cy = centerY;
		
		camera.x = 0;
		camera.y = 0;
		camera.motion = new Motion();
		camera.motion.vf = 3.8;
		
#if (!js) 
		Debug.registerVariable(camera, "x", "cam_x", true);
		Debug.registerVariable(camera, "y", "cam_y", true);
 
		Debug.registerFunction(this, "getRow", "row", true);
		Debug.registerFunction(this, "getCol", "col", true);
		Debug.registerFunction(this, "getChunkRow", "c_row", true);
		Debug.registerFunction(this, "getChunkCol", "c_col", true);
#end
	}
	
	
	override public function ready():Void 
	{
		super.ready();
	}
	
	
	override private function _handleInput(delta:Float):Void 
	{
		localX = Input.mouseX + camera.x;
		localY = Input.mouseY + camera.y;
		
		
		if ( Input.isKeyDown(Keyboard.W) || Input.isKeyDown(Keyboard.UP) ) {
			camera.cy -= 256 * delta;
		} 
		else
		if ( Input.isKeyDown(Keyboard.S) || Input.isKeyDown(Keyboard.DOWN) ) {
			camera.cy += 256 * delta;
		}		
		if ( Input.isKeyDown(Keyboard.A) || Input.isKeyDown(Keyboard.LEFT) ) {
			camera.cx -= 256 * delta;
		}
		else
		if ( Input.isKeyDown(Keyboard.D) || Input.isKeyDown(Keyboard.RIGHT) ) {
			camera.cx += 256 * delta;
		}
		
		if ( Input.isMouseDown() ) {
			
			if ( !Input.isKeyDown( Keyboard.SPACE ) ) {
				world.setTileAt(localX, localY, currTileType);
			}
		}
		
		if ( Input.isKeyPressed(Keyboard.O) ) {
			currTileType--;
			if (currTileType < 0) {
				currTileType = World.tile_type_count - 1;
			}
		} else
		if ( Input.isKeyPressed(Keyboard.P) ) {
			currTileType++;
			if (currTileType >= World.tile_type_count) {
				currTileType = 0;
			}
		}
		
		if ( Input.isKeyDown( Keyboard.SPACE) && Input.isMousePressed() ) {
			mouseDrag = true;
			dragX = localX;
			dragY = localY;
		}
		if ( Input.isKeyReleased( Keyboard.SPACE ) || Input.isMouseReleased() ) {
			mouseDrag = false;
		}
		
		if (mouseDrag) {
			camera.moveBy( dragX - localX, dragY - localY, 0.3 );
		}
	}
	
	override private function _update(delta:Float):Void 
	{
		camera.update(delta);
		
	}
	
	
	override public function render():Void 
	{
		//Draw.graphics.beginFill(0xCCCCCC, 0.3);
		//Draw.debug_drawAABB( gd, camera );
		//Draw.graphics.endFill();
		
		world.render(camera);			
		
		if ( !Input.isKeyDown( Keyboard.SPACE ) ) {
			world.drawCursorTile(localX, localY, currTileType, camera);
		}
		
		
		world.drawDebug(camera);
		
	}
	
	
	
	/*
	 * Entity Manager functions
	 */
	
	override public function add(e:Entity):Void 
	{
		super.add(e);
		//egh.set(e.id, gd.insert( e ));
	}
	
	override public function remove(e:Entity, ?free:Bool = true):Bool 
	{
		//egh.remove(e.id);
		return super.remove(e, free);
	}
	
	function getRow() :Int {
		return world.get_row( Input.mouseY + camera.y );
	}
	function getCol() :Int {
		return world.get_col( Input.mouseX + camera.x );
	}
	
	function getChunkRow() :Int {
		return world.get_region_row( Input.mouseY + camera.y );
	}
	function getChunkCol() :Int {
		return world.get_region_col( Input.mouseX + camera.x );
	}
	
}