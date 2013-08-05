package demos.platformTest;

import etc.PauseScreen;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;
import openfl.display.Tilesheet;

import sge.collision.AABB;
import sge.core.Engine;
import sge.core.Entity;
import sge.core.EntityGrid;
import sge.core.EntityTree;
import sge.core.Scene;
import sge.geom.Shape;
import sge.graphics.AssetManager;
import sge.graphics.Atlas;
import sge.graphics.Camera;
import sge.graphics.Draw;
import sge.graphics.Tileset;
import sge.io.Input;
import sge.math.Dice;
import sge.math.Random;
import sge.world.World;

/**
 * ...
 * @author ...
 */
class TestScene extends Scene
{
	
	static var GRID_WIDTH:Int = 1024;
	static var GRID_HEIGHT:Int = 1024;
	
	var controlsTxtFld:TextField;
	var ps:PauseScreen;
	var grid:EntityGrid;
	var world:World;
	var bounds:AABB;
	var _entities:Array<Entity>;
	var player:Player;
	var paused:Bool = true;
	
	var localX:Float;
	var localY:Float;	
	var startX:Float;
	var startY:Float;
	var moveCamera:Bool = false;
	
	var mc:Sprite;
	var tileCursor:Int;
	
	
	public function new() 
	{
		super();		
		id = "PlatformTest";
		
		atlas = new Atlas();
		
		// Setup the Entity Manager
		grid = new EntityGrid(GRID_WIDTH, GRID_HEIGHT);
		entities = grid;
		
		world = new World(GRID_WIDTH, GRID_HEIGHT, 8, 8, Math.floor(GRID_WIDTH / 4), Math.floor(GRID_HEIGHT / 4) );
		var tileset = new Tileset( AssetManager.getBitmap("img/tiles.png") );
		tileset.init(8, 8, 12, 8);
		world.init( tileset ); // TODO: setup a tilesheet and use it here (instead of null)
		
		// Setup the camera
		camera = new Camera();
		camera.width = cast(Engine.properties.getValue("_STAGE_WIDTH"), Int);
		camera.height = cast(Engine.properties.getValue("_STAGE_HEIGHT"), Int);
		camera.x = 0;
		camera.y = 0;
		
		camera.sceneBounds.width = GRID_WIDTH + camera.width;
		camera.sceneBounds.height = GRID_HEIGHT + camera.height;
		camera.sceneBounds.cx = GRID_WIDTH * 0.5;
		camera.sceneBounds.cy = GRID_HEIGHT * 0.5;
		
		player = new Player();
		player.x = 100;
		player.y = 100;
		player.world = world;

		tileCursor = 2;
		ps = new PauseScreen( this );
		ps.text = "Paused\rPress 'P' to resume.";
		
		controlsTxtFld = new TextField();
		controlsTxtFld.defaultTextFormat = new TextFormat("_sans", 16, 0xEEEEEE);
		controlsTxtFld.text = "WASD movement, SPACE or W for jump, S for crouch.\rMouse Click to place tiles.";
		controlsTxtFld.width = controlsTxtFld.textWidth;
		controlsTxtFld.x = 0;
		controlsTxtFld.y = camera.height - controlsTxtFld.textHeight;
	}
	
	
	override public function ready():Void 
	{
		super.ready();
		
		mc = atlas.makeLayer(0);
		
		add( player );
		mc.addChild( player.mc );	
		
		if (paused) {
			ps.show();
			mc.addChildAt(controlsTxtFld, mc.numChildren);
		}		
	}
	
	override private function _update(delta:Float):Void 
	{
		if (!paused) {
			super._update(delta);
		}
		
		bounds = grid.get_bounds();
		if ( !bounds.containsAabb( player.get_bounds() ) ) {
			resetPlayer();
		}
		
		camera.moveTo( player.x, player.y, 0.3);
	}
	
	
	override private function _handleInput(delta:Float) : Void 
	{
		localX = Input.mouseX + camera.x;
		localY = Input.mouseY + camera.y;	
		
		if ( Input.isKeyPressed( Keyboard.P ) ) {
			paused = !paused;
			if (paused) {
				ps.show();
				mc.addChildAt(controlsTxtFld, mc.numChildren);
			} else {
				ps.hide();
				mc.removeChild(controlsTxtFld);
			}
		}
		
		
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
			world.makeTileAt(localX, localY, tileCursor);
		}
		
		if ( Input.isKeyPressed( Keyboard.R ) ) {
			resetPlayer();
		}
	}	
	
	override public function render() : Void 
	{
		
		bounds = grid.get_bounds();
		
		// draw the outer quad tree square
		Draw.graphics.beginFill(0xFFFFFF, 1);
		Draw.debug_drawAABB( bounds, camera );
		Draw.graphics.endFill();	
		
		world.render( camera );
		player.render( camera );
		
		world.drawCursorTile(localX, localY, tileCursor, camera);
		
		//bounds = camera.bounds;
		//grid.getEntities( bounds, _entities );
		//for ( e in _entities ) {
			//e.render( camera );
		//}
		
		Draw.graphics.lineStyle(1, 0xFF0000);
		Draw.debug_drawAABB( bounds, camera );
		
		if (paused) {			
			ps.render();
		}
	}
	
	
	private function resetPlayer() :Void 
	{
		player.x = 100;
		player.y = 100;
		player.motion.vx = 0;
		player.motion.vy = 0;
	}
}