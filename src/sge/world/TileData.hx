package sge.world;

import nme.Assets;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Rectangle;
import sge.geom.Box;
import sge.graphics.AssetManager;
import sge.physics.BoxCollider;
import sge.physics.Collider;

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
	public var tileTypeCount	:Int;
	public var bitmapData		:BitmapData;	
	public var tilesheet		:Tilesheet;	
	
	private var collisionData	:Array<Int>; 

	public function new( assetString:String, tileWidth:Int = 16, tileHeight:Int = 16 ) 
	{
		bitmapData = AssetManager.getBitmap(assetString);
		tilesheet = new Tilesheet(bitmapData);
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		
		collisionData = [];
		
		_box = new Box(tileWidth * 0.5, tileHeight * 0.5, tileWidth, tileHeight);
		_boxCollider = new BoxCollider(_box);
		_boxCollider.useCenterPosition = false;
		
		initTilesheet();		
	}
	
	public function initTilesheet() :Void {
		var r = 0;
		var c = 0;
		var mr = Math.floor(bitmapData.height / tileHeight);
		var mc = Math.floor(bitmapData.width / tileWidth);
		tileTypeCount = 0; // doubles as the current tile index
		while (r < mr) {
			while (c < mc) {
				var rect = new Rectangle(c * tileWidth,  r * tileHeight, tileWidth, tileHeight);
				tilesheet.addTileRect(rect);
				
				// TODO: load the collision data, not just set all to SOLID
				collisionData[tileTypeCount] = SOLID_TILE; // default, temp value 
				
				tileTypeCount++;
				c++;
			}
			r++;
			c = 0;
		}		
		collisionData[0] = EMPTY_TILE; // default, temp value 
	}
	
	/// TODO: move the logic for drawing a single tile here
	
	/// get a colllider for the given tileIndex at the given position
	public function getCollider( tileIndex:Int, x:Float, y:Float ) :Collider
	{
		switch (collisionData[tileIndex]) {
			case EMPTY_TILE:
				return null;
			case SOLID_TILE:
				_box.x = x;
				_box.y = y;
				return _boxCollider;
		}
		
		// fall back
		return null;
	}
	private var _box:Box;
	private var _boxCollider:BoxCollider;
	
}