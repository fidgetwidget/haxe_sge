package demos.shmupTest;

import flash.display.Shape;
import flash.ui.Keyboard;

import sge.collision.CircleCollider;
import sge.core.Entity;
import sge.geom.Circle;
import sge.graphics.Camera;
import sge.io.Input;
import sge.math.Motion;


/**
 * ...
 * @author fidgetwidget
 */
class Player extends Entity
{
	public var SIZE:Float = 8;	
	public var SPEED:Float = 800;
	public var MAXSPEED:Float = 200;
	
	private var _circle:Circle;
	private var _circleCollider:CircleCollider;
	private var _shape:Shape;
	private var madeVisible:Bool = false;

	public function new() 
	{
		super();
		className = Type.getClassName(Player);	
		_circle = new Circle(0, 0, SIZE);
		_circleCollider = new CircleCollider(_circle, this);
		collider = _circleCollider;
		_visible = true;
		_active = true;
		
		state = Entity.DYNAMIC;	
		motion = new Motion();
		motion.fx = 0.03;
		motion.fy = 0.03;
		motion.max_v = MAXSPEED;
		
		_shape = new Shape();
		mc = _shape;
	}
	
	override private function _input(delta:Float):Void 
	{		
		if ( Input.isKeyDown(Keyboard.A) || Input.isKeyDown(Keyboard.LEFT) ) {
			motion.ax = -SPEED;
		} else
		if ( Input.isKeyDown(Keyboard.D) || Input.isKeyDown(Keyboard.RIGHT) ) {
			motion.ax = SPEED;
		} else {
			motion.ax = 0;
		}
		
	}	
	
	override public function _render( camera:Camera ):Void 
	{
		mc.x = x - camera.x;
		mc.y = y - camera.y;
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
		_shape.graphics.lineStyle(1, 0x2332CF);
		_shape.graphics.beginFill(0x2332CF);
		_circle.draw( _shape.graphics );
		_shape.graphics.endFill();
		madeVisible = true;
	}	
	
}