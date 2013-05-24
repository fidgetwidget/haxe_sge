//package sge.graphics;
//
//import nme.display.BitmapData;
//import nme.display.Tilesheet;
//import nme.display.Graphics;
//import nme.geom.Point;
//import nme.geom.Rectangle;
//
//
///**
 //* ...
 //* @author fidgetwidget
 //*/
//
 //
//class Frame
//{
	//public var tilesheet:Tilesheet;
	//public var rectangle:Rectangle;
	//public var index:Int;
	//
	//public function new( tilesheet, rectangle, index ) {
		//this.tilesheet = tilesheet;
		//this.rectangle = rectangle;
		//this.index = index;
	//}
//}
//
//class Spritesheet 
//{
	//public var frames(get_frames, null):Array<Frame>;
	//
	//private var _bmpSource:BitmapData;
	//private var _tilesheet:Tilesheet;
	//private var _frames:Array<Frame>;
	//private var _lastIndex:Int = 0;
//
	//public function new( source:BitmapData ) 
	//{		
		//_bmpSource = source;
		//_tilesheet = new Tilesheet(_bmpSource);
	//}	
	//
	//private function _makeFrame( rect:Rectangle ) :Int {
		//_tilesheet.addTileRect(rect);
		//_lastIndex++;
		//_frames[_lastIndex] = new Frame(_tilesheet, rect, _lastIndex);
		//return _lastIndex;
	//}
	//
	//private function get_frames() :Array<Frame> {
		//return _frames;
	//}
	//
//}