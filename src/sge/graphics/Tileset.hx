package sge.graphics;

import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;

/**
 * *** INCOMPLETE ***
 * Tilesheet Bitmap Data broken up into its parts (Tiles) for easy access
 * 
 * @author fidgetwidget
 */

typedef Tile = BitmapData;

typedef TileData = {
	tileset:Tileset,
	row:Int,
	col:Int
}

typedef TilesetData = {
	name:String,
	set:Array<Array<Tile>>,
	tileWidth:Int,
	tileHeight:Int
}
 
class Tileset
{
	public var name:String;
	public var set:Array<Array<Tile>>;
	public var tileWidth:Int;
	public var tileHeight:Int;
	
	public function new( name:String, tilesheet:BitmapData, tileWidth:Int, tileHeight:Int ) 
	{
		this.name = name;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		set = [];
		
		// emptyColor is the bottom right corner pixel color, used for empty tile check
		var emptyColor = tilesheet.getPixel32(tilesheet.width - 1, tilesheet.height - 1);
		
		for ( y in 0...Std.int(tilesheet.height / tileHeight) ) {
			
			set[y] = [];
			
			for ( x in 0...Std.int(tilesheet.width / tileWidth) ) {
				
				var b = new Tile( tileWidth, tileHeight, true, 0 );
				b.copyPixels(tilesheet, new Rectangle(x * tileWidth, y * tileHeight, tileWidth, tileHeight), new Point(0, 0));
				if( isEmpty( b, emptyColor ) ) {
					b.free();
					break;
				}
				set[y][x] = b;
			}			
		}
	}
	
	// return a single tile (BitmapData)
	public function getTile( row:Int, col:Int ) :Tile {
		
		return set[row][col];
	}
	
	// return a row of tiles (Array<BitmapData>)
	// used for animations
	public function getRow( row:Int ) :Array<Tile> {
		
		return set[row];
	}
	
	private static function isEmpty( b:Tile, bg:Int ) {

		for ( x in 0...b.width ) {
			
			for ( y in 0...b.height ) {
				
				var color = b.getPixel32(x, y);	
				
				if( color != bg )
					return false;
			}
		}
		return true;
	}
	
}