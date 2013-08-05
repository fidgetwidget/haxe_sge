package demos.randomBodies;

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
class ShapeEntity extends Entity
{
	
	private var _aabb		:AABB;
	private var _geom		:sge.geom.Shape; // TWO Shape classes... hrm... maybe I should rename my Shape to Geom?
	private var _shape		:Shape;
	private var SIZE		:Float = 8;
	private var _isCircle	:Bool = false;
	private var _isBox		:Bool = false;
	private var _isPoly		:Bool = false;
	private var madeVisible	:Bool = false;

	public function new() 
	{
		super();
		className = Type.getClassName(ShapeEntity);
		
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
			collider = new PolygonCollider(poly, this);
			_isPoly = true;
			transform.z = -0.25;
		} else
		if (dieRoll < 4) {
			var circle = sge.geom.Shape.makeCircle(0, 0, SIZE);
			_geom = circle;
			collider = new CircleCollider( circle, this );
			_isCircle = true;
			transform.z = 0;
		} else {
			var box = sge.geom.Shape.makeBox(0, 0, SIZE * 2, SIZE * 2);
			_geom = box;
			collider = new BoxCollider(box, this, false);	
			_isBox = true;
			transform.z = 0.25;
		}
		
	}
	
	override public function _render( camera:Camera ) : Void 
	{		
		_aabb = get_bounds();
		mc.x = (_aabb.cx - camera.ix) - (transform.z * (camera.cx - _aabb.cx)); // add the paralax offset
		mc.y = (_aabb.cy - camera.iy) - (transform.z * (camera.cy - _aabb.cy));
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
			_shape.graphics.beginFill( 0x990000 );
		} else
		if (_isCircle) {
			_shape.graphics.beginFill( 0x009900 );
		} else
		if (_isPoly) {
			_shape.graphics.beginFill( 0x000099 );
		}
		
		_geom.draw( _shape.graphics );
		_shape.graphics.endFill();
		
		madeVisible = true;
	}
}