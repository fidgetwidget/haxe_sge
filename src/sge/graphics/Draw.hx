package sge.graphics;

import nme.display.Bitmap;
import nme.display.GraphicsPathCommand;
import nme.Vector;
import sge.core.Camera;
import sge.core.Engine;
import sge.physics.AABB;

import nme.display.Stage;
import nme.display.Graphics;
import nme.display.BitmapData;
import nme.display.IBitmapDrawable;
import nme.display.IGraphicsData;
import nme.Vector;

/**
 * A Drawing Helper
 * Allows for batching of graphic and bitmap drawing
 * TODO: test this and make sure it all works
 * 
 * @author fidgetwidget
 */

class Draw 
{

	/*
	 * Properties 
	 */
	public static var graphics(get_graphics, null):Graphics;
	
	/*
	 * Members 
	 */
	private static var _graphics:Graphics;	
	private static var _bitmap:Bitmap;
	
	
	public static function init( graphics ) {
		
		_graphics = graphics;
		_bitmap = new Bitmap();
	}
	
	
	/*
	 * Getters & Setters
	 */	
	
	private static function get_graphics() :Graphics { return _graphics; }
	
	
	/*
	 * Debug Drawing Helper Calls
	 */	
	
	public static function debug_drawAABB( aabb:AABB, camera:Camera = null ) {
		if (camera == null) {
			_x = Math.floor(aabb.x);
			_y = Math.floor(aabb.y);
		} else {
			_x = Math.floor(aabb.x - camera.x);
			_y = Math.floor(aabb.y - camera.y);
		}
		_width = Math.floor(aabb.width);
		_height = Math.floor(aabb.height);
		 
		Draw.graphics.drawRect(_x, _y, _width, _height);
	}
	private static var _x:Float;
	private static var _y:Float;
	private static var _width:Float;
	private static var _height:Float;
	
}