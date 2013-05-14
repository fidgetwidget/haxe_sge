package sge.core;

/**
 * Quad Tree Entity Manager
 * 
 * Each entity added to the manager is placed in the best fit
 * quad in the tree based on the entities bounding box.
 * Entities can be queried based on a bounding area.
 * 
 * @author fidgetwidget
 */

 //TODO: using physics test as an example, create this entity manager
 
import com.eclecticdesignstudio.motion.easing.Quad;
import haxe.FastList;
import nme.geom.Point;
import sge.physics.AABB;

class QuadNode extends AABB {
	
	/*
	 * Properties
	 */
	public var tree:EntityTree;
	public var parent:QuadNode;	
	public var children:Array<QuadNode>;
	public var depth(default, null):Int;
	
	public var items:IntHash<Entity>;
	public var isEmpty(get_isEmpty, never):Bool;
	public var canDevide(get_canDevide, never):Bool;
	
	/*
	 * Members
	 */
	private var _qWidth:Float;
	private var _qHeight:Float;	
	private var _devided:Bool = false;
	private var _bounds:AABB;
	private var _items:Array<Entity>;
	
	public function new (x:Float, y:Float, width:Float, height:Float, tree:EntityTree, depth:Int = 0, parent:QuadNode = null ) {
		super();
		setRect(x, y, width, height);
		
		this.tree = tree;
		this.depth = depth;
		this.parent = parent;
		
		_qWidth = width * 0.25;
		_qHeight = height * 0.25;
	}
	
	/**
	 * Add an entity to the best fit
	 * @param	e - the entity to add
	 * @return  the best fitting node
	 */
	public function addEntity( e:Entity ) :QuadNode
	{
		if (!canDevide) {
			// If we can't devided, then just add it here
			return _addEntity( e );
			
		} else 
		if (!_devided) {
			// If we aren't devided yet, then devide first
			_subdevide();
		}
		
		// Find the best fit
		_bounds = e.getBounds();
		for (child in children) {
			if (child.containsAabb(_bounds)) {
				return child.addEntity(e);
			}
		}
		
		// We're it.
		return _addEntity( e );
		
	}	
	
	/// Add the entity to this Node
	private function _addEntity( e:Entity ) :QuadNode
	{
		if (items == null) {
			items = new IntHash<Entity>();
			_items = new Array<Entity>();
		}
		items.set(e.id, e);
		_items.push(e);
		
		return this;		
	}
	
	public function removeEntity( e:Entity ) :Void
	{
		items.remove(e.id);
		_items.remove(e);
	}
	
	/**
	 * return all entities in the given query area
	 * @param	queryArea - the AABB to test against
	 * @param	array - the results array to add the entities to
	 * @return  the array with the entities added to it
	 */
	public function getEntities( queryArea:AABB, array:Array<Entity> ) :Array<Entity>
	{
		// add all our items to the results
		for (item in items) {
			array.push(item);
		}
		
		if (!_devided || !canDevide) {
			// we are the last one in this branch
			return array;
		}
		
		// test children
		for (child in children) {
			if (queryArea.containsAabb(child) || queryArea.intersectsAabb(child)) {
				// this child is valid, so run this there too
				child.getEntities( queryArea, array );
			}
		}
		
		// exit
		return array;
	}
	
	/**
	 * Get the smallest node that the given bounds would fit in
	 * @param	aabb - the bounds to test against
	 * @return  the best fitting node
	 */
	public function getSmallestFit( aabb:AABB ) :QuadNode
	{
		// if it doesn't fit the root, then return null
		if (depth == 0 && !containsAabb(aabb)) {
			return null;
		}
		
		if (!canDevide) {
			// we're the bottom, so it must be us
			return this;
		} else 
		if (!_devided) {
			// If we aren't devided yet, then devide first
			_subdevide();
		}
		
		// test children
		for (child in children) {
			if (child.containsAabb(aabb)) {
				// it fits down this branch
				return child.getSmallestFit(aabb);
			}
		}
		
		// we're it.
		return this;
		
	}
	
	/*
	 * Helper functions
	 */
	/// create the children quad nodes
	private function _subdevide() :Void
	{
		if (children == null) {
			children = new Array<QuadNode>();
			children[0] = new QuadNode(x,          y,           hWidth, hHeight, tree, depth + 1, this);
			children[1] = new QuadNode(x + hWidth, y,           hWidth, hHeight, tree, depth + 1, this);
			children[2] = new QuadNode(x + hWidth, y + hHeight, hWidth, hHeight, tree, depth + 1, this);
			children[3] = new QuadNode(x,          y + hHeight, hWidth, hHeight, tree, depth + 1, this);
		}
		
		_devided = true;
	}
	
	/// set the values for this quad node
	private function _make( x:Float, y:Float, width:Float, height:Float, tree:EntityTree, depth:Int, parent:QuadNode = null ) :Void
	{
		setRect(x, y, width, height);
		
		this.tree = tree;
		this.depth = depth;
		this.parent = parent;
		
		_qWidth = width * 0.25;
		_qHeight = height * 0.25;
		
		if (canDevide) {
			_subdevide();
		}
	}
	
	
	/*
	 * Getters
	 */
	private function get_isEmpty() :Bool 
	{		
		if (items == null) return true;
		for (key in items.keys()) {
			
			return false;
		}
		return true;
	}
	
	private function get_canDevide() :Bool { return this.depth < tree.MAX_DEPTH; }
	
	
	/// Iterator    ------------------------------------------------------------------------
	public function iterator() :Iterator<Entity> 
	{
		_itt_index = 0;
		_itt_curChild = 0;
		_itt_result = null;
		
		if (_devided) {
			for (child in children)
			{
				child.iterator();
			}
		}
		
		return this;
	}
	
	public function hasNext() :Bool
	{
		if (_items != null && _items.length > _itt_index) {
			return true;
		} else
		if (children == null) {
			return false;
		}
		
		while (children.length > _itt_curChild) {
			
			if (children[_itt_curChild] != null && children[_itt_curChild].hasNext()) {
				return true; 
			} else {
				_itt_curChild++;
			}			
		}
		
		return false;
		
	}
	
	public function next() :Entity
	{
		// do we have any items in this quad?
		if (_items != null && _items.length > _itt_index)
		{
			_itt_result = _items[_itt_index];
			_itt_index++;
			return _itt_result;
		} else
		if (children == null) {
			return null;
		}
		
		// do we have any children that have items?
		while (children.length > _itt_curChild) {
			// test the current child for an item
			if (children[_itt_curChild] != null && children[_itt_curChild].hasNext()) 
			{ 
				return children[_itt_curChild].next();
			}
			_itt_curChild++;
		}		
		
		// if nothing else worked, we are out of items
		return null;
	}
	
	private var _itt_index:Int = 0;
	private var _itt_curChild:Int = 0;
	private var _itt_result:Entity;
	/// ------------------------------------------------------------------------------------
}

 
class EntityTree extends EntityManager
{
	
	/*
	 * Properties
	 */
	public var MAX_DEPTH:Int;
	public var WIDTH:Int;
	public var HEIGHT:Int;
	public var root:QuadNode;
	
	/*
	 * Members
	 */
	private var _entity_node:IntHash<QuadNode>;
	private var _node:QuadNode;
	private var _aabb:AABB;
	
	/**
	 * Constructor
	 * @param	width - the width of the largest node (a fixed value)
	 * @param	height - the height of the largest node (a fixed value)
	 */
	public function new(width:Int = 1024, height:Int = 1024, max_depth:Int = 6) 
	{
		super();
		
		WIDTH = width;
		HEIGHT = height;
		MAX_DEPTH = max_depth;		

		root = new QuadNode(0, 0, WIDTH, HEIGHT, this);
		_bounds = root;
		
		_entity_node = new IntHash<QuadNode>();
	}
	
	
	// add the entity to the appropriate cells based on its bounds
	private override function _addEntity( e:Entity ) :Void 
	{		
		_aabb = e.getBounds();
		if (!_bounds.containsAabb(_aabb)) {
			throw "Entity's Bounds are out of range of this EntityTree.";
		}
		_node = root.addEntity(e);
		_entity_node.set(e.id, _node);
	} 

	// remove the entity from all the cells its in
	private override function _removeEntity( e:Entity ) :Void 
	{ 
		_node = _entity_node.get(e.id);
		_node.removeEntity(e);
		_entity_node.remove(e.id);
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
		
		root.getEntities( queryArea, array );
		
		return array;
	}
	
	public function getSmallestFit( bounds:AABB ) :QuadNode
	{
		return root.getSmallestFit( bounds );
	}
	
	public function getNode( e:Entity ) :QuadNode
	{
		if ( !_entity_node.exists( e.id ) ) 
			return null;
		return _entity_node.get( e.id );
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
	
	public function intersectsAabb( aabb:AABB ) :Bool
	{
		return _bounds.intersectsAabb(aabb);
	}
	
	
	/*
	 * Helper functions
	 */
	
	
	/*
	 * Getters & Setters
	 */
		
	private override function get_count() :Int 
	{
		return 0;
	}
	
}