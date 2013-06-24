package demos.shmupTest;

import flash.display.Sprite;
import flash.ui.Keyboard;
import sge.collision.AABB;
import sge.collision.CollisionData;
import sge.collision.CollisionMath;
import sge.core.Entity;
import sge.core.EntityManager;
import sge.core.Engine;
import sge.core.EntityTree;
import sge.core.Scene;
import sge.graphics.Atlas;
import sge.graphics.Camera;
import sge.graphics.Draw;
import sge.io.Input;
import sge.math.Vector2D;
import sge.math.Dice;
import sge.math.Random;
import sge.geom.Path;

/**
 * Draw a number of basic shapes in a space, and allow dragging of the scene
 * @author fidgetwidget
 */
class TestScene extends Scene
{
	
	static var TREE_WIDTH:Int = 1200;
	static var TREE_HEIGHT:Int = 1200;
	static var SHOT_DELAY:Float = 0.33;
	static var SPAWN_DELAY:Float = 1;
	static var STAR_COUNT:Int = 500;
	
	static var LEFT_LIMIT:Int = 300;
	static var RIGHT_LIMIT:Int = 900;
	
	var drawQuads:Bool = false;
	var drawBounds:Bool = false;
	var paused:Bool = false;
	
	var localX:Float;
	var localY:Float;	
	
	var tree:EntityTree;
	
	var player:Player;
	var stars:List<Star>;
	var bullets:List<Bullet>;
	var shotDelay:Float;
	var spawnDelay:Float;
	
	var mc:Sprite;
	var bg:Sprite;
	var mg:Sprite;
	var fg:Sprite;
	

	public function new() 
	{
		super();		
		id = "ShmupTest";		
		atlas = new Atlas();
		
		// Setup the Entity Manager
		tree = new EntityTree(TREE_WIDTH, TREE_HEIGHT);
		entities = tree;
		stars = new List<Star>();
		bullets = new List<Bullet>();
		
		// Setup the camera
		camera = new Camera();
		camera.width = cast(Engine.properties.getValue("_STAGE_WIDTH"), Int);
		camera.height = cast(Engine.properties.getValue("_STAGE_HEIGHT"), Int);
		camera.x = 0;
		camera.y = 0;
		
		camera.sceneBounds.width = (TREE_WIDTH * 0.33) + camera.width;
		camera.sceneBounds.height = camera.height;
		camera.sceneBounds.cx = TREE_WIDTH * 0.5;
		camera.sceneBounds.cy = TREE_HEIGHT * 0.5;	
		
		camera.cx = TREE_WIDTH * 0.5;
		camera.cy = TREE_HEIGHT * 0.5;
	}
	
	
	override public function ready() : Void 
	{
		super.ready();
		
		mc = atlas.makeLayer(0);
		
		bg = atlas.makeLayer(1);
		mg = atlas.makeLayer(2);
		fg = atlas.makeLayer(3);	
		
		player = new Player();
		player.x = camera.cx;
		player.y = camera.y + camera.height - 50;
		add( player );
		mg.addChild( player.mc );
		
		while (stars.length < STAR_COUNT * 0.5) {		
			var x = Random.instance.between(tree.root.left + 10, tree.root.right - 10);
			var y = Random.instance.between(tree.root.top + 10, tree.root.bottom - 10);
			var z = Random.instance.between(25, 50) * 0.01;
			var star = Star.makeStar(x, y, -z);
			stars.add(star);
			add(star);
			bg.addChild( star.mc );
		}	
		
	}
	
	
	override private function _handleInput(delta:Float) : Void 
	{
		
		localX = Input.mouseX + camera.x;
		localY = Input.mouseY + camera.y;
		
		if ( Input.isMouseDown() || Input.isKeyDown( Keyboard.SPACE ) ) {
			shoot();
		}
		
	}	
	
	override private function _update( delta:Float ) : Void 
	{
		var i = 0;
		while (stars.length < STAR_COUNT && i++ < 1) {		
			var x = Random.instance.between(tree.root.left + 10, tree.root.right - 10);
			var y = tree.root.top + 10;
			var z = Random.instance.between(25, 50) * 0.01;
			var star = Star.makeStar(x, y, -z);
			stars.add(star);
			add(star);
			bg.addChild( star.mc );
		}
		
		if (shotDelay > 0) {
			shotDelay -= delta;
		}
		
		if (spawnDelay > 0) {
			spawnDelay -= delta;
		} else {
			spawnDelay = SPAWN_DELAY;
			spawn();
		}
		
		
		cdata = CollisionMath.getCollisionData();
		
		for (e in entities) {
			
			if (e == null) { continue; }
			
			e.update( delta );
			_bounds = e.get_bounds();
			quad = tree.getSmallestFit( _bounds );
			
			if (quad == null) {
				
				if (e.className == Type.getClassName(Star)) {
					stars.remove(cast(e, Star));
					bg.removeChild(e.mc);
				} else 
				if (e.className == Type.getClassName(Bullet)) {
					bullets.remove(cast(e, Bullet));
					fg.removeChild(e.mc);
				} else
				if (e.className == Type.getClassName(Enemy)) {
					fg.removeChild(e.mc);
				}				
				remove(e, true);
				
			} else {
				
				tree.updateEntityPosition(e);
				
				if (e.className == Type.getClassName(Enemy)) {
					
					for (b in bullets) {
						if (_bounds.containsPoint(b.x, b.y)) {
							
							camera.shake();
							
							if (cast(e, Enemy).hit()) {
								
								fg.removeChild(e.mc);
								remove(e, true);
								
							}
							
							fg.removeChild(b.mc);
							bullets.remove(cast(b, Bullet));
							remove(b, true);
							
						}
					}
					
				}
				
			}
			
		}
		
		CollisionMath.freeCollisionData(cdata);	
		
		if (player.x < LEFT_LIMIT) {
			player.x = LEFT_LIMIT;
			player.motion.vx *= -1;
		}
		if (player.x > RIGHT_LIMIT) {
			player.x = RIGHT_LIMIT;
			player.motion.vx *= -1;
		}
		camera.cx = player.x;
	}
	private var smallestQuad:QuadNode;
	private var cdata:CollisionData;
	private var _bounds:AABB;
	private var _bounds2:AABB;
	
	
	override public function render() : Void 
	{			
		
		Draw.graphics.beginFill(0x111111, 1);
		Draw.debug_drawAABB( tree.root, camera );
		Draw.graphics.endFill();
		
		for (e in tree) {
			// draw the entity
			e.render( camera );	
		}
		
		// Draw the Players Barriers
		Draw.graphics.lineStyle(1, 0xFF0000);
		Draw.graphics.moveTo( LEFT_LIMIT - player.SIZE - camera.x, 0 - camera.y);
		Draw.graphics.lineTo( LEFT_LIMIT - player.SIZE - camera.x, TREE_HEIGHT - camera.y);
		Draw.graphics.moveTo(RIGHT_LIMIT + player.SIZE - camera.x, 0 - camera.y);
		Draw.graphics.lineTo(RIGHT_LIMIT + player.SIZE - camera.x, TREE_HEIGHT - camera.y);
		Draw.graphics.endFill();
	}
	private var quad:QuadNode;
	
	
	private function shoot() :Void {
		if (shotDelay > 0) { return; }
		shotDelay = SHOT_DELAY;
		var bullet:Bullet = Bullet.makeBullet( player.x, player.y - player.SIZE );
		bullets.add(bullet);
		add(bullet);
		fg.addChild( bullet.mc );
	}
	
	private function spawn() :Void {
		var x = Random.instance.between(LEFT_LIMIT + 10, RIGHT_LIMIT - 10);
		var y = camera.bounds.top - 10;
		
		var enemy:Enemy = Enemy.makeEnemy( x, y );
		add(enemy);
		fg.addChild( enemy.mc );
	}
	
}