package sge.math;

import flash.Lib;

/**
 * ...
 * @author fidgetwidget
 */
class Dice 
{
	private static var _rand:Random;
	
	// Roll n dice of type d and return an array of the results
	// eg. Roll(6, 2) to roll 2d6
	// default: d = 6, n = 1 eg Roll() is 1d6
	public static inline function roll( d:Int = 6, n:Int = 1, newSeed:Bool = false ) :Array<Int>
	{
		if (_rand == null || newSeed) { _rand = Random.getInstance(Lib.getTimer()); }
		
		var _rr:Array<Int> = [];
		for (i in 0...n) {
			_rr[i] = Math.ceil(_rand.random(d) + 1);
		}
		return _rr;
	}
	
	// Roll n dice of type d and return the sum total
	// eg. Roll(6, 2) to roll 2d6
	// default: d = 6, n = 1 eg Roll() is 1d6
	public static inline function rollSum( d:Int = 6, n:Int = 1, newSeed:Bool = false) :Int
	{
		if (_rand == null || newSeed) { _rand = Random.getInstance(Lib.getTimer()); }
		
		var _r:Int = 0;
		for (i in 0...n) {
			_r += Math.ceil(_rand.random(d) + 1);
		}
		return _r;
	}
	
}