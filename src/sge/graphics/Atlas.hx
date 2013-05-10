package sge.graphics;

import nme.display.DisplayObjectContainer;
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
	
	/*
	 * Properties & Members
	 */
	public var atlases:IntHash<Sprite>;
	private var atlas_root:DisplayObjectContainer;
	public var layers(get_layers, never):Int;
	
	private var _count:Int = 0;
	
	/*
	 * Initializer
	 */
	public function new() {
		atlases = new IntHash();
		atlas_root = new Sprite();
		Engine.root.addChild(atlas_root);
	}
	
	public function makeLayer( layer:Int ) :Sprite
	{		
		if (atlases.exists(layer)) { 
			//throw "Atlas for layer " + layer + " already exists."; 
			return getLayer( layer );
		}
		
		var s = new Sprite();
		atlases.set(layer, s);
		atlas_root.addChildAt(s, layer);
		_count++;
		return s;
	}
	
	public function getLayer( layer:Int ) :Sprite
	{
		if (atlases == null || !atlases.exists(layer) ) { return null; }
		return atlases.get( layer );
	}
	
	public function removeLayer( layer:Int ) :Bool 
	{
		if (!atlases.exists(layer)) { return false; }	
		atlas_root.removeChild( atlases.get( layer ) );
		// TODO: remove all children from the layer sprite
		return atlases.remove( layer );
	}	
	
	public function addToLayer( layer:Int, mc:DisplayObject ) :Void 
	{
		if ( atlases == null || !atlases.exists(layer) ) { 
			throw "Atlas for layer " + layer + " doesn't exists.";  
		}
		atlases.get( layer ).addChild( mc );
	}
	public function removeFromLayer( layer:Int, mc:DisplayObject ) :Void 
	{
		if ( atlases == null || !atlases.exists(layer) ) { 
			throw "Atlas for layer " + layer + " doesn't exists.";  
		}
		atlases.get( layer ).removeChild( mc );
	}
	
	public function hideAll() :Void {
		atlas_root.visible = false;
	}
	
	public function showAll() :Void {
		atlas_root.visible = true;
		for ( layer in atlases ) {
			layer.visible = true;
		}
	}
	
	public function hideLayer( layer:Int ) :Void 
	{
		if (!atlases.exists(layer)) { return; }
		atlases.get( layer ).visible = false;
	}
	
	public function showLayer( layer:Int ) :Void 
	{
		if (!atlases.exists(layer)) { return; }
		atlases.get( layer ).visible = true;
	}
	
	
	private function get_layers() :Int {
		return _count;
	}
	
	
}