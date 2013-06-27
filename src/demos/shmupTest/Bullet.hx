package demos.shmupTest;

import flash.display.Shape;

import sge.core.Engine;
import sge.core.Entity;
import sge.collision.AABB;
import sge.graphics.Camera;
import sge.math.Motion;

/**
 * ...
 * @author fidgetwidget
 */
class Bullet extends Entity
{

	static var BULLET_SPEED :Int = 320;
	
	private var _shape		: Shape;
	private var _aabb		: AABB;
	private var _radius		: Float = 3;
	private var madeVisible	: Bool = false;

	public function new() 
	{		
		super();
		className = Type.getClassName(Bullet);
		
		_visible = true;
		_active = true;
		state = Entity.DYNAMIC;
		_shape = new Shape();
		mc = _shape;
		
		_aabb = new AABB();
		_aabb.set_centerHalfs(0, 0, _radius, _radius * 2);
	}
	
	override private function _updateTransform(delta:Float):Void 
	{
		super._updateTransform(delta);
	}
	
	override public function _render( camera:Camera ) : Void 
	{	
		_aabb.cx = ix;
		_aabb.cy = iy;
		mc.x = (ix - camera.ix); // add the paralax offset
		mc.y = (iy - camera.iy);
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
		_shape.graphics.lineStyle( 2, 0x00FF00 );
		_shape.graphics.moveTo(0, 0);
		_shape.graphics.lineTo(0, -_radius);		
		
		madeVisible = true;
	}
	
	private function _initMotion() : Void
	{
		if (_m == null) {
			_m = new Motion();
		}
		_m.vy = -BULLET_SPEED;
		_m.fx = 0;
		_m.fy = 0;
	}
	
	
	public static function makeBullet( x:Float, y:Float ) :Bullet
	{
		var bullet:Bullet = Engine.getEntity( Bullet );
		bullet.x = x;
		bullet.y = y;
		bullet._initMotion();
		bullet.makeVisible();
		return bullet;
	}
	
}