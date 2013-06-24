package demos.shmupTest;

import flash.display.Shape;
import sge.math.Dice;

import sge.collision.AABB;
import sge.core.Entity;
import sge.core.Engine;
import sge.graphics.Camera;
import sge.math.Motion;
import sge.math.Random;

/**
 * ...
 * @author fidgetwidget
 */
class Star extends Entity
{
	
	private var _shape		: Shape;
	private var _aabb		: AABB;
	private var _radius		: Float = 5;
	private var madeVisible	: Bool = false;

	public function new() 
	{		
		super();
		className = Type.getClassName(Star);
		
		_visible = true;
		_active = true;
		state = Entity.DYNAMIC;
		_shape = new Shape();
		mc = _shape;
		
		_aabb = new AABB();
		_aabb.set_centerHalfs(0, 0, _radius, _radius);
	}
	
	override private function _updateTransform(delta:Float):Void 
	{
		super._updateTransform(delta);
	}
	
	override public function _render( camera:Camera ) : Void 
	{	
		_aabb.cx = ix;
		_aabb.cy = iy;
		mc.x = (ix - camera.ix) - (transform.z * (camera.cx - x)); // add the paralax offset
		mc.y = (iy - camera.iy) - (transform.z * (camera.cy - y));
	}
	
	override private function get_visible() : Bool 
	{
		if (_visible && !madeVisible) { makeVisible(); }
		if (!_visible) { _shape.graphics.clear(); }
		return _visible;
	}
	
	override public function get_bounds():AABB 
	{
		_aabb.cx = ix;
		_aabb.cy = iy;
		return _aabb;
	}
	
	private function makeVisible() : Void 
	{		
		if (mc == null) { return; }		
		if (_shape.graphics == null) { return; }
		
		_shape.graphics.clear();
		if (Dice.rollSum() < 2) {
			_shape.graphics.lineStyle( 1, 0xFCDC3B );
		} else {
			_shape.graphics.lineStyle( 1, 0xCCCCCC );
		}
		_shape.graphics.moveTo(0, 0);
		_shape.graphics.lineTo(0, 1);
		
		madeVisible = true;
	}
	
	private function _initMotion() : Void
	{
		if (_m == null) {
			_m = new Motion();
		}
		_m.vy = Math.abs(500 * transform.z);
		_m.fx = 0;
		_m.fy = 0;
	}
	
	
	public static function makeStar( x:Float, y:Float, z ) :Star
	{
		var star:Star = Engine.getEntity( Star );
		star.x = x;
		star.y = y;
		star.transform.z = z;
		star._initMotion();
		star.makeVisible();
		return star;
	}
	
}