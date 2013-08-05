package demos.shmupTest;

import flash.display.Shape;
import sge.graphics.Camera;
import sge.math.Vector2D;
import sge.particles.Emitter;
import sge.particles.Particle;
import sge.math.Motion;
import sge.math.Random;
import sge.math.Transform;

/**
 * ...
 * @author fidgetwidget
 */
class Explosion extends Emitter
{
	
	static inline var MIN_LIFE:Float = 1.5;
	static inline var MAX_LIFE:Float = 2.3;
	static inline var PARTICLE_COUNT:Int = 60;
	
	public var life:Float;
	
	public var shape:Shape;
	private var _dir:Vector2D;
	private var _acc:Float;
	private var _fri:Float;
	private var _z:Float;

	public function new( x:Float, y:Float, z:Float = 0, vy:Float = 0 ) 
	{
		super();
		this.x = x;
		this.y = y;
		_z = z;
		shape = new Shape();
		motion = new Motion();
		fy = 0;
		this.vy = vy;
		mc = shape;
		life = Random.instance.between(MIN_LIFE, MAX_LIFE);
		init(PARTICLE_COUNT);
	}
	
	public function reset( x:Float, y:Float, z:Float = 0, vy:Float = 0 ) :Void {
		this.x = x;
		this.y = y;
		_z = z;
		this.vy = vy;
		life = Random.instance.between(MIN_LIFE, MAX_LIFE);
	}
	
	override public function start(reset:Bool = true):Void 
	{
		super.start(reset);

		while (_pool.length > 0) {
			var p:Particle = _pool.pop();
			_init( p );
			_particles.add(p);
		}
	}
	
	override public function update( delta : Float ) : Void 
	{
		if (!_active) { return; }
		
		super.update( delta );

		life -= delta;
	}
	
	override public function render( camera:Camera ):Void 
	{
		shape.graphics.clear();
		for (p in _particles) {
			shape.graphics.beginFill(0xFFFFFF, p.progress);
			shape.graphics.drawCircle( 
			 (x + p.x - camera.x) - (p.z * (camera.cx - p.x - x)),
			 (y + p.y - camera.y) - (p.z * (camera.cy - p.y - y)), 
			 1 );
			 shape.graphics.endFill();
		}
	}
	
	private function _init( p:Particle ) :Void 
	{
		p.make(life, null);
		
		if (p.transform == null) {
			p.transform = new Transform();
		}
		if (p.motion == null) {
			p.motion = new Motion();
		}
		p.z = _z;
		_dir = Random.instance.randomDir(_dir);
		_acc = Random.instance.between(500, 1000);
		_fri = Random.instance.between(5, 10) * 0.1;
		p.ax = _dir.x * _acc;
		p.ay = _dir.y * _acc;
		p.fx = _fri;
		p.fy = _fri;
	}
	
}