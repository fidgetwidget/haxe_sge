package demos.physicsTest;

import nme.display.Graphics;
import nme.display.Shape;
import nme.Lib;

import sge.core.Camera;
import sge.core.Engine;
import sge.core.Entity;
import sge.geom.Box;
import sge.graphics.Draw;
import sge.physics.AABB;
import sge.physics.BoxCollider;
import sge.physics.Motion;
import sge.random.Rand;


/**
 * ...
 * @author ...
 */
class Block extends Entity
{
	private var _box:Box;
	private var _boxCollider:BoxCollider;
	private var _shape:Shape;
	private var madeVisible:Bool = false;

	public function new() 
	{
		super();
		className = Type.getClassName(Block);
		_box = new Box(0, 0, Rand.instance.between(10,20), Rand.instance.between(10,20));
		_boxCollider = new BoxCollider( _box, this);
		_boxCollider.xOffset = _boxCollider.width * 0.5;
		_boxCollider.yOffset = _boxCollider.height * 0.5;
		collider = _boxCollider;
		_visible = true;
		_active = true;			
		color = 0xFF2233;
		state = Entity.DYNAMIC;
		_shape = new Shape();
		mc = _shape;
		
		_initMotion();	
	}
	
	override public function free():Void 
	{
		super.free();
		_visible = false;
		get_visible();
	}
	
	override public function _render( camera:Camera ):Void 
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
		aabb = this.collider.getBounds();
		
		if (motion.inMotion) {
			_shape.graphics.beginFill(color);
			_shape.graphics.lineStyle(1, color);
		} else {
			_shape.graphics.beginFill(0x6c6c6c);
		}
		
		_shape.graphics.drawRect(0,0,aabb.width, aabb.height );
		_shape.graphics.endFill();
		madeVisible = true;
	}
	
	private function _initMotion() {
		if (_m == null) {
			_m = new Motion();
		}
		_m.vx = Rand.instance.between( -20, 20);
		_m.vy = Rand.instance.between( -20, 20);
		_m.vf = 0.0015;
	}
	
	public static function makeBlock( x:Float, y:Float ) :Block
	{
		var block:Block = Engine.getEntity( Block );
		block.transform.z = 1;
		block.x = x;
		block.y = y;
		block._initMotion();
		block._visible = true;
		block.makeVisible();
		return block;
	}
	
	private var color:Int;
	private var aabb:AABB;
}