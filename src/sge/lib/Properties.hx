package sge.lib;
import nme.errors.Error;

/**
 * A collection of name value pair properties
 * 
 * @author fidgetwidget
 */
class Properties
{

	private var nameValHash:Hash<Dynamic>;
	
	public function new() 
	{
		nameValHash = new Hash<Dynamic>();		
	}
	
	public function set( properties:Array<NameValuePair> ) :Void {
		for (p in properties) {
			nameValHash.set(p.name, p.value);
		}
	}
	
	public function add( name:String, value:Dynamic ) :Void {
		nameValHash.set(name, value);
	}
	
	public function get( name:String ) :Dynamic {
		if (hasValue(name)) {
			return nameValHash.get(name);
		}
		return null;
	}
	
	public function hasValue( name:String ) :Bool {
		return nameValHash.exists(name);
	}
	
}