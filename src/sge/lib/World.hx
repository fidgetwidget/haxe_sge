package sge.lib;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Rectangle;
import sge.core.Camera;
import sge.graphics.Draw;
import sge.physics.AABB;
import sge.physics.Collider;
import sge.physics.CollisionData;
import sge.physics.CollisionMath;

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
	
	public function init() :Void {
		
		for (i in 0...layer_count) {
			layers[i] = [];
			layers_data[i] = new BitmapData(world_region_cols, world_region_rows, false);
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
	
	public function loadAssets( tileData:TileData ) :Void {		
		
		this.tileData = tileData;
		
		var r = 0;
		var c = 0;
		var mr = Math.floor(tileBitmap.height / cell_height);
		var mc = Math.floor(tileBitmap.width / cell_width);
		while (r < mr) {
			while (c < mc) {
				tilesheet.addTileRect(new Rectangle(c * cell_width,  r * cell_height, cell_width, cell_height));
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
	
	/*
	 * Render Functions
	 */	
	public function render( camera:Camera ) :Void {
		
		// get the relevant row/col values
		_r = get_row( camera.bounds.top );
		_c = get_col( camera.bounds.left );		
		_m_r = get_row( camera.bounds.bottom) + 1;
		_m_c = get_col( camera.bounds.right) + 1;		
		if (_r < 0) { _r = 0; }
		if (_c < 0) { _c = 0; }		
		if (_m_r > world_tile_rows) { _m_r = world_tile_rows; }
		if (_m_c > world_tile_cols) { _m_c = world_tile_cols; }
		_c_start = _c;
		
		// clear the list of tiles to render
		_renderTiles.splice(0, _renderTiles.length);
		
		// add the relevant tiles to the list
		while ( _r < _m_r ) {
			while ( _c < _m_c ) {
				render_addTile(_r, _c, camera);
				_c++;
			}
			_c = _c_start;
			_r++;
		}
		
		// render the list
		renderTiles();
	}
	
	
	public function drawCursorTile( x:Float, y:Float, tile:Int, camera:Camera ) :Void {
		
		// test for a valid tileId
		if (tile < 0 || tile >= tile_type_count) { return; }
		
		// get the row/col value from the cursor position
		_r = get_row(y);
		_c = get_col(x);
		
		// draw the tile
		tilesheet.drawTiles(Draw.graphics, 
		 [
		 (_c * cell_width) - camera.x,
		 (_r * cell_height) - camera.y, 
		 tile
		 ]);
		// draw a line around it 
		Draw.graphics.lineStyle(0.3, 0x000000);
		Draw.graphics.drawRect((_c * cell_width) - camera.x, (_r * cell_height) - camera.y, cell_width, cell_height);
		Draw.graphics.lineStyle(0, 0);
	}
	
	/// Draw the region lines
	/// TODO: draw the collision edges
	public function drawDebug( camera:Camera ) :Void {
		
		// get the relevant row/col values		
		_r = get_row( camera.bounds.top );
		_c = get_col( camera.bounds.left );
		_m_r = get_row( camera.bounds.bottom) + 1;
		_m_c = get_col( camera.bounds.right) + 1;
		if (_r < 0) { _r = 0; }
		if (_c < 0) { _c = 0; }
		if (_m_r > world_tile_rows) { _m_r = world_tile_rows; }
		if (_m_c > world_tile_cols) { _m_c = world_tile_cols; }
		_c_start = _c;
		
		// set the region row/col offset
		rr = _r - _r % region_rows;
		cc = _c - _c % region_cols;
		
		// draw the lines
		Draw.graphics.lineStyle(0.5, 0xFF0000);		
		while (rr <= _m_r) {
			while (cc <= _m_c) {
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
		var collider:Collider;
		rr = _r;
		cc = _c;
		while (rr <= _m_r) {
			while (cc <= _m_c) {
				if (getTile(rr, cc, 0) != 0) {
					collider = tileData.getCollider(1, cc * cell_width, rr * cell_height);
					Draw.debug_drawAABB(collider.getBounds(), camera);
				}
				cc++;
			}
			cc = _c_start;
			rr++;
		}
		Draw.graphics.lineStyle(0, 0, 0);
		
	}
	
	/// Render Helper
	private function render_addTile( r, c, camera:Camera ) :Void {
		_renderIndex = getTile(r, c);
		if (_renderIndex > 0) {
			_renderTiles.push( (c * cell_width) - camera.x  );
			_renderTiles.push( (r * cell_height) - camera.y );
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
	public function collidePoint( x:Float, y:Float, layer:Int = 0, cdata:CollisionData = null ) :Bool {
		
		_r = get_row( y );
		_c = get_col( x );
		var tileIndex = getTile(_r, _c, layer);
		if (tileIndex != 0) { // change this in the future
			var collider = tileData.getCollider(tileIndex, _c * cell_width, _r * cell_height);
			return collider.collidePoint(x, y, cdata);
		}
		return false;
	}
	 
	public function collideAabb( aabb:AABB, layer:Int = 0, cdata:CollisionData = null ) :Bool {		
		
		var collides:Bool = false;
		
		_r = get_row( aabb.top ) - 1;
		_c = get_col( aabb.left ) - 1;
		_m_r = get_row( aabb.bottom ) + 1;
		_m_c = get_col( aabb.right ) + 1;
		if (_r < 0) { _r = 0; }
		if (_c < 0) { _c = 0; }
		if (_m_r > world_tile_rows) { _m_r = world_tile_rows; }
		if (_m_c > world_tile_cols) { _m_c = world_tile_cols; }
		_c_start = _c;
		rr = _r;
		cc = _c;
		
		while (rr < _m_r + 1) {
			while (cc < _m_c + 1) {
				if (collideTile( rr, cc, aabb, layer, cdata )) {
					if (cdata != null) {
						cdata = cdata.setNext();
					}
					collides = true;
				}
				cc++;
			}
			cc = _c_start;
			rr++;
		}
		if (cdata != null) {
			CollisionData.getFirst(cdata);
		}
		return collides;
	}
	
	private function collideTile( r:Int, c:Int, aabb:AABB, layer:Int, cdata:CollisionData ) :Bool 
	{
		var tileIndex = getTile(r, c, layer);
		if (tileIndex != 0) { // change this in the future
			var collider = tileData.getCollider(tileIndex, c * cell_width, r * cell_height);
			return collider.collideAABB(aabb, cdata);
		}
		
		return false;
	}
	
	
	
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
	private var _c_start:Int;
	private var _m_r:Int;
	private var _m_c:Int;
	private var x_offset:Int;
	private var y_offset:Int;
}