package sge.graphics;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.display.Tilesheet;

/**
 * an expansion to the tilesheet class
 * + adds access to the source bitmap
 * + adds access to the tilesheets tile count
 * + adds methods to adding tilesRects to the tilesheet
 * @author fidgetwidget
 */

class Tileset 
{

	/*
	 * Properties
	 */
	public var source		(default, null)	: BitmapData;
	public var tilesheet	(default, null)	: Tilesheet;
	public var tileCount	(default, null)	: Int = 0;
	
	/// Memory Saver
	private var r:Int;
	private var c:Int;

	/**
	 * Constructor
	 * @param	bitmap
	 */
	public function new( bitmap:BitmapData ) 
	{
		source = bitmap;
		tilesheet = new Tilesheet( source );
	}
	
	public function init( tileWidth:Int, tileHeight:Int, rows:Int, cols:Int ) 
	{
		r = 0;
		c = 0;
		while (r < rows) {
			while (c < cols) {
				addTile(c * tileWidth, r * tileHeight, tileWidth, tileHeight);
				c++;
			}
			c = 0;
			r++;
		}
	}
	
	/**
	 * Add the tile to the tilesheet
	 * 
	 * @param	x
	 * @param	y
	 * @param	width
	 * @param	height
	 * @param	center
	 * @return	the index of the newly added tile
	 */
	public function addTile( x:Int, y:Int, width:Int, height:Int, center:Point = null ) :Int {
		
		var rect:Rectangle = new Rectangle(x, y, width, height);
		return addTileRect( rect, center );
	}	
	
	public function addTileRect( rect:Rectangle, center:Point = null ) :Int {
		tilesheet.addTileRect( rect, center );
		tileCount++;
		
		return tileCount - 1;
	}
	
}