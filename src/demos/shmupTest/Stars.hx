package demos.shmupTest;

import flash.display.Shape;
import sge.graphics.Camera;
import sge.graphics.Emitter;
import sge.graphics.Particle;
import sge.math.Motion;
import sge.math.Random;
import sge.math.Transform;

/**
 * ...
 * @author fidgetwidget
 */
class Stars extends Emitter
{
	
	public var area_width:Float = 0;
	public var area_height:Float = 0;
	var shape:Shape;

	public function new() 
	{
		super();
		shape = new Shape();
		mc = shape;
		init();
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
		
		var p:Particle;
		
		for (p in _particles) {
			p.update( delta );
			if (p.transform.y > area_height) {
				p.die();
			}
		}
		
		while (_pool.length > 0) {
			p = _pool.pop();
			_reset( p );			
			_particles.add(p);
		}
	}
	
	override public function render( camera:Camera ):Void 
	{
		mc.x = 0;
		mc.y = camera.bounds.top - camera.y;
		shape.graphics.clear();
		shape.graphics.lineStyle(1, 0xFFFFFF);
		for (p in _particles) {
			shape.graphics.moveTo( (p.transform.x - camera.x) - (p.transform.z * (camera.cx - p.transform.x)), p.transform.y );
			shape.graphics.lineTo( (p.transform.x - camera.x) - (p.transform.z * (camera.cx - p.transform.x)), p.transform.y + p.transform.z * 6 );
		}
	}
	
	private function _init( p:Particle ) :Void 
	{
		p.make(Math.POSITIVE_INFINITY, null);
		
		if (p.transform == null) {
			p.transform = new Transform();
		}
		if (p.motion == null) {
			p.motion = new Motion();
		}
		var zz = Random.instance.between(25, 50);
		p.transform.x = Random.instance.between(0, area_width);
		p.transform.y = Random.instance.between(0, area_height);
		p.transform.z = -(zz* 0.01);
		p.motion.vy = zz * 5;
		p.motion.fx = 0;
		p.motion.fy = 0;
		
	}
	
	private function _reset( p:Particle ) :Void 
	{
		p.make(Math.POSITIVE_INFINITY, null);
		
		if (p.transform == null) {
			p.transform = new Transform();
		}
		if (p.motion == null) {
			p.motion = new Motion();
		}
		var zz = Random.instance.between(25, 50);
		p.transform.x = Random.instance.between(0, area_width);
		p.transform.y = 0;
		p.transform.z = -(zz* 0.01);
		p.motion.vy = zz * 5;
		p.motion.fx = 0;
		p.motion.fy = 0;
	}
	
}