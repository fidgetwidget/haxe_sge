package sge.geom;

import nme.display.Graphics;
import nme.geom.Point;

import sge.physics.Vec2;

/**
 * ...
 * @author fidgetwidget
 */

class LineSegment
{
	
	public var startX(getStartX, setStartX):Float;
	public var startY(getStartY, setStartY):Float;
	public var endX(getEndX, setEndX):Float;
	public var endY(getEndY, setEndY):Float;
	
	public var start(getStart, setStart):Vec2;
	public var end(getEnd, setEnd):Vec2;

	public function new() 
	{
		_start = new Vec2();
		_end = new Vec2();
	}
	
	public function setPoints( startX:Float, startY:Float, endX:Float, endY:Float ) :Void 
	{
		_start.x = startX;
		_start.y = startY;
		_end.x = endX;
		_end.y = endY;
	}
	
	public function draw( graphics:Graphics ) :Void {
		graphics.moveTo(startX, startY);
		graphics.lineTo(endX, endY);
	}
	
	private function getStartX():Float { return _start.x;  }
	private function setStartX(x:Float):Float { _start.x = x; return _start.x;  }
	private function getStartY():Float { return _start.y;  }
	private function setStartY(y:Float):Float { _start.y = y; return _start.y;  }
	private function getEndX():Float { return _end.x;  }
	private function setEndX(x:Float):Float { _end.x = x; return _end.x;  }
	private function getEndY():Float { return _end.y;  }
	private function setEndY(y:Float):Float { _end.y = y; return _end.y;  }
	
	private function getStart():Vec2 { return _start;  }
	private function setStart(s:Vec2):Vec2 { _start.x = s.x; _start.y = s.y; return _start;  }
	private function getEnd():Vec2 { return _end;  }
	private function setEnd(e:Vec2):Vec2 { _end.x = e.x; _end.y = e.y; return _end;  }
	
	private var _start:Vec2;
	private var _end:Vec2;
	
}