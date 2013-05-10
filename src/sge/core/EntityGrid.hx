package sge.core;

import haxe.FastList;
import sge.graphics.Draw;
import sge.physics.AABB;
import sge.interfaces.IHasBounds;
import nme.geom.Point;

/**
 * Spacial Grid Entity Manager
 * 
 * Each entity added to the manager is placed in one or more cells
 * based on the entities bounding box.
 * Entities can be queried based on a bounding area.
 * 
 * @author fidgetwidget
 */

class EntityGrid extends EntityManager
{
	
	/*
	 * Properties
	 */
	public var gridWidth	(default, null):Int;
	public var gridHeight	(default, null):Int;
	public var cellWidth	(default, null):Int;
	public var cellHeight	(default, null):Int;
	public var rowCount		(default, null):Int;
	public var colCount		(default, null):Int;	
	
	/*
	 * Members
	 */
	// indexedItems index is the cell the item belongs to - item can belong to multiple cells (if overlaps)
	private var _cells:IntHash<List<Entity>>; 			// index is the cell (row,col as integer)
	private var _entityCellHash:IntHash<List<Int>>;		// index is the entity id, the list of ints are the cell indexs
	
	/// Memory Savers
	private var _indexes:List<Int>;
	private var _aabb:AABB;
	private var _lists:List<Int>;
	private var _list:List<Entity>;
	
	
	/**
	 * Constructor
	 * @param	width - the width of the grid (a fixed value)
	 * @param	height - the height of the grid (a fixed value)
	 */
	public function new(gridWidth:Int = 1024, gridHeight:Int = 1024, cellWidth:Int = 32, cellHeight:Int = 32) 
	{
		super();
		
		this.gridWidth = gridWidth;
		this.gridHeight = gridHeight;
		this.cellWidth = cellWidth;
		this.cellHeight = cellHeight;
		
		rowCount = Math.floor(gridHeight / cellHeight);
		colCount = Math.floor(gridWidth / cellWidth);
		
		_bounds = new AABB();
		_cells = new IntHash<List<Entity>>();
		_entityCellHash = new IntHash<List<Int>>();
		_indexes = new List<Int>();
		
		_bounds.setRect(0, 0, gridWidth, gridHeight);
	}
	
	public function testAddEntity( e:Entity ) :Bool {
		return _bounds.containsAabb(_aabb);
	}
	
	// add the entity to the appropriate cells based on its bounds
	private override function _addEntity( e:Entity ) :Void 
	{		
		_aabb = e.getBounds();
		if (!_bounds.containsAabb(_aabb)) {
			throw "Entity's Bounds are out of range of this EntityGrid.";
		}
		
		_setIndexs( _aabb );
		if (!_entityCellHash.exists(e.id)) {
			_entityCellHash.set(e.id, new List<Int>());
		} else {
			_lists = _entityCellHash.get(e.id);
			_lists.clear();
		}
		for (i in _indexes)
		{
			// check for first item in that cell
			if (!_cells.exists(i))
				_cells.set(i, new List<Entity>());
			
			_list = _cells.get(i);
			_list.add(e);
			
			_lists = _entityCellHash.get(e.id);
			_lists.add(i);
		}
	} 

	// remove the entity from all the cells its in
	private override function _removeEntity( e:Entity ) :Void 
	{ 
		_lists = _entityCellHash.get(e.id);
		for (i in _lists) {
			_list =  _cells.get(i);
			if (_list != null) {
				_list.remove(e);
			}
		}
		_entityCellHash.remove(e.id);
	}
	
	// Quick and dirty remove it from all cells, add it in again
	public function updateEntityPosition( e:Entity ) :Void 
	{
		_removeEntity(e);
		_addEntity(e);
	}
	
	// return an array of all entities in the given query area
	public function getEntities( queryArea:AABB, array:Array<Entity> = null ) :Array<Entity>
	{
		if (array == null) {
			array = new Array<Entity>();
		}
		_setIndexs( queryArea );
		// check all relevant cells
		for (i in _indexes)
		{
			// check for a list in this cell
			_list = _cells.get(i);
			// if there is a list
			if (_list != null) {
				// add all of it's items
				for (e in _list) { array.push(e); }
			}
		}
		return array;
	}
	
	/*
	 * AABB functions 
	 */
	public function containsAabb( aabb:AABB ) :Bool
	{
		return _bounds.containsAabb(aabb);
	}
	
	public function containsPoint( x:Float, y:Float ) :Bool
	{
		return _bounds.containsPoint(x, y);
	}
	
	
	/*
	 * Helper functions
	 */
	
	/// set the list of indexes (_indexes) to that of the cells which interesect with the given area 
	private inline function _setIndexs( area:AABB ) :Void
	{
		// make sure we empty it first
		_indexes.clear();
		
		var fr:Int = Math.floor(area.minY / cellHeight); // first row
		var lr:Int = Math.floor(area.maxY / cellHeight); // last row
		var fc:Int = Math.floor(area.minX / cellWidth);  // first col
		var lc:Int = Math.floor(area.maxX / cellWidth);  // last col
		for (r in fr...lr) {
			for (c in fc...lc)
				_indexes.add( get_index(r, c) );
		}
	}
	
	///get the 1D index for the row & col value
	private inline function get_index( row:Int, col:Int ) :Int
	{
		return (cellWidth * row) + col;
	}
	
	/// get the 1D index for the x,y position
	private inline function get_indexAt( x:Float, y:Float ) :Int
	{
		var r = get_row(y);
		var c = get_col(x);
		return get_index( r, c );
	}
	
	public inline function get_row( y:Float ) :Int { return Math.floor(y / cellHeight);  }
	public inline function get_col( x:Float ) :Int { return Math.floor(x / cellWidth);   }
	
	
	
	
	//TODO: add pooling for indexItems lists (recycle when empty, and add from pool when inserting first item)...
	
	
	
	/*
	 * Getters & Setters
	 */
		
	private override function get_count() :Int 
	{
		return 0;
	}
		
}