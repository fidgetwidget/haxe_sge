package demos.cameraTest;

import nme.display.Graphics;
import nme.display.Shape;
import nme.display.Sprite;
import nme.Lib;

import sge.core.Camera;
import sge.core.Engine;
import sge.core.Entity;
import sge.graphics.Draw;
import sge.random.Rand;
import sge.physics.AABB;
import sge.physics.BoxCollider;
import sge.physics.Motion;
import sge.geom.Box;

/**
 * ...
 * @author ...
 */
class Block extends Entity
{
	
	private var _box:Box;
	private var _boxCollider:BoxCollider;
	private var _shape:Shape;

	public function new() 
	{
		super();
		className = Type.getClassName(demos.cameraTest.Block);
		_box = new Box(0, 0, Rand.instance.between(4, 8), Rand.instance.between(4, 8));
		_boxCollider = new BoxCollider( _box, this );
		collider = _boxCollider;
		_visible = true;
		_active = true;
		_m = new Motion( Rand.instance.between( -20, 20), Rand.instance.between( -20, 20) );
		_m.vf = 0.03;
		transform.z = Rand.instance.between( -0.25, 0.25 );
		color = 0xFF2233;
		state = Entity.DYNAMIC;
		_shape = new Shape();
		mc = _shape;
	}
	
	override public function _render( camera:Camera ):Void 
	{		
		mc.x = (aabb.x - camera.x) + (transform.z * (camera.center.x - aabb.cx));
		mc.y = (aabb.y - camera.y) + (transform.z * (camera.center.y - aabb.cy));
	}
	
	override private function get_visible():Bool 
	{
		if (_visible && !madeVisible) { makeVisible(); }
		if (!_visible) { cast(mc, Shape).graphics.clear(); }
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
	private var madeVisible:Bool = false;
	
	
	public static function makeBlock( x:Float, y:Float, fixedZ:Bool = false ) :Block
	{
		var block:Block = Engine.getEntity( Block );
		block.x = x;
		block.y = y;
		block.motion.vx = Rand.instance.between( -20, 20 );
		block.motion.vy = Rand.instance.between( -20, 20 );
		block.motion.vf = 0.03;
		if (fixedZ) {
			block.transform.z = 0;
		} 
		else {
			block.transform.z = Rand.instance.between( -0.25, 0.5 );
			if (block.transform.z == 0) {
				
			}
			else
			if (block.transform.z > 0) {
				block.color = 0x333333;
			} 
			else {
				block.color = 0xaaaaaa;
			}
			
		}
		return block;
	}
	
	private var color:Int;
	private var aabb:AABB;
}