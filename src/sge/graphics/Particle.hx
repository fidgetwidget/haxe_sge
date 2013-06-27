package sge.graphics;

import sge.math.Motion;
import sge.math.Transform;
import sge.math.Vector2D;

/**
 * ...
 * @author fidgetwidget
 */
class Particle
{
	
	public var emitter			: Emitter;
	public var transform		: Transform;
	public var motion			: Motion;
	
	public var life				: Float;
	public var progress			(get, never) : Float;	// between 1 (fully a live) and 0 (dead)
	public var remaining		(get, never) : Float;
	
	private var _remaining 	: Float;

	public function new( emitter:Emitter ) 
	{
		this.emitter = emitter;
	}
	
	public function make( life:Float, properties:Dynamic ) :Void 
	{
		this.life = life;
	}
	
	public function update( delta : Float ) :Void 
	{
		motion.apply( transform, delta );
		
		_remaining -= delta;
		if (_remaining <= 0) {
			die();
		}
	}
	
	public function die( recycle:Bool = true ) : Particle {
		
		transform.free();
		motion.free();
		if (recycle) {
			emitter.recycle( this );
		}
		return this;
	}
	
	private function get_progress() : Float 
	{
		return _remaining / life;
	}
	
	private function get_remaining() : Float
	{
		return _remaining;
	}
	
}