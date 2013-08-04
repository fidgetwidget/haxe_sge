package sge.geom;

import nme.display.Graphics;
import nme.geom.Point;

import sge.physics.Vec2;

/**
 * ...
 * @author fidgetwidget
 */

class LineSegment
{
	
	public var ax(get_ax, set_ax):Float;
	public var ay(get_ay, set_ay):Float;
	public var bx(get_bx, set_bx):Float;
	public var by(get_by, set_by):Float;
	
	public var a(get_a, set_a):Vec2;
	public var b(get_b, set_b):Vec2;

	public function new() 
	{
		_a = new Vec2();
		_b = new Vec2();
	}
	
	public function setPoints( ax:Float, ay:Float, bx:Float, by:Float ) :Void 
	{
		_a.x = ax;
		_a.y = ay;
		_b.x = bx;
		_b.y = by;
	}
	
	public function draw( graphics:Graphics ) :Void {
		graphics.moveTo(ax, ay);
		graphics.lineTo(bx, by);
	}
	
	private function get_ax():Float 		{ return _a.x;  }
	private function set_ax(x:Float):Float 	{ _a.x = x; return _a.x;  }
	private function get_ay():Float 		{ return _a.y;  }
	private function set_ay(y:Float):Float 	{ _a.y = y; return _a.y;  }
	private function get_bx():Float 			{ return _b.x;  }
	private function set_bx(x:Float):Float 	{ _b.x = x; return _b.x;  }
	private function get_by():Float 			{ return _b.y;  }
	private function set_by(y:Float):Float 	{ _b.y = y; return _b.y;  }
	
	private function get_a():Vec2 			{ return _a;  }
	private function set_a(s:Vec2):Vec2 	{ _a.x = s.x; _a.y = s.y; return _a;  }
	private function get_b():Vec2 			{ return _b;  }
	private function set_b(e:Vec2):Vec2 		{ _b.x = e.x; _b.y = e.y; return _b;  }
	
	private var _a:Vec2;
	private var _b:Vec2;
	
}