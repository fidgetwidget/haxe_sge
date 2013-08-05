package sge.geom;

import sge.math.Vector2D;

/**
 * ...
 * @author fidgetwidget
 */
class SplineSegment extends LineSegment
{
	
	/*
	 * Properties 
	 */
	public var resolution(null, set):Int;
	
	/*
	 * Members 
	 */	
	private var _pointsBetween	: List<Vector2D>;
	private var _verts			: Vertices;
	private var _changed		: Bool;	
	private var _prev			: Vector2D;
	private var _next			: Vector2D;
	private var _hermiteValues	: Array<Float>;
	
	// Memory Saving Members
	private var _m1				: { x:Float, y:Float };
	private var _m2				: { x:Float, y:Float };
	private var _px				:Float;
	private var _py				:Float; 
	private var _t				:Float;
	private var _i				:Int;	// Index
	private var _l				:Int;	// Length	
	private var _h00			:Float;	// Hermite Matrix Values
	private var _h10			:Float;
	private var _h01			:Float;
	private var _h11			:Float;
	

	public function new( r:Int = 5, prev:Vector2D = null, next:Vector2D = null ) 
	{
		super();
		_prev = prev;
		_next = next;
		_pointsBetween = new List<Vector2D>();
		resolution = r;
		_changed = false;
		_hermiteValues = [0, 0, 1, 0];
	}
	
	
	public function setPrev( x:Float, y:Float ) :Void {
		if (_prev == null) {
			_prev = new Vector2D(x, y);
		} else {
			_prev.x = x;
			_prev.y = y;
		}
		_changed = true;
	}
	public function setPrevPoint( prev:Vector2D ) :Void {
		_prev = prev; 
		_changed = true;
	}
	
	public function setNext( x:Float, y:Float ) :Void {
		if (_next == null) {
			_next = new Vector2D(x, y);
		} else {
			_next.x = x;
			_next.y = y;
		}
		_changed = true;
	}
	public function setNextPoint( next:Vector2D ) :Void {
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
		
		_verts.add(start);
		for (p in _pointsBetween)
		{
			_verts.add(p);
		}
		_verts.add(end);
		
		return _verts;
	}
	
	public override function draw( graphics:Graphics ) :Void {
		
		graphics.moveTo(start.x, start.y);
		
		// if we are using the points at all, we need to make sure they are correct
		if (_changed)
			resetSpline(); // should this be before the first draw?
		
		for (p in _pointsBetween) {
			graphics.lineTo(p.x, p.y);
		}
		
		graphics.lineTo(end.x, end.y);
	}
	
	private function resetSpline() {
		
		_pointsBetween.clear(); // TODO: will need to change when pooling Point objects is added...
		
		smoothSpline( start.x, start.y, end.x, end.y,
			(_prev == null ? start.x : _prev.x), (_prev == null ? start.y : _prev.y),
			(_next == null ? end.x   : _next.x), (_next == null ? end.y   : _next.y) );
			
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
	
	
	private function set_resolution( r:Int ) :Int	{ 
		resolution = 1 / r;
		_hermiteValues = [];
		_t = resolution;
		while (_t <= 1) {
			_h00 = (1 + 2 * _t) * (1 - _t) * (1 - _t);
			_h10 = _t  * (1 - _t) * (1 - _t);
			_h01 = _t * _t * (3 - 2 * _t);
			_h11 = _t * _t * (_t - 1);
			_hermiteValues.push(_h00);
			_hermiteValues.push(_h10);
			_hermiteValues.push(_h01);
			_hermiteValues.push(_h11);
			_t += resolution;
		}
		_changed = true;
		return r;
	}
	
	
}