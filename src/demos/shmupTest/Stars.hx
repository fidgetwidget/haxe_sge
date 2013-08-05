package demos.shmupTest;

import flash.display.Shape;
import sge.graphics.Camera;
import sge.particles.Emitter;
import sge.particles.Particle;
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
		init(200);
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
			if (p.y > area_height) {
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
			shape.graphics.moveTo( (p.x - camera.x) - (p.z * (camera.cx - p.x)), (p.y - camera.y) );
			shape.graphics.lineTo( (p.x - camera.x) - (p.z * (camera.cx - p.x)), (p.y - camera.y) + (p.z * 8) );
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
		var zz = Random.instance.between(10, 30);
		p.x = Random.instance.between(0, area_width);
		p.y = Random.instance.between(0, area_height);
		p.z = -(zz* 0.01);
		p.vy = zz * 6;
		p.ay = zz;
		p.fx = 0;
		p.fy = 0;
		
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
		var zz = Random.instance.between(10, 30);
		p.x = Random.instance.between(0, area_width);
		p.y = 0;
		p.z = -(zz* 0.01);
		p.vy = zz * 6;
		p.ay = zz;
		p.fx = 0;
		p.fy = 0;
	}
	
}