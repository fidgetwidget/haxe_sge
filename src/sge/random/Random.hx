package sge.random;

import sge.physics.Vec2;

/**
 * taken from: https://github.com/ncannasse/ld24/blob/master/lib/Rand.hx 
 */

class Random 
{
	// Singleton instance
	public static var instance:Random;
	
	/**
	 * Members
	 */
	private var seed : Float;
	
	public static function init( seed:Int ) :Random
	{
		return getInstance(seed);
	}
	
	public static function getInstance( seed:Int ) :Random
	{
		return instance = new Random(seed);
	}
	
	// TODO: change it to accept a string instead of an int seed
	private function new( seed : Int ) {
		this.seed = hash(((seed < 0) ? -seed : seed) + 151);
	}
	
	// taken from: https://github.com/ncannasse/ld24/blob/master/lib/Rand.hx
	public static function hash( n ) {
		for( i in 0...5 ) {
			n ^= (n << 7) & 0x2b5b2500;
			n ^= (n << 15) & 0x1b8b0000;
			n ^= n >>> 16;
			n &= 0x3FFFFFFF;
			var h = 5381;
			h = (h << 5) + h + (n & 0xFF);
			h = (h << 5) + h + ((n >> 8) & 0xFF);
			h = (h << 5) + h + ((n >> 16) & 0xFF);
			h = (h << 5) + h + (n >> 24);
			n = h & 0x3FFFFFFF;
		}
		return n;
	}	
	
	public inline function random( n ) : Float {
		return int() % n;
	}
	
	public inline function between( min:Float, max:Float ) :Float {
		return int() % (max - min) + min;
	}
	
	public inline function randomDir() :Vec2 {
		var vec2:Vec2 = new Vec2(between(-10, 10), between(-10, 10));
		vec2.normalize();
		return vec2;
	}
	
	public inline function randomColor() :Int {
		return int() * 0xFFFFFF;
	}
	
	public inline function rand() : Float {
		// we can't use a divider > 16807 or else two consecutive seeds
		// might generate a similar float
		return (int() % 10007) / 10007.0;
	}

	inline function int() : Int {
		return Std.int(seed = (seed * 16807.0) % 2147483647.0) & 0x3FFFFFFF;
	}
	
}