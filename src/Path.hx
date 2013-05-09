package ;

import nme.geom.Point;

/**
 * Dot Path with traversable functionality.
 * 
 * @author fidgetwidget
 */
/*
class Path
{
	public var points:Array<Point>;
	public var start:Point;
	public var tail:Point;
	public var position:Point;
	
	public var on_pathComplete:Dynamic;
	
	private var _i:Int; // itterator index;
	
	public function new( path:Array<Point> = null ) { 
		
		_i = -1;
		position = new Point();
		points = [];
		if ( path != null ) {
			points.concat( path );
		}
	}
	
	public function begin() :Void {
		
		start = new Point( points[0].x, points[0].y );
		tail = new Point( points[points.length - 1].x, points[points.length - 1].y );
		_i = 1;
		
		position.x = start.x;
		position.y = start.y;
	}
	
	// prevents travel from moving the position, 
	// and calls the path complete event
	public function end() :Void {
		_i = points.length;
		pathComplete();
	}
	
	public function travel( speed:Float, delta:Float ) :Point {
		
		if (_i == -1) { return position; }
		if ( _i == points.length || 
		     ( position.x == tail.x && 
		       position.y == tail.y ) 
			) {
			_i = points.length;
			return position;
		}
		
		var dtt:Float = speed * delta;
		
		var p0:Point = points[_i];				
		var dtn:Float = Point.distance( position, p0 );
		
		// if we are going to pass a point
		while ( dtn < dtt && _i < points.length - 1 ) {
			
			position.x = p0.x;
			position.y = p0.y;
			
			dtt -= dtn;
			
			_i++;
			p0 = points[_i];
			dtn = Point.distance( position, p0 );
		}
		
		// moving a distance between two points
		if ( dtt < dtn  || 
		     ( dtt > 0 && _i < points.length - 1 ) ) {
			
			var f = dtt / dtn;
			position = Point.interpolate(p0, position, f);
		} else
		if ( dtt > dtn && 
		     _i ==  points.length -1 ) {
			
			position.x = p0.x;
			position.y = p0.y;
			_i = points.length;
			
			pathComplete();
		}
		
		return position;
	}
	
	private function pathComplete() :Void {
		
		if ( on_pathComplete != null )  {
			on_pathComplete( this );
		}		
	}
	
	
	
}*/