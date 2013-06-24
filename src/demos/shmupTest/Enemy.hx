package demos.shmupTest;

import flash.Lib;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import sge.collision.BoxCollider;
import sge.collision.CircleCollider;
import sge.collision.PolygonCollider;
import sge.geom.Circle;
import sge.geom.Polygon;
import sge.math.Dice;

import sge.core.Engine;
import sge.core.Entity;
import sge.graphics.Camera;
import sge.graphics.Draw;
import sge.math.Random;
import sge.math.Motion;
import sge.collision.AABB;

/**
 * ...
 * @author fidgetwidget
 */
class Enemy extends Entity
{
	
	private var _aabb		:AABB;
	private var _geom		:sge.geom.Shape; // TWO Shape classes... hrm... maybe I should rename my Shape to Geom?
	private var _shape		:Shape;
	private var SIZE		:Float = 8;
	private var hits		:Int = 3;
	private var _isCircle	:Bool = false;
	private var _isBox		:Bool = false;
	private var _isPoly		:Bool = false;
	private var madeVisible	:Bool = false;

	public function new() 
	{
		super();
		className = Type.getClassName(Enemy);
		
		_visible = true;
		_active = true;
		state = Entity.DYNAMIC;
		
		_m = new Motion();
		_m.fx = 0;
		_m.fy = 0;
		_shape = new Shape();
		mc = _shape;
		
		var dieRoll = Dice.rollSum(); // 1d6
		
		if (dieRoll < 2) {
			var poly = sge.geom.Shape.makePolygon( 0, 0, SIZE, Math.floor(Random.instance.between(5, 9)) );
			_geom = poly;
			_isPoly = true;
		} else
		if (dieRoll < 4) {
			var circle = sge.geom.Shape.makeCircle(0, 0, SIZE);
			_geom = circle;
			_isCircle = true;
		} else {
			var box = sge.geom.Shape.makeBox(-SIZE, -SIZE, SIZE * 2, SIZE * 2);
			_geom = box;
			_isBox = true;
		}
		_aabb = new AABB();
		_aabb.set_centerHalfs(0, 0, SIZE, SIZE);
		
	}
	
	override public function _render( camera:Camera ) : Void 
	{		
		_aabb.cx = ix;
		_aabb.cy = iy;
		mc.x = (_aabb.cx - camera.ix); // add the paralax offset
		mc.y = (_aabb.cy - camera.iy);
	}
	
	override public function get_bounds():AABB 
	{
		_aabb.cx = ix;
		_aabb.cy = iy;
		return _aabb;
	}
	
	override private function get_visible() : Bool 
	{
		if (_visible && !madeVisible) { makeVisible(); }
		if (!_visible) { _shape.graphics.clear(); }
		return _visible;
	}
	
	private function makeVisible() : Void {
		
		if (mc == null) { return; }		
		if (_shape.graphics == null) { return; }
		
		_shape.graphics.clear();
		
		if (_isBox) {
			_shape.graphics.lineStyle( 1, 0xFF0000 );
			_shape.graphics.beginFill( 0x990000 );
		} else
		if (_isCircle) {
			_shape.graphics.lineStyle( 1, 0x00FF00 );
			_shape.graphics.beginFill( 0x009900 );
		} else
		if (_isPoly) {
			_shape.graphics.lineStyle( 1, 0x0000FF );
			_shape.graphics.beginFill( 0x000099 );
		}
		
		_geom.draw( _shape.graphics );
		_shape.graphics.endFill();
		
		madeVisible = true;
	}
	
	private function _initMotion() : Void
	{
		if (_m == null) {
			_m = new Motion();
		}
		
		_m.vy = 50;
		if (_isBox) {
			_m.vy = 80;
		} else
		if (_isCircle) {
			_m.vy = 50;
		} else 
		if (_isPoly) {
			_m.vy = 20;
		}
		
		_m.fx = 0;
		_m.fy = 0;
	}
	
	private function _initHealth() : Void 
	{
		hits = 3;
		if (_isBox) {
			hits = 2;
		} else
		if (_isCircle) {
			hits = 3;
		} else 
		if (_isPoly) {
			hits = 5;
		}
	}
	
	public function hit() :Bool
	{
		hits--;
		if (hits <= 0) {
			return true;
		}
		return false;
	}
	
	
	public static function makeEnemy( x:Float, y:Float ) :Enemy 
	{
		var enemy = Engine.getEntity( Enemy );
		enemy.x = x;
		enemy.y = y;
		enemy._initMotion();
		enemy._initHealth();
		enemy.makeVisible();
		return enemy;
	}
}