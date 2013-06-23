package sge.geom;

import flash.geom.Point;
import sge.math.Vector2D;

/**
 * ...
 * @author fidgetwidget
 */
class LineSegment
{
	
	/*
	 * Properties
	 */
	public var start				: Vector2D;
	public var sx(get, set)			: Float;
	public var sy(get, set)			: Float;
	public var end					: Vector2D;
	public var ex(get, set)			: Float;
	public var ey(get, set)			: Float;
	public var length(get, never)	: Float;
	

	public function new( sx:Float, sy:Float, ex:Float, ey:Float ) 
	{
		start = new Vector2D();
		end = new Vector2D();
		set( sx, sy, ex, ey );
	}
	
	public function set( sx:Float, sy:Float, ex:Float, ey:Float ) :Void 
	{
		start.x = sx;
		start.y = sy;
		end.x = ex;
		end.y = ey;
	}
	
	public function draw( graphics:Graphics ) :Void 
	{
		graphics.moveTo(start.x, start.y);
		graphics.lineTo(end.x, end.y);
	}
	
	
	/*
	 * Getters & Setters
	 */
	
	private function get_sx() :Float { return start.x; }
	private function get_sy() :Float { return start.y; }
	private function get_ex() :Float { return end.x; }
	private function get_ey() :Float { return end.y; }
	
	private function set_sx( x:Float ) :Float { return start.x = x; }
	private function set_sy( y:Float ) :Float { return start.y = y; }
	private function set_ex( x:Float ) :Float { return end.x = x; }
	private function set_ey( y:Float ) :Float { return end.y = y; }
	
	private function get_length() :Float
	{
		_dx = end.x - start.x;
		_dy = end.y - start.y;
		return Math.sqrt(_dx * _dx + _dy * _dy);
	}
	private var _dx:Float;
	private var _dy:Float;
	
}