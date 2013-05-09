package demos.brickBreaker;

import sge.core.Camera;
import sge.core.Engine;
import sge.core.Entity;
import sge.geom.Box;
import sge.graphics.Draw;
import sge.physics.BoxCollider;

import nme.display.Shape;
import nme.display.Graphics;

/**
 * ...
 * @author fidgetwidget
 */

class Brick extends Entity
{
	public var width(get_width, set_width):Int;
	public var height(get_height, set_height):Int;
	public var color(default, set_color):Int = 0x555555;
	
	private var _shape:Shape;
	private var _box:Box;
	private var _boxCollider:BoxCollider;
	private var _madeVisible:Bool = false;

	public function new() 
	{
		super();
		className = Type.getClassName(Ball);
		_box = new Box(0, 0, 0, 0);
		_boxCollider = new BoxCollider(_box, this);
		collider = _boxCollider;
		_visible = true;
		_active = true;
		state = Entity.DYNAMIC;
		_shape = new Shape();
		mc = _shape;
	}
	
	public override function free()
	{
		super.free();
		_box.free();
	}
	
	public function setPosition( x:Float, y:Float ) :Void {
		
		this.x = x;
		this.y = y;
		_shape.x = x;
		_shape.y = y;
	}
	
	public function setSize( width:Int, height:Int ) :Void {		
		_boxCollider.width = width;
		_boxCollider.height = height;
		_boxCollider.xOffset = width * 0.5;
		_boxCollider.yOffset = height * 0.5;
	}
	
	override private function _render( camera:Camera ):Void 
	{
		// never moves, so we don't have to update its x,y
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
		_shape.graphics.beginFill(color);
		_shape.graphics.drawRect(0, 0, width, height);		
		_shape.graphics.endFill();
	}
	
	private function get_width() :Int 			{ return Std.int(_box.width); }
	private function get_height() :Int 			{ return Std.int(_box.height); }
	private function set_width( w:Int ) :Int 	{ return Std.int(_box.width = w); }
	private function set_height( h:Int ) :Int 	{ return Std.int(_box.height = h); }
	
	private function set_color( c:Int ) :Int {
		this.color = c;
		makeVisible();
		return this.color;
	}
	
	public static function make( x:Int, y:Int, width:Int, height:Int ) :Brick
	{
		var brick = Engine.getEntity(Brick);
		brick.setPosition(x, y);
		brick.setSize(width, height);
		return brick;
	}
	
}