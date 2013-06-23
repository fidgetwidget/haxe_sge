package sge.world;

import haxe.ds.IntMap;
import sge.collision.Collider;
import sge.collision.TileCollider;
import sge.geom.Box;
import sge.graphics.Camera;
import sge.graphics.Tileframes;

/**
 * Tile Type Class
 * 
 * TODO: change the collider to support multiple tile shapes
 * 
 * @author fidgetwidget
 */
class Tile
{
	private var world		:World;
	private var frameIndex	:Int;
	
	/// Memory Savers
	private var _xx			:Float;
	private var _yy			:Float;
	private var _direction	:Int;
	private var _box		:Box;
	private var _collider	:TileCollider;

	public function new( world:World, frameIndex:Int )
	{
		this.world = world;
		this.frameIndex = frameIndex;
		_box = new Box(0, 0, world.CELL_WIDTH, world.CELL_HEIGHT);
		_collider = new TileCollider(_box);
		_collider.useCenterPosition = false;
	}
	
	public function render( r:Int, c:Int, camera:Camera, tileframes:Tileframes ) :Void 
	{
		_xx = (c * world.CELL_WIDTH) - camera.x;
		_yy = (r * world.CELL_HEIGHT) - camera.y;
		tileframes.addFrame(_xx, _yy, frameIndex);
	}
	
	public function getDirections( r:Int, c:Int, layer:Int = 0 ) :Int 
	{
		_direction = 0;
		if (world.getTile(r - 1, c, layer) == Tile.EMPTY) {
			_direction |= TileCollider.UP;
		}
		if (world.getTile(r + 1, c, layer) == Tile.EMPTY) {
			_direction |= TileCollider.DOWN;
		}
		if (world.getTile(r, c - 1, layer) == Tile.EMPTY) {
			_direction |= TileCollider.LEFT;
		}
		if (world.getTile(r, c + 1, layer) == Tile.EMPTY) {
			_direction |= TileCollider.RIGHT;
		}
		return _direction;
	}
	public function getCollider( r:Int, c:Int, layer:Int = 0 ) :Collider 
	{
		_collider.directions = getDirections( r, c, layer );
		_box.x = c * world.CELL_WIDTH;
		_box.y = r * world.CELL_HEIGHT;
		return _collider;
	}
	
	public static function makeTile( world:World, frameIndex:Int ) :Tile 
	{
		if (_tiles == null) {
			_tiles = new IntMap<Tile>();
		}
		if (!_tiles.exists( frameIndex )) {
			_tiles.set(frameIndex, new Tile(world, frameIndex));
		}
		return _tiles.get(frameIndex);
	}
	
	private static var _tiles:IntMap<Tile>;
	
	public static var EMPTY:Tile = null;
	
}