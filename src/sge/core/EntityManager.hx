package sge.core;

import sge.interfaces.IHasBounds;
import sge.physics.AABB;

/**
 * Basic Type of Entity Manager
 *  
 *  - EntityGrid 
 *  - EntityQuadTree
 * 
 * @author fidgetwidget
 */
class EntityManager implements IHasBounds
{
	
	/*
	 * Properties
	 */
	public var count(get_count, null):Int;
	
	/*
	 * Members
	 */
	private var _idSortedEntities:IntHash<Entity>;
	private var _bounds:AABB;
	
	/**
	 * Constructor
	 */
	public function new() 
	{ 
		_idSortedEntities = new IntHash<Entity>();
	}
	
	/**
	 * Add the given entity to the manager
	 * @param	e - the entity to add
	 */
	public function add( e:Entity ) :Void 
	{ 
		_idSortedEntities.set( e.id, e );
		_addEntity( e );
	}
	private function _addEntity( e:Entity ) :Void { } // extended classes will put their additional add functionality here
	
	/**
	 * Remove the given entity from the manager
	 * @param	e - the entity to remove
	 * @param	?free - whether or not to free the entity upon removal (optional)
	 */
	public function remove( e:Entity, ?free:Bool = false ) :Void 
	{ 
		_idSortedEntities.remove( e.id );
		_removeEntity( e );
		if ( free ) {
			Engine.free( e );
		}
	}
	private function _removeEntity( e:Entity ) :Void { } // extended classes will put their additional remove functionality here
	
	/**
	 * Get an array of the entities in this manager
	 * @param	array - the array to use (optional)
	 * @return
	 */
	public function getAllEntities( array:Array<Entity> = null ) :Array<Entity>
	{
		if (array == null) {
			array = new Array<Entity>();
		}
		
		for ( e in _idSortedEntities ) {
			array.push(e);
		}
		
		return array;
	}
	
	
	/*
	 * Getters & Setters
	 */	
	
	/**
	 * Return the total number of currently active entities in the manager
	 * @return entity count
	 */
	private function get_count() :Int 
	{
		return 0;
	}
	
	/// Iterable<Entity>
	public function iterator():Iterator<Entity>
	{
		return _idSortedEntities.iterator();
	}
	
	/// IHasBounds
	public function getBounds() :AABB 
	{
		return _bounds;
	}
	
}