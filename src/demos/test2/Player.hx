package demos.test2;

import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Graphics;
import flash.ui.Keyboard;
import sge.collision.BoxCollider;
import sge.geom.Box;
import sge.graphics.Draw;
import sge.math.Vector2D;

import sge.core.Entity;
import sge.collision.CircleCollider;
import sge.geom.Circle;
import sge.io.Input;
import sge.graphics.Camera;
import sge.math.Motion;


/**
 * ...
 * @author fidgetwidget
 */
class Player extends Entity
{
	public var SIZE:Float = 16;	
	public var SPEED:Float = 800;
	public var MAXSPEED:Float = 200;
	
	private var _circle:Circle;
	private var _box:Box;
	private var _circleCollider:CircleCollider;
	private var _boxCollider:BoxCollider;
	private var _shape:Shape;
	private var madeVisible:Bool = false;
	private var endX:Float;
	private var endY:Float;
	private var displayMode:Int = 0;

	public function new() 
	{
		super();
		className = Type.getClassName(Player);	
		_circle = new Circle(0, 0, SIZE);
		_circleCollider = new CircleCollider(_circle, this);
		_box = new Box(-SIZE, -SIZE, SIZE * 2, SIZE * 2);
		_boxCollider = new BoxCollider(_box, this);
		_boxCollider.useCenterPosition = false;
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
		if ( Input.isKeyDown(Keyboard.W) || Input.isKeyDown(Keyboard.UP) ) {
			motion.ay = -SPEED;
		} else
		if ( Input.isKeyDown(Keyboard.S) || Input.isKeyDown(Keyboard.DOWN) ) {
			motion.ay = SPEED;
		} else {
			motion.ay = 0;
		}		
		
		if ( Input.isKeyDown(Keyboard.A) || Input.isKeyDown(Keyboard.LEFT) ) {
			motion.ax = -SPEED;
		} else
		if ( Input.isKeyDown(Keyboard.D) || Input.isKeyDown(Keyboard.RIGHT) ) {
			motion.ax = SPEED;
		} else {
			motion.ax = 0;
		}
		
		if ( Input.isKeyPressed( Keyboard.T ) ) {
			collider = _boxCollider;
			displayMode = 1;
			makeVisible();
		} else
		if ( Input.isKeyPressed( Keyboard.Y ) ) {
			collider = _circleCollider;
			displayMode = 0;
			makeVisible();
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
		if (displayMode == 0) {
			_circle.draw( _shape.graphics );
		} else {
			_box.draw( _shape.graphics );
		}
		_shape.graphics.endFill();
		madeVisible = true;
	}	
	
}