package sge.lib;

/**
 * ...
 * @author fidgetwidget
 */

class Region 
{		
	/*
	 * Properties
	 */
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var tiles:Array<Int>;
	public var world:World;
	public var layer:Int;
	public var isDirty(default, null):Bool = false;
	public var isSaving(default, null):Bool = false;
	
	
	/**
	 * Constructor
	 * @param	x
	 * @param	y
	 */
	public function new( x:Int, y:Int, layer:Int, world:World ) 
	{
		tiles = [];
		this.x = x;
		this.y = y;
		this.layer = layer;
		this.world = world;
		resetTiles();
	}
	
	public function free() :Void {
		x = 0;
		y = 0;
		layer = 0;
		//tiles.splice(0, tiles.length);
	}
	
	public function set( x:Int, y:Int, layer:Int ) :Void {
		this.x = x;
		this.y = y;
		this.layer = layer;
	}
	
	/**
	 * It uses the world bitmap data, and the current offset position to set the tiles from that source.
	 */
	public function setTiles() :Void {
		//TODO: set the tiles array using bitmap data in the world.
	}
	/**
	 * Writes the current state of the region to the world bitmap data
	 */
	public function save() :Void {
		isDirty = false;
		isSaving = true;
	}
	
	public function resetTiles() :Void {
		for (r in 0...World.region_rows) {
			for (c in 0...World.region_cols) {
				setTile(r, c, 0);
			}
		}
	}
	
	/*
	 * get and set via row and column
	 */
	
	// returns the fixed index of the row and column passed
	public function setTile( r:Int, c:Int, tile:Int ) :Int {
		var index = get_index(r, c);
		tiles[index] = tile;
		isDirty = true;
		return index;
	}
	
	public function getTile( r:Int, c:Int ) :Int {
		var index = get_index(r, c);
		return tiles[index];
	}
	
	/*
	 * get and set via world position
	 */
	public function setTileAt( x:Float, y:Float, tile:Int ) :Int {
		if (check_bounds( x, y )) {
			var r = Math.floor( (y - this.y) / World.tile_height);
			var c = Math.floor( (x - this.x) / World.tile_width);
			return setTile( r, c, tile );
		}
		return -1;
	}
	
	public function getTileAt( x:Float, y:Float ) :Int {
		if (check_bounds( x, y )) {
			var r = Math.floor( (y - this.y) / World.tile_height);
			var c = Math.floor( (x - this.x) / World.tile_width);
			return getTile( r, c );
		}
		return -1;
	}
	
	
	/*
	 * Helper Functions
	 */
	inline function check_bounds( x:Float, y:Float ) :Bool {
		return ( 
		 ( x > this.x && x < this.x + World.region_width ) && 
		 ( y > this.y && y < this.y + World.region_height ) );
	}
	
	inline function get_index( r:Int, c:Int ) :Int 			{ return c + (r * World.region_rows); }
	inline function get_index_at( x:Float, y:Float ) :Int 	{ return get_index( get_row(y), get_col(x) ); }
	inline function get_row( y:Float ) :Int 				{ return Math.floor( y / World.tile_height ); }
	inline function get_col( x:Float ) :Int 				{ return Math.floor( x / World.tile_width ); }
}