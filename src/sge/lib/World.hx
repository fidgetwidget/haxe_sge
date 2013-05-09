package sge.lib;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Rectangle;
import sge.core.Camera;
import sge.graphics.Draw;
import sge.physics.AABB;
import sge.physics.CollisionData;

#if (!js)
import sge.core.Debug;
#end

/**
 * ...
 * @author fidgetwidget
 */

class World 
{
	/*
	 * Static Properties 
	 */
	
	/// Used in the constructor
	public static inline var region_rows 	: Int = 128;
	public static inline var region_cols 	: Int = 64;
	
	/// Used in the init call
	public static inline var tile_width 	: Int = 16;
	public static inline var tile_height 	: Int = 16;	
	public static var layer_count			: Int = 2;
	
	/// Set by the constructor
	public static var world_rows 			: Int = 0;
	public static var world_cols 			: Int = 0;
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
	public var layers:Array<Array<Region>>;
	public var layers_data:Array<BitmapData>;
	public var tileData:BitmapData;
	public var tilesheet:Tilesheet;
	public var initialized(default, null):Bool = false;
	

	/**
	 * Constructor
	 */
	public function new( tile_rows:Int, tile_cols:Int, init_now:Bool = true ) 
	{
		world_rows = Math.floor(tile_rows / region_rows);
		world_cols = Math.floor(tile_cols / region_cols);
		
		layers = [];
		layers_data = [];
		
		_renderTiles = [];
		
		if (init_now) {
			init();
		}
	}
	
	public function init() :Void {
		
		for (i in 0...layer_count) {
			layers[i] = [];
			layers_data[i] = new BitmapData(world_cols, world_rows, false);
		}
		
		for (r in 0...world_rows) {
			for (c in 0...world_cols) {
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
	
	public function loadAssets() :Void {		
		tileData = Assets.getBitmapData("img/tiles.png");
		tilesheet = new Tilesheet(tileData);
		var r = 0;
		var c = 0;
		var mr = Math.floor(tileData.height / tile_height);
		var mc = Math.floor(tileData.width / tile_width);
		while (r < mr) {
			while (c < mc) {
				tilesheet.addTileRect(new Rectangle(c * tile_width,  r * tile_height, tile_width, tile_height));
				tile_type_count++;
				c++;
			}
			r++;
			c = 0;
		}
	}
	
	private function loadRegion(r:Int, c:Int) :Void {
		
	}
	
	private function saveRegion(r:Int, c:Int) :Void {
		
	}
	
	
	/*
	 * Public functions
	 */
	
	public function getTileAt( x:Float, y:Float, layer:Int = 0 ) :Int { 
		index = get_region_index_at(x, y);
		if (index < 0 || index > (world_rows * world_cols) - 1) { return 0; }
		return layers[layer][index].getTileAt(x, y);
	}
	public function setTileAt( x:Float, y:Float, tile:Int, layer:Int = 0 ) :Void { 
		index = get_region_index_at(x, y);
		if (index < 0 || index > (world_rows * world_cols) - 1) { return; }
		layers[layer][index].setTileAt(x, y, tile);
	}
	
	public inline function get_row( y:Float ) :Int 			{ return Math.floor( y / tile_height);  }
	public inline function get_col( x:Float ) :Int 			{ return Math.floor( x / tile_width);   }
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
		if (index < 0 || index > (world_rows * world_cols) - 1) { return 0; }
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
		if (index < 0 || index > (world_rows * world_cols) - 1) { return; }
		r %= region_rows;
		c %= region_cols;
		layers[layer][index].setTile(r, c, tile);
	}
	
	/*
	 * Render Functions
	 */	
	public function render( camera:Camera ) :Void {
		
		_r = get_row( camera.bounds.top );
		_c = get_col( camera.bounds.left );
		_c_start = _c;
		_m_r = get_row( camera.bounds.bottom) + 1;
		_m_c = get_col( camera.bounds.right) + 1;
		
		if (_r < 0) { _r = 0; }
		if (_c < 0) { _c = 0; }		
		if (_m_r > world_tile_rows) { _m_r = world_tile_rows; }
		if (_m_c > world_tile_cols) { _m_c = world_tile_cols; }
		
		_renderTiles.splice(0, _renderTiles.length);
		
		while ( _r < _m_r ) {
			while ( _c < _m_c ) {
				addTile(_r, _c, camera);
				_c++;
			}
			_c = _c_start;
			_r++;
		}
		
		renderTiles();
	}
	
	
	public function drawCursorTile( x:Float, y:Float, tile:Int, camera:Camera ) :Void {
		if (tile < 0 || tile >= tile_type_count) { return; }
		
		_r = get_row(y);
		_c = get_col(x);
		tilesheet.drawTiles(Draw.graphics, 
		 [
		 (_c * tile_width) - camera.x,
		 (_r * tile_height) - camera.y, 
		 tile
		 ]);
		 
		Draw.graphics.lineStyle(0.3, 0x000000);
		Draw.graphics.drawRect((_c * tile_width) - camera.x, (_r * tile_height) - camera.y, tile_width, tile_height);
		Draw.graphics.lineStyle(0, 0);
	}
	
	public function drawDebug( camera:Camera ) :Void {
		
		Draw.graphics.lineStyle(0.5, 0xFF0000);
		
		_r = get_row( camera.bounds.top );
		_c = get_col( camera.bounds.left );
		_c_start = _c;
		_m_r = get_row( camera.bounds.bottom) + 1;
		_m_c = get_col( camera.bounds.right) + 1;
		rr = _r - _r % region_rows;
		cc = _c - _c % region_cols;
		
		while (rr < _m_r + 1) {
			while (cc < _m_c + 1) {
				Draw.graphics.moveTo( (cc * tile_width) - camera.x, 0 );
				Draw.graphics.lineTo( (cc * tile_width) - camera.x, camera.height );
				
				Draw.graphics.moveTo( 0, (rr * tile_height) - camera.y );
				Draw.graphics.lineTo( camera.width, (rr * tile_height) - camera.y );
				cc += region_cols;
			}
			cc = 0;
			rr += region_rows;
		}
		Draw.graphics.lineStyle(0, 0, 0);
	}
	
	/// Render Helper
	private function addTile( r, c, camera:Camera ) :Void {
		_renderIndex = getTile(r, c);
		if (_renderIndex > 0) {
			_renderTiles.push( (c * tile_width) - camera.x  );
			_renderTiles.push( (r * tile_height) - camera.y );
			_renderTiles.push( _renderIndex );	
		}
	}	
	private function renderTiles() :Void {
		tilesheet.drawTiles(Draw.graphics, _renderTiles);
	}
	private var _renderIndex:Int = 0;
	private var _renderTiles:Array<Float>;

	/*
	 * Collision Functions
	 */	
	public function collidePoint( x:Float, y:Float, cData:CollisionData = null ) :Bool {
		
		
		return false;
	}
	 
	public function collideAabb( aabb:AABB, cData:CollisionData = null ) :Bool {		
		
		
		return false;
	}
	
	
	
	/*
	 * Helper Functions
	 */
	
	private function reset_regions() :Void {
		for (r in 0...world_rows) {
			for (c in 0...world_cols) {
				index = get_index(r, c);
				
				for (i in 0...layer_count) {
					layers[i][index].resetTiles();
				}
			}
		}
	}
	
	// get the region index from the world row and world col
	private inline function get_index( r:Int, c:Int ) :Int { 
		return c + (r * world_cols); 
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
	
	
	/*
	 * private getters for public properties
	 */
	
	private static inline function get_width() :Int 		{ return region_width * world_cols; }
	private static inline function get_height() :Int 		{ return region_height * world_rows; }
	private static inline function get_region_width() :Int 	{ return tile_width * region_cols; }
	private static inline function get_region_height() :Int 	{ return tile_height * region_rows; }
	private static inline function get_world_rows() :Int	{ return world_rows * region_rows; }
	private static inline function get_world_cols() :Int	{ return world_cols * region_cols; }	
	
	
	/*
	 * Reusable variables
	 */
	
	private var index:Int;
	private var _r:Int;
	private var rr:Int;
	private var _c:Int;
	private var cc:Int;
	private var _c_start:Int;
	private var _m_r:Int;
	private var _m_c:Int;
	private var x_offset:Int;
	private var y_offset:Int;
}