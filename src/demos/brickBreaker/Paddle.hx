package demos.brickBreaker;

import nme.display.Shape;
import nme.display.Graphics;

import sge.core.Camera;
import sge.core.Entity;
import sge.physics.BoxCollider;
import sge.physics.Motion;
import sge.geom.Circle;
import sge.geom.Box;


/**
 * ...
 * @author fidgetwidget
 */

class Paddle extends demos.shared.Paddle
{
	
	public function new() 
	{
		WIDTH = 56;
		HEIGHT = 16;
		COLOR = 0x333333;
		FRICTION = 0;
		super();
	}
	
}