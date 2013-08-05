package sge.graphics;

import openfl.display.Tilesheet;

/**
 * Drawing data wrapper to draw with the Tilesheet class
 * 
 * @author fidgetwidget
 */
class Tileframes
{
	public var tilesheet	: Tilesheet;
	public var smooth		(get_smooth, set_smooth) : Bool;
	public var flags		(get_flags, set_flags) : Int;
	public var tileData		(get_tileData, null) : Array<Float>;
	
	private var _tileData	: Array<Float>;
	private var _smooth		: Bool = false;
	private var _flags		: Int = 0;
	private var _useScale	: Bool = false;
	private var _useRotate	: Bool = false;
	
	public function new( tilesheet:Tilesheet ) 
	{
		this.tilesheet = tilesheet;
		_tileData = new Array<Float>();
	}
	
	/**
	 * Add the frame to the tileData at the given position (x,y) with optional scale and rotation
	 * NOTE: not yet supporting rgb or alpha flags - I don't need them
	 * 
	 * @param	x
	 * @param	y
	 * @param	width
	 * @param	height
	 * @param	center
	 * @return	the index of the newly added tile
	 */
	public function addFrame( x:Float, y:Float, frame:Int, scale:Float = 0, rotation:Float = 0 ) :Void 
	{	
		// convert to int so that we don't draw off pixel
		x = Std.int(x);
		y = Std.int(y);
		
		_tileData.push(x);
		_tileData.push(y);
		_tileData.push(frame);
		if ( _useScale ) {
			_tileData.push(scale);
		}
		if ( _useRotate ) {
			_tileData.push(rotation);
		}
	}
	
	/// Clear the tileData 
	public function clear() :Void 
	{
		_tileData.splice(0, _tileData.length); // this is bad, as it creates a new Array every time...
	}
	
	public function drawTiles() :Void 
	{
		if (tilesheet == null) { return; } // throw "drawTiles requires a tilesheet to be set.";		
		tilesheet.drawTiles(Draw.graphics, _tileData, _smooth, _flags);
	}
	
	/*
	 * Getters & Setters
	 */
	private function get_smooth() 				:Bool 			{ return _smooth; }
	private function get_flags() 				:Int 			{ return _flags; }
	private function get_tileData() 			:Array<Float> 	{ return _tileData; }	
	private function set_smooth( smooth:Bool ) 	:Bool 			{ return _smooth = smooth; }
	private function set_flags( flags:Int ) 	:Int 			{
		_flags = flags;
		set_useScale();
		set_useRotation();
		return _flags;
	}	
	private function set_useScale() 			:Void 			{ _useScale = _flags & Tilesheet.TILE_SCALE > 0; }
	private function set_useRotation() 			:Void 			{ _useRotate = _flags & Tilesheet.TILE_ROTATION > 0; }
}