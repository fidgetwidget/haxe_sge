package demos.shared;

import nme.display.Graphics;
import nme.display.Shape;

import sge.core.Entity;
import sge.core.Camera;
import sge.geom.Box;
import sge.graphics.Draw;
import sge.physics.AABB;
import sge.physics.BoxCollider;
import sge.physics.Motion;

/**
 * ...
 * @author fidgetwidget
 */

class Paddle extends Entity
{

	public var WIDTH:Int;
	public var HEIGHT:Int;
	public var COLOR:Int;
	public var FRICTION:Float;
	
	private var _box:Box;
	private var _boxCollider:BoxCollider;
	private var _shape:Shape;
	private var _madeVisible:Bool = false;

	public function new() 
	{
		super();
		className = Type.getClassName(Paddle);
		_box = new Box(0, 0, WIDTH, HEIGHT);
		_boxCollider = new BoxCollider(_box, this);
		collider = _boxCollider;
		_visible = true;
		_active = true;
		_m = new Motion();
		_m.vf = FRICTION;
		state = Entity.DYNAMIC;
		_shape = new Shape();
		mc = _shape;
	}
	
	override public function _render( camera:Camera ):Void 
	{		
		_shape.x = x - _box.width * 0.5;
		_shape.y = y - _box.height * 0.5;
	}
	
	override private function set_visible(visible:Bool):Bool 
	{
		if (visible && !_madeVisible) { makeVisible(); }
		if (!visible) { _shape.graphics.clear(); }
		return super.set_visible(visible);
	}
	
	override private function get_visible():Bool 
	{
		if (_visible && !_madeVisible) { makeVisible(); }
		if (!_visible) { _shape.graphics.clear(); }
		return _visible;
	}
	
	private function makeVisible() :Void {
		
		if (mc == null) { return; }		
		if (_shape.graphics == null) { return; }
		
		_shape.graphics.clear();
		_shape.graphics.beginFill(COLOR);
		_shape.graphics.drawRect(0, 0, WIDTH, HEIGHT);
		_shape.graphics.endFill();
		
		_madeVisible = true;
	}
	
	
	
}