package sge.graphics;

import nme.display.BitmapData;
import nme.display.Graphics;
import nme.geom.Point;
import nme.geom.Rectangle;


/**
 * ...
 * @author fidgetwidget
 */

 
class Frame
{
	public var tilesheet:nme.display.Tilesheet;
	public var rectangle:Rectangle;
	public var index:Int;
	
	public function new( tilesheet, rectangle, index ) {
		this.tilesheet = tilesheet;
		this.rectangle = rectangle;
		this.index = index;
	}
}

class Spritesheet 
{
	public var frames(get_frames, null):Array<Frame>;
	
	private var bmpSource:BitmapData;
	private var tilesheet:nme.display.Tilesheet;
	private var lastIndex:Int = 0;

	public function new( bitmapData :BitmapData ) 
	{		
		tilesheet = new nme.display.Tilesheet(bitmap);		
	}
	
	
	private function _makeFrame( rect:Rectangle ) :Void {
		tilesheet.addTileRect(rect);
		lastIndex++;
		frames[lastIndex] = new Frame(tilesheet, rect, lastIndex);
	}
	
}