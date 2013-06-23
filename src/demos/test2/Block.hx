package demos.test2;

import flash.display.Shape;
import sge.collision.CircleCollider;
import sge.core.Engine;
import sge.core.Entity;
import sge.collision.BoxCollider;
import sge.geom.Circle;
import sge.graphics.Camera;
import sge.geom.Box;
import sge.math.Dice;
import sge.math.Motion;
import sge.math.Random;

/**
 * ...
 * @author fidgetwidget
 */
class Block extends Entity
{
	
	private var _shape			: Shape;
	private var _box			: Box;
	private var _circle			: Circle;
	private var _boxCollider	: BoxCollider;
	private var _circleCollider : CircleCollider;
	private var isBox			(default, set) : Bool = false;
	private var madeVisible		: Bool = false;
	private var _wasInMotion 	: Bool;

	public function new() 
	{
		super();
		className = Type.getClassName(Block);
		
		_visible = true;
		_active = true;
		state = Entity.DYNAMIC;
		
		_m = new Motion();
		_m.fx = 0.025;
		_m.fy = 0.025;
		_shape = new Shape();
		mc = _shape;
		
		var size:Float = Random.instance.between(30, 60);
		
		_box = sge.geom.Shape.makeBox(0, 0, size, size);		
		_boxCollider = new BoxCollider(_box, this, false);
		
		_circle = sge.geom.Shape.makeCircle(0, 0, size * 0.5);
		_circleCollider = new CircleCollider(_circle, this);
		
		collider = _boxCollider;
		isBox = true;
		
	}
	
	override private function _update(delta:Float):Void 
	{
		super._update(delta);
		if (_wasInMotion != motion.inMotion) {
			makeVisible(); // update the drawing 
		}
		_wasInMotion = motion.inMotion;
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
		_shape.graphics.lineStyle( 1, 0x000000 );
		if (motion.inMotion) {
			_shape.graphics.beginFill( 0xFA6900 );
		} else {
			_shape.graphics.beginFill( 0xCCCCCC );
		}
		if (isBox) {
			_box.draw(_shape.graphics );
		} else {
			_circle.draw(_shape.graphics );
		}		
		_shape.graphics.endFill();
		
		madeVisible = true;
	}
	
	
	private function _initMotion() {
		if (_m == null) {
			_m = new Motion();
		}
		_m.vx = Random.instance.between( -20, 20 );
		_m.vy = Random.instance.between( -20, 20 );
		_m.fx = 0.005;
		_m.fy = 0.005;
		_m.angularVelocity = 0;
		_m.angularFriction = 0;
		_wasInMotion = _m.inMotion;
	}
	
	private function set_isBox( value:Bool ) :Bool 
	{
		if (isBox != value) {
			isBox = value;
			if (isBox) {
				collider = _boxCollider;
			} else {
				collider = _circleCollider;
			}
			makeVisible();
		}
		return isBox;
	}
	
	
	public static function makeBlock( x:Float, y:Float, isBox:Bool = true ) :Block
	{
		var block:Block = Engine.getEntity( Block );
		block.x = x;
		block.y = y;
		block._initMotion();
		block.isBox = isBox;
		block.makeVisible();
		return block;
	}
}