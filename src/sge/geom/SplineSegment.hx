package sge.geom;

import haxe.FastList;
import nme.display.Graphics;
import nme.geom.Point;

import sge.physics.Vec2;

/**
 * ...
 * @author fidgetwidget
 */

class SplineSegment extends LineSegment
{
	
	public var resolution(never, setRes):Int;

	public function new(res:Int = 5, prev:Vec2 = null, next:Vec2 = null ) 
	{
		super();
		_prev = prev;
		_next = next;
		_pointsBetween = new List<Vec2>();
		resolution = res;
		_changed = false;
		_hermiteValues = [0, 0, 1, 0];
		
	}
	
	public function setPrev(prevX:Float, prevY:Float) :Void {
		if (_prev == null) {
			_prev = new Vec2(prevX, prevY);
		}
		else {
			_prev.x = prevX;
			_prev.y = prevY;
		}
		_changed = true;
	}
	public function setPrevPoint( prev:Vec2 ) :Void {
		_prev = prev; 
		_changed = true;
	}
	
	public function setNext(nextX:Float, nextY:Float) :Void {
		if (_next == null) {
			_next = new Vec2(nextX, nextY);
		}
		else {
			_next.x = nextX;
			_next.y = nextY;
		}
		_changed = true;
	}
	public function setNextPoint( next:Vec2 ) :Void {
		_next = next;
		_changed = true;
	}
	
	public function getVertices() :Vertices
	{	
		// only init the line list if we are going to use it.
		if (_verts == null) { _verts = new Vertices(); }
		
		// Reset the list if it has changed
		if (_changed) { 
			_verts.clear(); 
			resetSpline(); 
		}
		
		_verts.add(_start);
		for (p in _pointsBetween)
		{
			_verts.add(p);
		}
		_verts.add(end);
		
		return _verts;
	}
	
	public override function draw( graphics:Graphics ) :Void {
		
		graphics.moveTo(startX, startY);
		
		// if we are using the points at all, we need to make sure they are correct
		if (_changed)
			resetSpline(); // should this be before the first draw?
		
		for (p in _pointsBetween) {
			graphics.lineTo(p.x, p.y);
		}
		
		graphics.lineTo(endX, endY);
	}
	
	private function resetSpline() {
		
		_pointsBetween.clear(); // TODO: will need to change when pooling Point objects is added...
		
		smoothSpline( _start.x, _start.y, _end.x, _end.y,
			(_prev == null ? _start.x : _prev.x), (_prev == null ? _start.y : _prev.y),
			(_next == null ? _end.x : _next.x), (_next == null ? _end.y : _next.y) );
			
		_changed = false;
	}
	
	private function smoothSpline(_startX:Float, _startY:Float, _endX:Float, _endY:Float,
							_prevX:Float, _prevY:Float, _nextX:Float, _nextY:Float ) :Void
	{
		_m1.x = ( _endX - _prevX ) / 2; 
		_m1.y = ( _endY - _prevY ) / 2;
		_m2.x = ( _nextX - _startX ) / 2;
		_m2.y = ( _nextY - _startY ) / 2;
					
		_l = _hermiteValues.length;
		_i = 0;
		while (_i < _l)
		{
			_h00 = _hermiteValues[_i];
			_h10 = _hermiteValues[_i + 1];
			_h01 = _hermiteValues[_i + 2];
			_h11 = _hermiteValues[_i + 3];
			
			_px = _h00 * _startX + _h10 * _m1.x + _h01 * _endX + _h11 * _m2.x;
			_py = _h00 * _startY + _h10 * _m1.y + _h01 * _endY + _h11 * _m2.y;
			
			_pointsBetween.push(new Vec2(_px, _py)); // TODO: change this to use pooling.
			_i += 4;
		}
	}
	
	private function setRes( res:Int ) :Int	{ 
		_res = 1 / res;
		_hermiteValues = [];
		_t = _res;
		while (_t <= 1) {
			_h00 = (1 + 2 * _t) * (1 - _t) * (1 - _t);
			_h10 = _t  * (1 - _t) * (1 - _t);
			_h01 = _t * _t * (3 - 2 * _t);
			_h11 = _t * _t * (_t - 1);
			_hermiteValues.push(_h00);
			_hermiteValues.push(_h10);
			_hermiteValues.push(_h01);
			_hermiteValues.push(_h11);
			_t += _res;
		}
		_changed = true;
		return res;
	}
	
	private var _pointsBetween:List<Vec2>;
	private var _verts:Vertices;
	private var _changed:Bool;
	
	private var _prev:Vec2;
	private var _next:Vec2;
	
	private var _m1: { x:Float, y:Float };
	private var _m2: { x:Float, y:Float };
	private var _px:Float;
	private var _py:Float; 
	private var _t:Float;
	private var _i:Int;
	private var _l:Int;
	private var _hermiteValues:Array<Float>;
	private var _h00:Float;
	private var _h10:Float;
	private var _h01:Float;
	private var _h11:Float;
	private var _res:Float;
	
}