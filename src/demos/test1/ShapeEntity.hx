package demos.test1;

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
	
	private var _geom		:sge.geom.Shape; // TWO Shape classes... hrm... maybe I should rename my Shape to Geom?
	private var _shape		:Shape;
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
		
		var dieRoll = Dice.rollSum(6, 1);
		
		if (dieRoll <= 2) {
			var poly = sge.geom.Shape.makePolygon( 0, 0, 15, Math.floor(Random.instance.between(5, 9)) );
			_geom = poly;
			collider = new PolygonCollider(poly, this);
		} else
		if (dieRoll <= 4) {
			var circle = sge.geom.Shape.makeCircle(0, 0, 15);
			_geom = circle;
			collider = new CircleCollider( circle, this );
		} else {
			var box = sge.geom.Shape.makeBox(0, 0, 30, 30);
			_geom = box;
			collider = new BoxCollider(box, this, false);				
		}
	}
	
	override public function _render( camera:Camera ) : Void 
	{		
		mc.x = (ix - camera.ix);
		mc.y = (iy - camera.iy);
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
		_shape.graphics.lineStyle( 1, 0xFF0000 );
		_geom.draw( _shape.graphics );
		
		madeVisible = true;
	}
}