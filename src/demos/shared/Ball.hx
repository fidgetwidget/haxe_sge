package demos.shared;

import nme.display.Shape;
import nme.display.Graphics;
import sge.geom.Circle;

import sge.core.Camera;
import sge.core.Entity;
import sge.graphics.Draw;
import sge.physics.CircleCollider;
import sge.physics.Motion;

/**
 * ...
 * @author fidgetwidget
 */
class Ball extends Entity
{
	
	/**
	 * Properties
	 */
	public var RADIUS:Int;
	public var COLOR:Int;
	public var FRICTION:Int = 0;
	
	/*
	 * Members
	 */
	private var _shape:Shape;
	private var _circle:Circle;
	private var _circleCollider:CircleCollider;
	private var madeVisible:Bool = false;

	public function new() 
	{
		super();
		className = Type.getClassName(Ball);
		_circle = new Circle(0, 0, RADIUS);
		_circleCollider= new CircleCollider(_circle, this);
		collider = _circleCollider;
		_visible = true;
		_active = true;
		_m = new Motion();
		_m.vf = FRICTION;
		state = Entity.DYNAMIC;
		_shape = new Shape();
		mc = _shape;
	}	
	
	override private function _render( camera:Camera ):Void 
	{
		_shape.x = x - camera.x;
		_shape.y = y - camera.y;
	}
	
	override private function get_visible():Bool 
	{
		if (_visible && !madeVisible) { makeVisible(); }
		if (!_visible) { _shape.graphics.clear(); }
		return _visible;
	}
	
	private function makeVisible() :Void {
		
		if (mc == null) { return; }		
		if (_shape.graphics == null) { return; }
		_shape.graphics.clear();
		_shape.graphics.beginFill(COLOR);
		_shape.graphics.drawCircle(0,0,_circle.radius);
		_shape.graphics.endFill();
		madeVisible = true;
	}
	
}