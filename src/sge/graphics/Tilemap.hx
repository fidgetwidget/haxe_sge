package sge.graphics;

import sge.graphics.Tileset;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.PixelSnapping;
import nme.errors.ArgumentError;
import nme.geom.Point;
import nme.geom.Rectangle;

/** 
 * *** INCOMPLETE ***
 * @author fidgetwidget
 */

typedef TilemapData = {
	bmp:Bitmap,
	tiles:Array<Array<Tile>>,	
	tileWidth:Int,
	tileHeight:Int,
	rows:Int,
	columns:Int	
}
 

class Tilemap 
{	
	
	/**
	 * Properties
	 */
	public var bmp:Bitmap;
	public var tiles:Array<Array<TileData>>;
	public var sets:Hash<Tileset>;
	
	public var tileWidth (default, null) :Int;		// the width&height of the tiles
	public var tileHeight (default, null) :Int;
	
	public var rows (default, null) :Int;			// the number of tiles wide&heigh the Tilemap is
	public var columns (default, null) :Int;
	
	public var width (get_width, null) :Int;		// the width&height of the Tilemap
	public var height (get_height, null) :Int;
	
	/**
	 * Members
	 */
	private var _rect:Rectangle;
	private var _point:Point;
	private var _bmd:BitmapData;

	public function new( tileWidth:Int, tileHeight:Int, rows:Int, columns:Int )
	{
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;		
		this.rows = rows;
		this.columns = columns;
		
		_rect = new Rectangle(0, 0, tileWidth, tileHeight);
		_point = new Point();
		
		bmp = new Bitmap(null, PixelSnapping.NEVER, false);
		tiles = [];
		for ( y in 0...rows ) {
			
			tiles[y] = [];
		}
	}
	
	public function setTile( row:Int, col:Int, tile:TileData ) :Void {
		
		if ( row > rows || col > columns ) { throw "Position Out Of Bounds"; }
		
		tiles[row][col] = tile;
		
		// get the x/y position of the row/column
		_point.x = col * tileWidth;	
		_point.y = row * tileHeight;
		
		_bmd = tile.tileset.getTile(tile.row, tile.col);
		
		bmp.bitmapData.copyPixels(_bmd, _rect, _point);
	}
	
	/**
	 * Getters & Setters
	 */
	private inline function get_width() :Int { return tileWidth * columns; }
	private inline function get_height() :Int { return tileHeight * rows; }
	
}