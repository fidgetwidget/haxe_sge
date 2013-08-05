package sge.lib;

import haxe.ds.StringMap;

/**
 * ...
 * @author fidgetwidget
 */
class Properties
{

	private var nameValHash:StringMap<Dynamic>;
	
	public function new() 
	{
		nameValHash = new StringMap<Dynamic>();		
	}
	
	public function add( name:String, value:Dynamic ) :Void {
		nameValHash.set(name, value);
	}
	
	public function getValue( name:String ) :Dynamic {
		if (hasValue(name)) {
			return nameValHash.get(name);
		}
		return null;
	}
	
	public function hasValue( name:String ) :Bool {
		return nameValHash.exists(name);
	}
	
}