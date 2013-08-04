package sge.world;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Rectangle;
import sge.core.Camera;
import sge.graphics.Draw;
import sge.graphics.TileFrames;
import sge.physics.AABB;
import sge.physics.Collider;
import sge.physics.CollisionData;
import sge.physics.CollisionMath;
import sge.physics.TileCollider;

/**
 * World 
 * a large grid of Tiles broken up into regions
 * 
 * TODO: make the number or rows/cols in each region, the width/height of each cell, and the
 *       number of layers all be set by params on init.
 * TODO: make this dynamicly load and unload the regions based on what is needed at the time
 * 
 * @author fidgetwidget
 */

class World 
{
	/*
	 * Static Properties 
	 */
	
	/// Used in the constructor 
	/// TODO: change this to be loaded on init with optional params
	public static inline var region_rows 	: Int = 8;
	public static inline var region_cols 	: Int = 8;
	
	/// Used in the init call
	/// TODO: change this to be loaded on init with optional params
	public static inline var cell_width 	: Int = 16;
	public static inline var cell_height 	: Int = 16;	
	public static var layer_count			: Int = 2;
	
	/// Set by the constructor
	public static var world_region_rows 	: Int = 0;
	public static var world_region_cols 	: Int = 0;
	public static var tile_type_count		: Int = 0;
		
	public static var world_width(get_width, never) : Int;
	public static var world_height(get_height, never) : Int;
	public static var region_width(get_region_width, never) : Int;
	public static var region_height(get_region_height, never) : Int;
	public static var world_tile_rows(get_world_rows, never) :Int;
	public static var world_tile_cols(get_world_cols, never) :Int;	
	
	/*
	 * Properties 
	 */	
	public var layers:Array<Array<Region>>; // outer array is the layer, inner array is the grid of regions
	public var layers_data:Array<BitmapData>;

	public var tileData:TileData;
	public var tileBitmap(get_tileBitmap, never):BitmapData;
	public var tilesheet(get_tilesheet, never):Tilesheet;	
	public var initialized(default, null):Bool = false;
	
	private var tileFrames:TileFrames;
	private var _renderIndex:Int = 0;
	private var _renderTiles:Array<Float>;
	

	/**
	 * Constructor
	 */
	public function new( tile_rows:Int, tile_cols:Int, init_now:Bool = true ) 
	{
		world_region_rows = Math.floor(tile_rows / region_rows);
		world_region_cols = Math.floor(tile_cols / region_cols);
		
		layers = [];
		layers_data = [];
		
		_renderTiles = [];
		
		if (init_now) {
			init();
		}
	}
	
	// Initialize the world's arrays, etc
	public function init() :Void {
		
		for (i in 0...layer_count) {
			layers[i] = [];
			//layers_data[i] = new BitmapData(world_tile_cols, world_tile_rows, false);
		}
		
		for (r in 0...world_region_rows) {
			for (c in 0...world_region_cols) {
				index = get_index(r, c);
				x_offset = c * region_width;
				y_offset = r * region_height;
				
				for (i in 0...layer_count) {
					layers[i][index] = new Region(x_offset, y_offset, i, this);
				}
			}
		}
		
		initialized = true;
	}
	
	// 
	public function loadAssets( tileData:TileData ) :Void {		
		
		this.tileData = tileData;
		
		tileFrames = new TileFrames(tilesheet);
		tile_type_count = tileData.tileset.tileCount;
	}
	
	/// Temporary way of loading in map data for the purposes of the demo...
	public function loadMap( array:Array<Int>, layer:Int = 0 ) :Void {
		var r:Int = 0;
		var c:Int = 0;
		for (i in 0...array.length) {
			 
			r = Math.floor(i / world_tile_cols);
			c = i % world_tile_cols;
			setTile(r, c, array[i], layer);
		}
	}
	
	//TODO: for dynamic loading/unloading of regions (as needed)
	private function loadRegion(r:Int, c:Int) :Void {
		
	}
	
	private function saveRegion(r:Int, c:Int) :Void {
		
	}
	
	
	/*
	 * Public functions
	 */
	
	/// Getters & Setters
	public function getTileAt( x:Float, y:Float, layer:Int = 0 ) :Int { 
		index = get_region_index_at(x, y);
		if (index < 0 || index > (world_region_rows * world_region_cols) - 1) { return 0; }
		return layers[layer][index].getTileAt(x, y);
	}
	public function setTileAt( x:Float, y:Float, tile:Int, layer:Int = 0 ) :Void { 
		index = get_region_index_at(x, y);
		if (index < 0 || index > (world_region_rows * world_region_cols) - 1) { return; }
		layers[layer][index].setTileAt(x, y, tile);
	}
	
	public inline function get_row( y:Float ) :Int 			{ return Math.floor( y / cell_height);  }
	public inline function get_col( x:Float ) :Int 			{ return Math.floor( x / cell_width);   }
	public inline function get_region_row( y:Float ) :Int 	{ return Math.floor( y / region_height); }
	public inline function get_region_col( x:Float ) :Int 	{ return Math.floor( x / region_width);  }
	
	/**
	 * Get the tile at the given world row and col position
	 * @param	r 	: the world row position
	 * @param	c 	: the world column position
	 * @param	bg	: whether or not you want the background tile (default false)
	 * @return the tile type id value at the given row and col position
	 */
	private function getTile( r:Int, c:Int, layer:Int = 0 ) :Int {
		index = get_region_index(r, c);
		if (index < 0 || index > (world_region_rows * world_region_cols) - 1) { return 0; }
		r %= region_rows;
		c %= region_cols;
		return layers[layer][index].getTile(r, c);
	}
	/**
	 * Set the tile at the given world row and col position
	 * @param	r	: the world row position
	 * @param	c	: the world column position
	 * @param	tile: the tile value to set 
	 * @param	bg	: whether or not to set the background tile (default false)
	 */
	private function setTile( r:Int, c:Int, tile:Int, layer:Int = 0 ) :Void {
		index = get_region_index(r, c);
		if (index < 0 || index > (world_region_rows * world_region_cols) - 1) { return; }
		r %= region_rows;
		c %= region_cols;
		layers[layer][index].setTile(r, c, tile);
	}
	
	// TODO: make this STORED data for each tile
	private function getTileDirections( r:Int, c:Int, layer:Int = 0 ) :Int {
		dir = 0;
		if (getTile(r - 1, c, layer) == 0) {
			dir |= TileCollider.UP;
		}
		if (getTile(r + 1, c, layer) == 0) {
			dir |= TileCollider.DOWN;
		}
		if (getTile(r, c - 1, layer) == 0) {
			dir |= TileCollider.LEFT;
		}
		if (getTile(r, c + 1, layer) == 0) {
			dir |= TileCollider.RIGHT;
		}
		return dir;
	}
	private var dir:Int;
	
	/*
	 * Render Functions
	 */	
	public function render( camera:Camera ) :Void {
		
		// get the relevant row/col values
		_r = get_row( camera.bounds.top );
		_c = get_col( camera.bounds.left );		
		mr = get_row( camera.bounds.bottom) + 1;
		mc = get_col( camera.bounds.right) + 1;		
		if (_r < 0) { _r = 0; }
		if (_c < 0) { _c = 0; }		
		if (mr > world_tile_rows) { mr = world_tile_rows; }
		if (mc > world_tile_cols) { mc = world_tile_cols; }
		c_start = _c;
		
		// clear the list of tiles to render
		tileFrames.clear();
		
		// add the relevant tiles to the list
		while ( _r < mr ) {
			while ( _c < mc ) {
				frame = getTile(_r, _c);
				
				// don't draw frame 0's
				if (frame != 0) {
					xx = (_c * cell_width) - camera.x;
					yy = (_r * cell_height) - camera.y;
					tileFrames.addFrame(xx, yy, frame);
				}
				
				_c++;
			}
			_c = c_start;
			_r++;
		}
		
		// render the list
		tileFrames.drawTiles();
	}
	private var frame:Int;
	private var xx:Float;
	private var yy:Float;
	
	
	public function drawCursorTile( x:Float, y:Float, tile:Int, camera:Camera ) :Void {
		
		// test for a valid tileId
		if (tile < 0 || tile >= tile_type_count) { return; }
		
		// get the row/col value from the cursor position
		_r = get_row(y);
		_c = get_col(x);
		xx = (_c * cell_width) - camera.x;
		yy = (_r * cell_height) - camera.y;
		// draw the tile
		tilesheet.drawTiles(Draw.graphics, [ xx, yy, tile ]);
		// draw a line around it 
		Draw.graphics.lineStyle(0.3, 0x000000);
		Draw.graphics.drawRect(xx, yy, cell_width, cell_height);
		Draw.graphics.lineStyle(0, 0);
	}
	
	/// Draw the region lines
	/// TODO: draw the collision edges
	public function drawDebug( camera:Camera ) :Void {
		
		// get the relevant row/col values		
		_r = get_row( camera.bounds.top );
		_c = get_col( camera.bounds.left );
		mr = get_row( camera.bounds.bottom) + 1;
		mc = get_col( camera.bounds.right) + 1;
		if (_r < 0) { _r = 0; }
		if (_c < 0) { _c = 0; }
		if (mr > world_tile_rows) { mr = world_tile_rows; }
		if (mc > world_tile_cols) { mc = world_tile_cols; }
		c_start = _c;
		
		// set the region row/col offset
		rr = _r - _r % region_rows;
		cc = _c - _c % region_cols;
		
		// draw the lines
		Draw.graphics.lineStyle(0.5, 0xFF0000);		
		while (rr <= mr) {
			while (cc <= mc) {
				Draw.graphics.moveTo( (cc * cell_width) - camera.x, 0 );
				Draw.graphics.lineTo( (cc * cell_width) - camera.x, camera.height );
				
				Draw.graphics.moveTo( 0, (rr * cell_height) - camera.y );
				Draw.graphics.lineTo( camera.width, (rr * cell_height) - camera.y );
				cc += region_cols;
			}
			cc = _c - _c % region_cols;
			rr += region_rows;
		}
		
		Draw.graphics.lineStyle(0.5, 0x0000FF);
		rr = _r;
		cc = _c;
		while (rr <= mr) {
			while (cc <= mc) {
				if (getTile(rr, cc, 0) != 0) {
					collider = tileData.getCollider(1, TileCollider.ALL, cc * cell_width, rr * cell_height);
					Draw.debug_drawAABB(collider.getBounds(), camera);
				}
				cc++;
			}
			cc = c_start;
			rr++;
		}
		Draw.graphics.lineStyle(0, 0, 0);
		
	}


	/*
	 * Collision Functions
	 */	
	public function collidePoint( x:Float, y:Float, layer:Int = 0, cdata:CollisionData = null ) :Bool {
		
		_r = get_row( y );
		_c = get_col( x );
		var tileIndex = getTile(_r, _c, layer);
		if (tileIndex != 0) { // change this in the future
			directions = getTileDirections(_r, _c, layer);
			collider = tileData.getCollider(tileIndex, directions, _c * cell_width, _r * cell_height);
			return collider.collidePoint(x, y, cdata);
		}
		return false;
	}
	 
	public function collideAabb( aabb:AABB, layer:Int = 0, cdata:CollisionData = null ) :Bool {		
		
		var collides:Bool = false;
		
		_r = get_row( aabb.top - 1 );
		_c = get_col( aabb.left - 1 );
		mr = get_row( aabb.bottom + 1 );
		mc = get_col( aabb.right + 1 );
		if (_r < 0) { _r = 0; }
		if (_c < 0) { _c = 0; }
		if (mr > world_tile_rows) { mr = world_tile_rows; }
		if (mc > world_tile_cols) { mc = world_tile_cols; }
		c_start = _c;
		rr = _r;
		cc = _c;
		
		while (rr < mr + 1) {
			while (cc < mc + 1) {
				if (collideTile( rr, cc, aabb, layer, cdata )) {
					if (cdata != null) {
						cdata = cdata.setNext();
					}
					collides = true;
				}
				cc++;
			}
			cc = c_start;
			rr++;
		}
		if (cdata != null) {
			CollisionData.getFirst(cdata);
		}
		return collides;
	}
	
	/// TODO: change this so that it only collides on "exposed" edges (and not connected edges)
	private function collideTile( r:Int, c:Int, aabb:AABB, layer:Int, cdata:CollisionData ) :Bool 
	{
		var tileIndex = getTile(r, c, layer);
		if (tileIndex != 0) { // change this in the future
			directions = getTileDirections(r, c, layer);
			collider = tileData.getCollider(tileIndex, directions, c * cell_width, r * cell_height);
			return collider.collideAABB(aabb, cdata);
		}
		
		return false;
	}
	
	private var collider:Collider;
	private var directions:Int;
	
	/*
	 * Helper Functions
	 */
	
	private function reset_regions() :Void {
		for (r in 0...world_region_rows) {
			for (c in 0...world_region_cols) {
				index = get_index(r, c);
				
				for (i in 0...layer_count) {
					layers[i][index].resetTiles();
				}
			}
		}
	}
	
	// get the region index from the world row and world col
	private inline function get_index( r:Int, c:Int ) :Int { 
		return c + (r * world_region_cols); 
	} 
	
	private inline function get_index_at( x:Float, y:Float ) :Int 	{ 
		_r = get_row(y);
		_c = get_col(x); 
		return get_index(_r, _c); 
	}
	
	// get the region index from the tile row and tile col
	private inline function get_region_index( r:Int, c:Int ) :Int { 
		r = Math.floor(r / region_rows);
		c = Math.floor(c / region_cols);		
		return get_index(r, c); 
	}
	
	private inline function get_region_index_at( x:Float, y:Float ) :Int { 
		_r = get_region_row(y);
		_c = get_region_col(x);
		return get_index(_r, _c); 
	}
	
	private inline function get_tileBitmap() :BitmapData { return tileData.bitmapData; }
	private inline function get_tilesheet() :Tilesheet { return tileData.tilesheet; }
	
	
	/*
	 * private getters for public properties
	 */
	
	private static inline function get_width() :Int 		{ return region_width * world_region_cols; }
	private static inline function get_height() :Int 		{ return region_height * world_region_rows; }
	private static inline function get_region_width() :Int 	{ return cell_width * region_cols; }
	private static inline function get_region_height() :Int { return cell_height * region_rows; }
	private static inline function get_world_rows() :Int	{ return world_region_rows * region_rows; }
	private static inline function get_world_cols() :Int	{ return world_region_cols * region_cols; }	
	
	
	/*
	 * Reusable variables
	 */
	
	private var index:Int;
	private var _r:Int;
	private var rr:Int;
	private var _c:Int;
	private var cc:Int;
	private var c_start:Int;
	private var mr:Int;
	private var mc:Int;
	private var x_offset:Int;
	private var y_offset:Int;
}