package sge.lib.si;

import haxe.FastList;
import nme.geom.Point;
import sge.physics.AABB;
import sge.interfaces.IHasBounds;
import sge.interfaces.IHasId;
/**
 * ...
 * @author fidgetwidget
 */

class QuadTree<T:(IHasBounds, IHasId)> extends AABB
{
	public var MAXDEPTH:Int = 6;
	public var MAXQUADSIZE:Float = 16;
	
	public var root:QuadTree<T>;
	public var parent:QuadTree<T>;
	public var depth(default, null):Int;
	
	public var nodes:Array<QuadTree<T>>;
	private var nbounds:Array<AABB>;
	
	public var canDevide(get_canDevide, never):Bool;
	public var isEmpty(get_isEmpty, never):Bool;
	
	public var qWidth(get_qw, never):Float;
	public var qHeight(get_qh, never):Float;
	
	public var items:IntHash<T>;
	private var _items:Array<T>;
	
	// these are only part of the root
	public var allItems:IntHash<T>;
	public var itemQuad:IntHash<QuadTree<T>>;
	public var pool:FastList<QuadTree<T>>;
	
	public function new( x:Float, y:Float, width:Float, height:Float, parent:QuadTree<T> = null ) 
	{
		super();
		setRect(x, y, width, height);
		this.parent = parent;
		
		items = new IntHash<T>();
		_items = new Array<T>();
		nodes = new Array<QuadTree<T>>();
		nbounds = new Array<AABB>();
		
		if (parent == null)
		{
			root = this;
			depth = 0;
			
			// Only part of the root
			allItems = new IntHash<T>();
			itemQuad = new IntHash<QuadTree<T>>();
			pool = new FastList<QuadTree<T>>();			
		}
		else
		{
			root = parent.root;
			depth = parent.depth + 1;
		}
		
		nbounds[0] = new AABB().setRect(x, y, hWidth, hHeight);
		nbounds[1] = new AABB().setRect(x + hWidth, y, hWidth, hHeight);
		nbounds[2] = new AABB().setRect(x, y + hHeight, hWidth, hHeight);
		nbounds[3] = new AABB().setRect(x + hWidth, y + hHeight, hWidth, hHeight);
	}
	
	public override function free() :Void
	{
		root.pool.add(this);
		parent = null;
		_center.x = 0;
		_center.y = 0;
		_extents.x = 0;
		_extents.y = 0;
	}
	
	public function update( item:T ) :Void 
	{
		if ( !allItems.exists( item.getId() ) ) { return; }
		
		this.remove( item );
		this.insert( item );
	}
	
	public function query( queryArea:AABB ) :List<T>
	{
		var _results:List<T> = new List<T>();
		
		query_addToResults( queryArea, _results );
		
		for ( i in 0...4 )
		{
			if ( nodes.length < i ) { return _results; }
			
			var node = nodes[i];
			if ( node == null ) { continue; }
			if ( node.isEmpty )
			{
				node.cleanUp();
				node.free();
			}
			
			// this node contains the query area (we don't need to check the other nodes then)
			if ( node.containsAabb( queryArea ) ) {
				node.query_addToResults( queryArea, _results );
				break;
			}
			// the query area contains the node, add and move on
			if ( queryArea.containsAabb(node) ) {
				node.query_addAllToResults( queryArea, _results );
				continue;
			}
			// the query area overlaps the node, 
			if ( node.intersectsAabb( queryArea ) ) {
				node.query_addToResults( queryArea, _results );
			}
		}
		
		return _results;
	}
	// ----- helper function (add the relevent items to the results ----- //
	private function query_addToResults( queryArea:AABB, _results:List<T> ) :Void
	{
		for ( item in items )
		{
			_bounds = item.getBounds();
			if ( queryArea.intersectsAabb(_bounds) )
				_results.add( item );
		}
	}
	// ----- helper function (add all the items to the results ----- //
	private function query_addAllToResults( queryArea:AABB, _results:List<T> ) :Void
	{
		for ( item in items )
		{
			_results.add( item );
		}
	}
	
	public function getSmallestQuadAtPoint( x:Float, y:Float ) :QuadTree<T>
	{
		if (!canDevide) { return this; }
		
		for ( i in 0...4 )
		{			
			if ( !nbounds[i].containsPoint(x, y) ) { continue; }
			else {
				if (nodes.length == 0 || nodes[i] == null) { 
					makeQuad(i);
				}
				return nodes[i].getSmallestQuadAtPoint( x, y );
			}
		}
		return this;
	}
	
	public function getSmallestQuadAtAabb( aabb:AABB, allowIntersections = false ) :QuadTree<T>
	{
		if (depth == 0 && !containsAabb( aabb )) {
			
			if (allowIntersections && intersectsAabb( aabb )) 
				return this;
				
			return null;
		}
		
		if (!canDevide) { 
			return this;		
		}
		
		for ( i in 0...4 )
		{			
			if ( !nbounds[i].containsAabb( aabb ) ) { continue; }
			else {
				if (nodes.length == 0 || nodes[i] == null) { 
					makeQuad(i);
				}
				return nodes[i].getSmallestQuadAtAabb( aabb );
			}
		}
		
		return this;
	}
	
	public function insert( item:T  ) :QuadTree<T> 
	{
		if (depth == 0)
			root.allItems.set( item.getId(), item );
		
		_bounds = item.getBounds();
		if (!this.containsAabb(_bounds)) { return null; } // doesn't fit in the quad tree
		
		// can't devide
		if (!canDevide)
		{
			// if we can't get smaller, then put the item here
			items.set( item.getId(), item );
			_items.push( item );
			root.itemQuad.set( item.getId(), this );
			return this;
		}
		
		// find best fit
		for (i in 0...4)
		{
			if (nbounds[i].containsAabb( _bounds ))
			{
				if (nodes.length < i || nodes[i] == null) 
					makeQuad(i);
					
				var quad:QuadTree<T> = nodes[i].insert(item);
				root.itemQuad.set( item.getId(), quad );
				return quad;
			}
		}
		
		// too big for subdevide
		items.set( item.getId(), item );
		_items.push( item );
		root.itemQuad.set( item.getId(), this );
		return this;		
	}
	
	// remove the given item from the quad tree
	public function remove( item:T ) :Void
	{
		if (depth == 0)
			allItems.remove( item.getId() );
		
		if (itemQuad.exists( item.getId() ) ) 
		{
			itemQuad.get( item.getId() ).items.remove( item.getId() );
			itemQuad.get( item.getId() )._items.remove( item );
		}
	}
	
	public function hasItem( item:T ) :Bool 
	{
		return allItems.exists( item.getId() );
	}
	
	public function getItemsQuad( item:T ) :QuadTree<T> 
	{
		if ( !itemQuad.exists( item.getId() ) )
			return null;
		return itemQuad.get( item.getId() );
	}
	
	
	// ----- helper function ----- //
	private function makeSubBounds() :Void {
		nbounds[0].setRect(x, y, hWidth, hHeight);
		nbounds[1].setRect(x + hWidth, y, hWidth, hHeight);
		nbounds[2].setRect(x, y + hHeight, hWidth, hHeight);
		nbounds[3].setRect(x + hWidth, y + hHeight, hWidth, hHeight);
	}
	
	private function subdevide() :Void {
		
		nodes[0] = makeNode(x, y, hWidth, hHeight, this);
		nodes[1] = makeNode(x + hWidth, y, hWidth, hHeight, this);
		nodes[2] = makeNode(x, y + hHeight, hWidth, hHeight, this);
		nodes[3] = makeNode(x + hWidth, y + hHeight, hWidth, hHeight, this);
	}
	private function makeQuad( i:Int ) :Void {
		
		switch (i) {
			case 0:
				nodes[0] = makeNode(x, y, hWidth, hHeight, this);
			case 1:
				nodes[1] = makeNode(x + hWidth, y, hWidth, hHeight, this);
			case 2:
				nodes[2] = makeNode(x, y + hHeight, hWidth, hHeight, this);
			case 3:
				nodes[3] = makeNode(x + hWidth, y + hHeight, hWidth, hHeight, this);
			default:
				return;
		}
	}
	private function cleanUp() :Void {
		for (i in 0...4) {
			if (nodes.length < i) { return; }
			nodes[i].cleanUp();
			nodes[i].free();
		}
	}
	
	// ----- recylcing helpers ----- //
	private function makeNode( x:Float, y:Float, width:Float, height:Float, parent:QuadTree<T> = null ) :QuadTree<T> 
	{
		if (root != this) { 
			return root.makeNode(x, y, width, height, parent);
		}
		if ( pool.isEmpty() ) {
			return new QuadTree<T>( x, y, width, height, parent );
		}
		_node = pool.pop();
		_node.make( x, y, width, height, parent );
		return _node;	
		
	}
	private function make( x:Float, y:Float, width:Float, height:Float, parent:QuadTree<T> = null ) :Void
	{
		setRect(x, y, width, height);
		this.parent = parent;
		root = parent.root;
		if (canDevide) {
			makeSubBounds();
		}
	}
	
	// depth OR quad size devision rule
	private inline function get_canDevide() :Bool { 
		var sizeCheck = root.MAXQUADSIZE > 0 ? (Math.min(hWidth, hHeight) > root.MAXQUADSIZE) : true;
		var depthCheck = root.MAXDEPTH > 0 ? (depth < root.MAXDEPTH) : true;
		return sizeCheck && depthCheck;
	}
	private function get_isEmpty() :Bool { 
		for (i in items.keys())
		{
			return false;
		}		
		return true;
	}	
	private inline function get_qw() :Float	{ return width * 0.25; }
	private inline function get_qh() :Float { return height * 0.25; }
	
	private var _bounds:AABB;
	private var _node:QuadTree<T>;
	
	
	public function iterator() :Iterator<T> 
	{
		// reset the values
		_ittIndex = 0;
		_ittCurChild = 0;
		_result = null;
		for (child in nodes) {
			
			if (child != null)
				child.iterator();
				
		}
		return this;
	}
	
	public function hasNext() :Bool
	{
		if (_items.length > _ittIndex) 
		{
			return true;
		}
		while (nodes.length > _ittCurChild) {
			// test the current child for an item
			if (nodes[_ittCurChild] != null && nodes[_ittCurChild].hasNext()) { return true; }
			// try the next child
			_ittCurChild++;
		}	
		
		return false;
	}
	
	// Non itterator itterator
	public function next() :T
	{
		// do we have any items in this quad?
		if (_items.length > _ittIndex)
		{
			_result = _items[_ittIndex];
			_ittIndex++;
			return _result;
		}
		
		// do we have any children that have items?
		while (nodes.length > _ittCurChild) {
			// test the current child for an item
			if (nodes[_ittCurChild] != null && nodes[_ittCurChild].hasNext()) 
			{ 
				return nodes[_ittCurChild].next();
			}
			_ittCurChild++;
		}		
		
		// if nothing else worked, we are out of items
		return null;
	}
	private var _ittIndex:Int = 0;
	private var _ittCurChild:Int = 0;
	private var _result:T;
	
	
}