///****************************************
/// DEPRICATED (kept for reference)
///****************************************

//package sge.lib.si;
//
//import sge.graphics.Draw;
//import sge.physics.AABB;
//import sge.interfaces.IHasBounds;
//import nme.geom.Point;
//
///**
 //* ...
 //* @author fidgetwidget
 //*/
//
//class Grid<T:(IHasBounds)> extends AABB
//{
	//public var cellWidth:Int;
	//public var cellHeight:Int;
	//
	//public var row_count(default, null):Int;
	//public var col_count(default, null):Int;
	//
	//private var count:Int;
	//
	// indexedItems index is the cell the item belongs to - item can belong to multiple cells (if overlaps)
	//private var _indexedItems:IntHash<List<T>>;
	//private var _items:List<T>;
	//
	//public function new(width:Float, height:Float, rows:Int, cols:Int, xOffset:Float = 0, yOffset:Float = 0) 
	//{
		//super();
		//this.setRect(xOffset, yOffset, width, height);
		//cellWidth = Math.floor(width / cols);
		//cellHeight = Math.floor(height / rows);
		//row_count = rows;
		//col_count = cols;
		//count = rows * cols;
		//_indexedItems = new IntHash<List<T>>();
		//_indexes = new List<Int>();
		//_items = new List<T>();
	//}
	//
	//public override function free() :Void
	//{		
		// TODO: free		
	//}
	//
	// insert the item into the grid, puting it in the correct indexed lists
	// based on its bounds (can be in more than one cell).
	//public function insert( item:T ) :List<Int>
	//{
		//_bounds = item.getBounds();
		//if (!this.intersectsAabb(_bounds)) { throw "items bounds are out of range for this grid."; }
		//
		//_items.add(item);
		//get_indexs( _bounds ); // set _indexes values
		//for (i in _indexes)
		//{
			//if (!_indexedItems.exists(i))
				//_indexedItems.set(i, new List<T>());
			//
			//_list = _indexedItems.get(i);
			//_list.add(item);
		//}
		//return _indexes;
	//}
	//
	//public function remove( item:T ) :Void {
		//_items.remove(item);
	//}
	//
	// get the list of items at the given cell location
	//public function getItems( row:Int, col:Int ) :List<T>
	//{			
		//return _indexedItems.get( get_index(row, col) );
	//}
	//
	// get a list of all items that intersect with a given area
	//public function query( queryArea:AABB ) :List<T>
	//{
		//var _results:List<T> = new List<T>();
		//get_indexs( queryArea );
		//for (i in _indexes)
		//{
			//_list = _indexedItems.get(i);
			//if (_list != null) {
				//for (item in _list)
				//{
					//_results.add(item);
				//}
			//}
		//}
		//return _results;
	//}
	//
	// re-index the items in the grid  *NOTE: you shouldn't be using a grid if this is happening often
	//public function sort() :Void 
	//{
		// clear the lists
		//for (key in _indexedItems.keys())
		//{
			//_list = _indexedItems.get(key);
			//_list.clear();
		//}
		// re-insert all items
		//for (item in _items)
		//{
			//insert( item );
		//}
	//}
	//
	//public function draw_debug( camera ) :Void {
		//var aabb:AABB;
		//Draw.graphics.lineStyle(1, 0xff0000);
		//for (item in _items) {
			//aabb = item.getBounds();
			//Draw.debug_drawAABB(aabb, camera);
		//}
	//}
	//
	//
	//public inline function get_row( y:Float ) :Int { return Math.floor((y - this.y) / cellHeight);  }
	//public inline function get_col( x:Float ) :Int { return Math.floor((x - this.x) / cellWidth);   }
	//
	//
	// ----- helper function: get a list of indexes that interesect with the area ----- //
	//private inline function get_indexs( area:AABB ) :List<Int>
	//{
		//_indexes.clear();
		//var fr:Int = Math.floor(area.minY / cellHeight); // first row
		//var lr:Int = Math.floor(area.maxY / cellHeight); // last row
		//var fc:Int = Math.floor(area.minX / cellWidth);  // first col
		//var lc:Int = Math.floor(area.maxX / cellWidth);  // last col
		//for (r in fr...lr) {
			//for (c in fc...lc)
				//_indexes.add( get_index(r, c) );
		//}
		//return _indexes;
	//}
	// ----- helper function: get the 1D index for the row & col value ----- //
	//private inline function get_index( row:Int, col:Int ) :Int
	//{
		//return cellWidth * row + col;
	//}
	// ----- helper function: get the 1D index for the x,y position ----- //
	//private inline function get_index_at( x:Float, y:Float ) :Int
	//{
		//_r = get_row(y);
		//_c = get_col(x);
		//return get_index( _r, _c );
	//}
	//private var _r:Int;
	//private var _c:Int;
	//
	//private var _list:List<T>;
	//private var _bounds:AABB;
	//private var _indexes:List<Int>;
	//
	//TODO: add pooling for indexItems lists (recycle when empty, and add from pool when inserting first item)...
	//
	//
	//
	//public function iterator() :Iterator<T> 
	//{
		//return _items.iterator();
	//}
//}