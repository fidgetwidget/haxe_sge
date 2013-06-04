package sge.world;

import nme.Assets;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Rectangle;
import sge.geom.Box;
import sge.graphics.AssetManager;
import sge.graphics.Tileset;
import sge.physics.BoxCollider;
import sge.physics.Collider;
import sge.physics.TileCollider;

/**
 * TileData
 * the details that describe the way tiles in a World should behave
 * stores the tile size (width/height) and tilesheet
 * 
 * TODO: set the collision array with bitmap data (the alpha in the part of the bitmapData being set
 * TODO: add more tile collision types (more than just empty & solid)
 * @author fidgetwidget
 */

class TileData 
{
	
	public var EMPTY_TILE:Int = 0;
	public var SOLID_TILE:Int = 1;
	// TODO: add more tile state types (slopes... other behaviours?)
	
	public var tileWidth		:Int;
	public var tileHeight		:Int;
	public var tileset			:Tileset;
	
	public var bitmapData(get_bitmapData, null):BitmapData;	
	public var tilesheet(get_tilesheet, null):Tilesheet;	
	public var tileTypeCount(get_tileTypeCount, null):Int;
	
	private var collisionData	:Array<Int>; 
	

	public function new( assetString:String, tileWidth:Int = 16, tileHeight:Int = 16 ) 
	{
		tileset = new Tileset( AssetManager.getBitmap(assetString) );
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		
		collisionData = [];
		
		_box = new Box(tileWidth * 0.5, tileHeight * 0.5, tileWidth, tileHeight);
		_collider = new TileCollider(_box);
		_collider.useCenterPosition = false;
		
		tileset.init(tileWidth, tileHeight, Std.int(tileset.source.width / tileWidth), Std.int(tileset.source.height / tileHeight));
		for (i in 1...tileTypeCount) {
			collisionData[i] = SOLID_TILE;
		}	
		collisionData[0] = EMPTY_TILE; // default, temp value 	
		
	}
	
	/// TODO: move the logic for drawing a single tile here
	
	
	
	/// get a colllider for the given tileIndex at the given position
	public function getCollider( tileIndex:Int, dir:Int, x:Float, y:Float ) :Collider
	{
		switch (collisionData[tileIndex]) {
			case EMPTY_TILE:
				return null;
			case SOLID_TILE:
				_box.x = x;
				_box.y = y;
				_collider.directions = dir;
				return _collider;
		}
		
		// fall back
		return null;
	}
	private var _box:Box;
	private var _collider:TileCollider;
	
	
	private function get_bitmapData() :BitmapData { return tileset.source; }
	private function get_tilesheet() :Tilesheet { return tileset.tilesheet; }
	private function get_tileTypeCount() :Int { return tileset.tileCount; }
	
}