package sge.world;

/**
 * ...
 * @author fidgetwidget
 */
class Region
{
	
	/*
	 * Properties
	 */
	public var x(default, null):Int;	// Positional Offset
	public var y(default, null):Int;
	public var cells:Array<Tile>;
	
	public var world:World;
	public var layer:Int;				// World Layer
	
	public var isDirty(default, null):Bool;
	public var isSaving(default, null):Bool;
	
	/*
	 * Members 
	 */
	

	/**
	 * Constructor
	 * @param	x
	 * @param	y
	 */
	public function new( x:Int, y:Int, layer:Int, world:World ) 
	{
		cells = [];
		set( x, y, layer, world );
	}
	
	// Set values for recycled regions
	public function set( x:Int, y:Int, layer:Int, world:World ) :Void {	
		
		this.x = x;
		this.y = y;
		this.layer = layer;
		this.world = world;
		
		isDirty = false;
		isSaving = false;
		
		resetTiles();
	}
	
	public function load() :Void {
		// TODO: set the tiles from a file.
	}
	
	public function save() :Void {
		// TODO: save the region state to a file.
	}
	
	public function resetTiles() :Void {
		for (r in 0...world.REGION_ROWS) {
			for (c in 0...world.REGION_COLS) {
				setTile(r, c, Tile.EMPTY);
			}
		}
	}
	
	/*
	 * Get & Set Tiles
	 */
	
	// returns the fixed index of the row and column passed
	public function setTile( r:Int, c:Int, tile:Tile ) :Int {
		var index = get_index(r, c);
		cells[index] = tile;
		isDirty = true;
		return index;
	}
	
	public function getTile( r:Int, c:Int ) :Tile {
		var index = get_index(r, c);
		return cells[index];
	}
	
	public function setTileAt( x:Float, y:Float, tile:Tile ) :Int {
		if (check_bounds( x, y )) {
			var r = Math.floor( (y - this.y) / world.CELL_HEIGHT);
			var c = Math.floor( (x - this.x) / world.CELL_WIDTH);
			return setTile( r, c, tile );
		}
		return -1; // not set
	}
	
	public function getTileAt( x:Float, y:Float ) :Tile {
		if (check_bounds( x, y )) {
			var r = Math.floor( (y - this.y) / world.CELL_HEIGHT);
			var c = Math.floor( (x - this.x) / world.CELL_WIDTH);
			return getTile( r, c );
		}
		return null;
	}
	
	/*
	 * Helper Functions
	 */
	private inline function check_bounds( x:Float, y:Float ) :Bool {
		return ( 
		 ( x > this.x && x < this.x + world.REGION_WIDTH ) && 
		 ( y > this.y && y < this.y + world.REGION_HEIGHT ) );
	}
	
	private inline function get_index( r:Int, c:Int ) :Int 			{ return c + (r * world.REGION_ROWS); }
	private inline function get_index_at( x:Float, y:Float ) :Int 	{ return get_index( get_row(y), get_col(x) ); }
	private inline function get_row( y:Float ) :Int 				{ return Math.floor( y / world.CELL_HEIGHT ); }
	private inline function get_col( x:Float ) :Int 				{ return Math.floor( x / world.CELL_WIDTH ); }	
	
	
	/*
	 * IRecycleable 
	 */
	public function free() :Void 
	{		
		// TODO: clear the cells
		x = 0;
		y = 0;
		layer = 0;
		world = null;
		isDirty = false;
		isSaving = false;
		_free = true;
	}
	public function get_free() :Bool { return _free; }
	public function set_free( free:Bool ) :Bool { return _free = free; }
	private var _free:Bool = false;
	
}