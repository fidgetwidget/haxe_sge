package demos.pong;

import nme.display.Graphics;
import nme.display.Shape;

import sge.core.Entity;
import sge.core.Camera;
import sge.geom.Box;
import sge.graphics.Draw;
import sge.physics.AABB;
import sge.physics.BoxCollider;
import sge.physics.Motion;


/**
 * ...
 * @author fidgetwidget
 */
class Paddle extends demos.shared.Paddle
{

	public function new() 
	{
		WIDTH = 8;
		HEIGHT = 80;
		COLOR = 0x222222;
		FRICTION = 0.002;
		super();
	}
	
}