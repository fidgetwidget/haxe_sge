package sge.graphics;

import nme.display.DisplayObject;
import nme.display.Sprite;
import sge.core.Engine;

/**
 * A Managed Sprite Layering System
 * 
 * @author fidgetwidget
 */

class Atlas
{
	
	public static function makeLayer( layer:Int ) :Sprite
	{
		if (atlases == null) { atlases = new IntHash(); }
		
		if (atlases.exists(layer)) { 
			//throw "Atlas for layer " + layer + " already exists."; 
			return getLayer( layer );
		}
		
		var s = new Sprite();
		atlases.set(layer, s);
		Engine.root.addChildAt(s, layer);
		return s;
	}
	
	public static function getLayer( layer:Int ) :Sprite
	{
		if (atlases == null) { return null; }
		return atlases.get( layer );
	}
	
	public static function addToLayer( layer:Int, mc:DisplayObject ) :Void 
	{
		if ( atlases == null || !atlases.exists(layer) ) { 
			throw "Atlas for layer " + layer + " doesn't exists.";  
		}
		atlases.get( layer ).addChild( mc );
	}
	public static function removeFromLayer( layer:Int, mc:DisplayObject ) :Void 
	{
		if ( atlases == null || !atlases.exists(layer) ) { 
			throw "Atlas for layer " + layer + " doesn't exists.";  
		}
		atlases.get( layer ).removeChild( mc );
	}
	
	public static function removeLayer( layer:Int ) :Bool 
	{
		if (!atlases.exists(layer)) { return false; }	
		Engine.root.removeChild( atlases.get( layer ) );
		return atlases.remove( layer );
	}
	
	public static function hideLayer( layer:Int ) :Void 
	{
		if (!atlases.exists(layer)) { return; }
		atlases.get( layer ).visible = false;
	}
	
	public static function showLayer( layer:Int ) :Void 
	{
		if (!atlases.exists(layer)) { return; }
		atlases.get( layer ).visible = true;
	}
	
	public static var atlases:IntHash<Sprite>;
	
}