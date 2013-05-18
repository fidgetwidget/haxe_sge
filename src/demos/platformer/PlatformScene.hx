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

	static inline var WIDTH:Int = 4096;
	static inline var HEIGHT:Int = 4096;
	
	/*
	 * Members
	 */	
	private var localX:Float;
	private var localY:Float;
	private var cdata:CollisionData;	
	private var mouseDrag:Bool = false;
	private var dragX:Float;
	private var dragY:Float;
	
	private var grid:EntityGrid;
	private var world:World;
	private var _currTileType:Int = 1;
	private var mc:Sprite;
	
	private var player:Player;
	private var _playerPaused:Bool = true;
	
	
	public function new() 
	{		
		
		super();
		atlas = new Atlas();
		id = "PlatformScene";
		
		var rows:Int = Math.floor( HEIGHT / World.cell_height );
		var cols:Int = Math.floor( WIDTH / World.cell_width  );
		camera = new Camera();
		world = new World(rows, cols);
		player = new Player();
		grid = new EntityGrid(WIDTH, HEIGHT, World.cell_width, World.cell_height);
		entities = grid;
		mc = atlas.makeLayer(0);
		
		var tileData = new TileData();
		world.loadAssets(tileData);
		
		camera.width = cast(Engine.properties.get("_STAGE_WIDTH"), Int);
		camera.height = cast(Engine.properties.get("_STAGE_HEIGHT"), Int);
		camera.x = 0;
		camera.y = 0;
		camera.sceneBounds.width = WIDTH + camera.width;
		camera.sceneBounds.height = HEIGHT + camera.height;
		camera.sceneBounds.cx = WIDTH * 0.5;
		camera.sceneBounds.cy = HEIGHT * 0.5;
		camera.motion = new Motion();
		camera.motion.vf = 3.8;
		
		player.x = 100;
		player.y = 100;
		player.world = world;
		add(player);
		mc.addChild(player.mc);
		
#if (!js) 
		Debug.registerVariable(camera, "x", "cam_x", true);
		Debug.registerVariable(camera, "y", "cam_y", true);
		
		Debug.registerVariable(player, "x", "player_x", true);
		Debug.registerVariable(player, "y", "player_y", true);
 
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
		cdata = CollisionMath.getCollisionData();
		camera.update(delta);
		
		if (!_playerPaused) {
			
			player.update(delta);
			//player.doWorldCollisions(world, cdata);		
			
		}
		
		CollisionMath.freeCollisionData(cdata);
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