package sge.world;

import openfl.display.Tilesheet;
import sge.collision.AABB;
import sge.collision.Collider;
import sge.collision.CollisionData;
import sge.collision.TileCollider;
import sge.graphics.Camera;
import sge.graphics.Draw;
import sge.graphics.Tileframes;
import sge.graphics.Tileset;

/**
 * A World of Tiles
 * 
 * TODO: convert this to a "TileScene" class, rather than something contained within a scene? * 
 * 
 * @author fidgetwidget
 */
class World
{
	/*
	 * Properties
	 */
	public var WIDTH				: Int;
	public var HEIGHT				: Int;
	public var CELL_WIDTH 			: Int;
	public var CELL_HEIGHT 			: Int;
	public var REGION_WIDTH			: Int;
	public var REGION_HEIGHT		: Int;
	
	public var REGION_ROWS 			: Int; // number of rows per region
	public var REGION_COLS 			: Int;	
	public var WORLD_REGION_ROWS 	: Int; // number of rows OF regions
	public var WORLD_REGION_COLS 	: Int;
	public var ROWS					: Int;
	public var COLS					: Int;
	
	public var layers				: Array< Array<Region> >; // outer array is the layer, inner array is the grid of regions
	public var layer_count			: Int;
	public var initialized			(default, null) : Bool;
	
	/*
	 * Members 
	 */	
	private var tileset				: Tileset;
	private var tileframes			: Tileframes;
	
	// Memory Savers
	private var _collider			: Collider;
	private var _tile				: Tile;
	private var _index				: Int;	
	private var _xOffset			: Int;
	private var _yOffset			: Int;	
	private var _r					: Int;
	private var _c					: Int;
	private var _rr					: Int;
	private var _cc					: Int;
	private var _cStart				: Int;
	private var _mr					: Int;
	private var _mc					: Int;
	private var _xx					: Float;
	private var _yy					: Float;
	

	public function new( width:Int = 1024, height:Int = 1024, cellWidth:Int = 16, cellHeight:Int = 16, regionWidth:Int = 256, regionHeight:Int = 256 ) 
	{
		WIDTH = width;
		HEIGHT = height;
		CELL_WIDTH = cellWidth;
		CELL_HEIGHT = cellHeight;
		REGION_WIDTH = regionWidth;
		REGION_HEIGHT = regionHeight;
		
		ROWS = Math.floor( height / cellHeight );
		COLS = Math.floor( width / cellWidth );
		WORLD_REGION_ROWS = Math.floor( height / regionHeight );
		WORLD_REGION_COLS = Math.floor( width / regionWidth );
		REGION_ROWS = Math.floor( ROWS / WORLD_REGION_ROWS );
		REGION_COLS = Math.floor( COLS / WORLD_REGION_COLS );
		
		layers = [];
		initialized = false;
	}
	
	
	// Initialize the world's arrays, etc
	public function init( tileset:Tileset, layer_count:Int = 2 ) :Void {
		
		this.tileset = tileset;		
		tileframes = new Tileframes(tileset.tilesheet);		
		this.layer_count = layer_count;
		
		for (i in 0...layer_count) {
			layers[i] = [];
		}
		
		for (r in 0...WORLD_REGION_ROWS) {
			for (c in 0...WORLD_REGION_COLS) {
				_index = get_index(r, c);
				_xOffset = c * REGION_WIDTH;
				_yOffset = r * REGION_HEIGHT;				
				for (i in 0...layer_count) {
					layers[i][_index] = new Region(_xOffset, _yOffset, i, this);
				}
			}
		}		
		initialized = true;
	}
	
	public function loadRegion( r:Int, c:Int ) :Void 
	{
		_index = get_index(r, c);
		for (i in 0...layer_count) {
			layers[i][_index].load();
		}
	}
	
	public function saveRegion( r:Int, c:Int ) :Void 
	{
		_index = get_index(r, c);
		for (i in 0...layer_count) {
			layers[i][_index].save();
		}
	}	
	
	/*
	 * Render Functions
	 */	
	public function render( camera:Camera ) :Void {
		
		// get the relevant row/col values
		_r = get_row( camera.bounds.top );
		_c = get_col( camera.bounds.left );		
		_mr = get_row( camera.bounds.bottom) + 1;
		_mc = get_col( camera.bounds.right) + 1;		
		if (_r < 0) { _r = 0; }
		if (_c < 0) { _c = 0; }		
		if (_mr > ROWS) { _mr = ROWS; }
		if (_mc > COLS) { _mc = COLS; }
		_cStart = _c;
		
		// clear the list of tiles to render
		tileframes.clear();
		
		// add the relevant tiles to the list
		while ( _r < _mr ) {
			while ( _c < _mc ) {
				_tile = getTile(_r, _c);
				if (_tile != Tile.EMPTY) {
					_tile.render(_r, _c, camera, tileframes);
				}				
				_c++;
			}
			_c = _cStart;
			_r++;
		}
		
		// render the list
		tileframes.drawTiles();
	}
	
	
	public function drawCursorTile( x:Float, y:Float, tile:Int, camera:Camera ) :Void {
		
		// test for a valid tileId
		if (tile < 0 || tile >= tileset.tileCount ) { return; }
		
		// get the row/col value from the cursor position
		_r = get_row(y);
		_c = get_col(x);
		_xx = (_c * CELL_WIDTH) - camera.x;
		_yy = (_r * CELL_HEIGHT) - camera.y;
		// draw the tile
		tileset.tilesheet.drawTiles(Draw.graphics, [ _xx, _yy, tile ]);
		// draw a line around it 
		Draw.graphics.lineStyle(0.3, 0x000000);
		Draw.graphics.drawRect(_xx, _yy, CELL_WIDTH, CELL_HEIGHT);
		Draw.graphics.lineStyle(0, 0);
	}
	
	
	/*
	 * Collision Functions
	 */	
	public function collidePoint( x:Float, y:Float, layer:Int = 0, cdata:CollisionData = null ) :Bool {
		
		_r = get_row( y );
		_c = get_col( x );
		var tile = getTile(_r, _c, layer);
		if (tile != Tile.EMPTY) { // change this in the future
			_collider = tile.getCollider(_r, _c, layer);
			return _collider.collidePoint(x, y, cdata);
		}
		return false;
	}
	 
	public function collideAabb( aabb:AABB, layer:Int = 0, cdata:CollisionData = null ) :Bool {		
		
		var collides:Bool = false;
		
		_r = get_row( aabb.top - 1 );
		_c = get_col( aabb.left - 1 );
		_mr = get_row( aabb.bottom + 1 );
		_mc = get_col( aabb.right + 1 );
		if (_r < 0) { _r = 0; }
		if (_c < 0) { _c = 0; }
		if (_mr > ROWS) { _mr = ROWS; }
		if (_mc > COLS) { _mc = COLS; }
		_cStart = _c;
		_rr = _r;
		_cc = _c;
		
		while (_rr < _mr + 1) {
			while (_cc < _mc + 1) {
				if (collideTile( _rr, _cc, aabb, layer, cdata )) {
					if (cdata != null) {
						cdata = cdata.setNext();
					}
					collides = true;
				}
				_cc++;
			}
			_cc = _cStart;
			_rr++;
		}
		if (cdata != null) {
			CollisionData.getFirst(cdata);
		}
		return collides;
	}
	
	private function collideTile( r:Int, c:Int, aabb:AABB, layer:Int, cdata:CollisionData ) :Bool 
	{
		var tile = getTile(r, c, layer);
		if (tile != Tile.EMPTY) { // change this in the future
			_collider = tile.getCollider(r, c, layer);
			return _collider.collideAABB(aabb, cdata);
		}
		
		return false;
	}
	
	
	/// Helper Functions
	private function reset_regions() :Void {
		for (r in 0...WORLD_REGION_ROWS) {
			for (c in 0...WORLD_REGION_COLS) {
				_index = get_index(r, c);
				
				for (i in 0...layer_count) {
					layers[i][_index].resetTiles();
				}
			}
		}
	}
	
	/// Getters & Setters
	public function getTileAt( x:Float, y:Float, layer:Int = 0 ) :Tile { 
		_index = get_region_index_at(x, y);
		if (_index < 0 || _index > (WORLD_REGION_ROWS * WORLD_REGION_COLS) - 1) { return Tile.EMPTY; }
		return layers[layer][_index].getTileAt(x, y);
	}	
	public function setTileAt( x:Float, y:Float, tile:Tile, layer:Int = 0 ) :Void { 
		_index = get_region_index_at(x, y);
		if (_index < 0 || _index > (WORLD_REGION_ROWS * WORLD_REGION_COLS) - 1) { return; }
		layers[layer][_index].setTileAt(x, y, tile);
	}
	public function makeTileAt( x:Float, y:Float, frameIndex:Int, layer:Int = 0 ) :Void 
	{
		if (frameIndex < 0) { setTileAt(x, y, null, layer); }
		setTileAt(x, y, Tile.makeTile(this, frameIndex), layer);
	}
	
	public inline function get_row( y:Float ) :Int 			{ return Math.floor( y / CELL_HEIGHT);  }
	public inline function get_col( x:Float ) :Int 			{ return Math.floor( x / CELL_WIDTH);   }
	public inline function get_region_row( y:Float ) :Int 	{ return Math.floor( y / REGION_HEIGHT); }
	public inline function get_region_col( x:Float ) :Int 	{ return Math.floor( x / REGION_WIDTH);  }
	
	/**
	 * Get the tile at the given world row and col position
	 * @param	r 	: the world row position
	 * @param	c 	: the world column position
	 * @param	bg	: whether or not you want the background tile (default false)
	 * @return the tile type id value at the given row and col position
	 */
	public function getTile( r:Int, c:Int, layer:Int = 0 ) :Tile {
		_index = get_region_index(r, c);
		if (_index < 0 || _index > (WORLD_REGION_ROWS * WORLD_REGION_COLS) - 1) { return Tile.EMPTY; }
		r %= REGION_ROWS;
		c %= REGION_COLS;
		return layers[layer][_index].getTile(r, c);
	}
	/**
	 * Set the tile at the given world row and col position
	 * @param	r	: the world row position
	 * @param	c	: the world column position
	 * @param	tile: the tile value to set 
	 * @param	bg	: whether or not to set the background tile (default false)
	 */
	public function setTile( r:Int, c:Int, tile:Tile, layer:Int = 0 ) :Void {
		_index = get_region_index(r, c);
		if (_index < 0 || _index > (WORLD_REGION_ROWS * WORLD_REGION_COLS) - 1) { return; }
		r %= REGION_ROWS;
		c %= REGION_COLS;
		layers[layer][_index].setTile(r, c, tile);
	}
	
	public function makeTile( r:Int, c:Int, frameIndex:Int, layer:Int = 0 ) :Void {
		if (frameIndex < 0) { setTile( r, c, null, layer ); }
		setTile( r, c, Tile.makeTile(this, frameIndex), layer );
	}
	
	
	// get the region index from the world row and world col
	private inline function get_index( r:Int, c:Int ) :Int { 
		return c + (r * WORLD_REGION_COLS); 
	} 
	
	private inline function get_index_at( x:Float, y:Float ) :Int 	{ 
		_r = get_row(y);
		_c = get_col(x); 
		return get_index(_r, _c); 
	}
	
	// get the region index from the tile row and tile col
	private inline function get_region_index( r:Int, c:Int ) :Int { 
		r = Math.floor(r / REGION_ROWS);
		c = Math.floor(c / REGION_COLS);
		return get_index(r, c); 
	}
	
	private inline function get_region_index_at( x:Float, y:Float ) :Int { 
		_r = get_region_row(y);
		_c = get_region_col(x);
		return get_index(_r, _c); 
	}
	
}