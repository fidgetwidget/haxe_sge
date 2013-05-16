package demos.platformer;

import nme.geom.Point;
import nme.ui.Keyboard;
import nme.display.Sprite;
import sge.lib.TileData;

import sge.core.EntityGrid;
import sge.graphics.Atlas;

import sge.core.Camera;
import sge.core.Engine;
import sge.core.Scene;
import sge.core.Entity;
import sge.graphics.Draw;
import sge.io.Input;
import sge.lib.World;
import sge.physics.AABB;
import sge.physics.CollisionData;
import sge.physics.CollisionMath;
import sge.physics.Motion;
import sge.random.Random;

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
	
	private var localX:Float;
	private var localY:Float;
	
	private var mouseDrag:Bool = false;
	private var dragX:Float;
	private var dragY:Float;
	
	private var grid:EntityGrid;
	private var world:World;
	private var worldBounds:AABB;
	private var cdata:CollisionData;
	
	private var mc:Sprite;
	
	private var player:Player;
	private var aabb:AABB;	
	private var _currTileType:Int = 1;
	private var _playerPaused:Bool = true;
	
	public function new() 
	{		
		var rows:Int = Math.floor( HEIGHT / World.cell_height );
		var cols:Int = Math.floor( WIDTH / World.cell_width  );
		
		super();
		atlas = new Atlas();
		id = "PlatformScene";
		
		camera = new Camera();
		world = new World(rows, cols);
		player = new Player();
		grid = new EntityGrid(WIDTH, HEIGHT, World.cell_width, World.cell_height);
		entities = grid;
		mc = atlas.makeLayer(0);
		
		var tileData = new TileData();
		world.loadAssets(tileData);
		
		var stage = Engine.root.stage;
		var centerX:Float = WIDTH * 0.5;
		var centerY:Float = HEIGHT * 0.5;
		
		camera.width = cast(Engine.properties.get("_STAGE_WIDTH"), Int);
		camera.height = cast(Engine.properties.get("_STAGE_HEIGHT"), Int);
		camera.x = 0;
		camera.y = 0;
		camera.sceneBounds.width = WIDTH + camera.width;
		camera.sceneBounds.height = HEIGHT + camera.height;
		camera.sceneBounds.cx = centerX;
		camera.sceneBounds.cy = centerY;
		camera.motion = new Motion();
		camera.motion.vf = 3.8;
		
		player.x = 100;
		player.y = 100;
		add(player);
		mc.addChild(player.mc);
		
		cdata = CollisionMath.getCollisionData();
		
#if (!js) 
		Debug.registerVariable(camera, "x", "cam_x", true);
		Debug.registerVariable(camera, "y", "cam_y", true);
		
		Debug.registerVariable(cdata, "px", "collider_px", true);
		Debug.registerVariable(cdata, "py", "collider_py", true);
 
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
		
		
		if ( Input.isMouseDown() ) {
			
			if ( !Input.isKeyDown( Keyboard.SPACE ) ) {
				world.setTileAt(localX, localY, _currTileType);
			}
		}
		
		if ( Input.isKeyPressed(Keyboard.LEFTBRACKET) ) {
			_currTileType--;
			if (_currTileType < 0) {
				_currTileType = World.tile_type_count - 1;
			}
		} else
		if ( Input.isKeyPressed(Keyboard.RIGHTBRACKET) ) {
			_currTileType++;
			if (_currTileType >= World.tile_type_count) {
				_currTileType = 0;
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
		
		if ( Input.isKeyPressed( Keyboard.P ) ) {
			_playerPaused = !_playerPaused;
			player.paused = _playerPaused;
		}
		
		if (_playerPaused) {
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
		}
		
	}
	
	override private function _update(delta:Float):Void 
	{
		camera.update(delta);
		
		if (!_playerPaused) {	
			
			aabb = player.getBounds();
			
			if ( world.collidePoint(aabb.center.x, aabb.bottom, 0, cdata) ) {
				player.motion.vy = 0;
				player.y -= cdata.py;
				player.falling = false;
			} else
			if ( world.collidePoint(aabb.center.x, aabb.top, 0, cdata) ) {
				player.motion.vy = 0;
				player.y += cdata.py;
				player.jumping = false;
				player.falling = true;
			}
			
			/// TODO: create a way to test one side at a time, and use that instead
			if ( world.collideAabb(aabb, 0, cdata) ) {
				if (cdata.px < cdata.py) {
					player.motion.vx = 0;
					player.x -= cdata.px * cdata.oH;
				}
			}
			
			player.update(delta);
		}
	}
	
	
	override public function render():Void 
	{
		Draw.graphics.beginFill(0xCCCCCC, 0.3);
		Draw.debug_drawAABB( grid.getBounds(), camera );
		Draw.graphics.endFill();
		
		world.render(camera);			
		
		if ( !Input.isKeyDown( Keyboard.SPACE ) ) {
			world.drawCursorTile(localX, localY, _currTileType, camera);
		}
		
		world.drawDebug(camera);
		player.render(camera);
		
		Draw.graphics.lineStyle(0.5, 0xff0000);
		Draw.debug_drawAABB( player.getBounds(), camera );
		
	}
	
	
	
	/*
	 * Helper Functions
	 */
	
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