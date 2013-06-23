package sge.math;

/**
 * ...
 * @author fidgetwidget
 */
class Projection 
{
	public var min:Float;
	public var max:Float;
	
	public function new() 
	{ 
		max = min = 0; 
	}
		
	public inline function overlaps( other:Projection ) :Bool
	{
		return min > other.max || max < other.min;
	}

	public inline function getOverlap( other:Projection ) :Float
	{
		return (max > other.max) ? max - other.min : other.max - min;
	}
	
}