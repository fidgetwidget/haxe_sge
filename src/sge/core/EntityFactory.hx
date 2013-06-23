package sge.core;

import haxe.ds.IntMap;
import haxe.ds.StringMap;

/**
 * A tool for recycling Entities of any type
 *  NOTE: Right now, Entity types must not have any arguments in their constructor * 
 *  TODO: handle Entity types that have arguments in their constructor * 
 * @author fidgetwidget
 */

class EntityFactory 
{	
	
	/// Members
	private static var _entityId:Int = 0;
	private static var _entities:StringMap<Array<Entity>>;
	private static var _entTypes:IntMap<String>;
	private static var _typeName:String;

	
	// init the entities and entityTypes hash tables
	public static function init() 
	{
		_entities = new StringMap<Array<Entity>>();
		_entTypes = new IntMap<String>();
		_entityId = 0;
	}
		
	/**
	 * Get an entity of the given type
	 */
	public static function getEntity<E:Entity>( type:Class<E>, forceNew:Bool = false ) :E {
		
		_typeName = Type.getClassName(type);
		
		// if the type is new
		if ( _entities.get(_typeName) == null ) {
			_entities.set(_typeName, new Array<Entity>());
		}		
		
		// if there aren't any, then add one.
		if ( _entities.get(_typeName).length == 0 ) {
			var e = Type.createInstance(type, []);
			_entities.get(_typeName).push( e );
		}
		
		return cast _entities.get(_typeName).pop();
	}
	
	/**
	 * Release the given entity and add it to the pool
	 */
	public static function free( e:Entity ) :Void {		
		
		_typeName = Type.getClassName(Type.getClass(e));
		if ( _entities.exists(_typeName) ) {
			e.free();
			_entities.get(_typeName).push(e);
		} else {
			e.free();
		}		
	}	
	
	/**
	 * Get the next entity ID
	 * @return
	 */
	public static function getNextEntityId() :Int {
		return _entityId++;
	}
	
	/**
	 * Get the last used entity ID
	 * @return
	 */
	public static function getPrevEntityId() :Int {
		return _entityId;
	}	
	
		
	
}