package sge.graphics;

import nme.display.BitmapData;
import nme.Assets;

/**
 * ...
 * @author fidgetwidget
 */

class AssetManager 
{

	public static function init() :Void {
		
		_images = new Hash<BitmapData>();
		
	}
	
	public static function saveBitmap( source:Dynamic ) :Bool {
		
		if (_images == null) { init(); }
		
		var name:String = Std.string(source);
		var data:BitmapData = Assets.getBitmapData(source);
		
		if (data != null) {
			_images.set(name, data);
			return true;
		}
		
		return false;
	}	
	
	public static function getBitmap( source:Dynamic ) :BitmapData {
		
		if (_images == null) { return null; }
		
		var name:String = Std.string(source);
		// if it already exists, just return it
		if (_images.exists(name)) {
			return _images.get(name);
		}
		
		// save and return the data result
		var data:BitmapData = Assets.getBitmapData(source);
		if (data != null) {
			_images.set(name, data);
		}
		
		return data;
	}
	
	// Asset hash table
	private static var _images:Hash<BitmapData>;
	
}