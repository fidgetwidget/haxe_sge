package sge.graphics;

import motion.Actuate;

import sge.core.Entity;
import sge.math.Motion;
import sge.math.Vector2D;

/**
 * ...
 * @author fidgetwidget
 */
class Emitter extends Entity
{	
	
	public var maxCount		: Int;
	public var particles 	(get, never) : List<Particle>;
	
	private var _particles 	: List<Particle>;
	private var _pool		: List<Particle>;
	
	public function new() 
	{
		super();
		className = Type.getClassName(Emitter);
		
		_particles = new List<Particle>();
		_pool = new List<Particle>();		
	}
	
	public function init( maxCount:Int = 255 ) :Void 
	{
		this.maxCount = maxCount;
		
		// in case we are re-initing (TODO: handle this case better)
		_particles.clear();
		_pool.clear();
		
		// fill the pool
		while (_pool.length < maxCount) {
			_pool.add( new Particle( this ) );
		}
	}
	
	public function start( reset : Bool = true ) : Void 
	{
		if (reset) {
			// move all active particles to the pool (and kill them first)
			while (_particles.length > 0) {
				_pool.add( _particles.pop().die(false) );
			}
		}
		
		_active = true;
		
		/// Setup the rules here
	}
	
	public function stop() : Void
	{
		_active = false;
		
		/// make sure to pause any active tweens here as well...
	}
	
	override public function update( delta : Float ) : Void 
	{
		if (!_active) { return; }
		
		for (p in _particles) {
			p.update( delta );
		}
	}
	
	override public function render( camera ):Void 
	{
		// rendering the particles should be done in a batch here
		// eg.
		// loop through each active particle and
		// use something like Tileframes to batch draw the particles using their data
		// -----
		// for (p in _active) {
		//     tileframes.addFrame( p.transform.x, p.transform.y, frame, p.transform.scaleX, p.transform.rotation );
		// }
		// tileframes.drawTiles();
		// -----
	}
	
	public function recycle( particle : Particle ) : Void 
	{
		_particles.remove( particle );
		_pool.add( particle );
	}
	
	private function get_particles() :List<Particle>
	{
		return _particles;
	}
	
}