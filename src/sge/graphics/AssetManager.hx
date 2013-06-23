package sge.graphics;

import flash.display.BitmapData;
import haxe.ds.StringMap;
import openfl.Assets;
import openfl.display.Tilesheet;

/**
 * ...
 * @author fidgetwidget
 */

class AssetManager 
{
	
	/*
	 * Members
	 */
	private static var _images:StringMap<BitmapData>;
	private static var _tilesheets:StringMap<Tilesheet>;

	public static function init() :Void {
		
		_images = new StringMap<BitmapData>();
		_tilesheets = new StringMap<Tilesheet>();
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
	
}