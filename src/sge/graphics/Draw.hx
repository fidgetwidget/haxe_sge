package sge.graphics;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.GraphicsPathCommand;
import flash.display.IBitmapDrawable;
import flash.display.IGraphicsData;
import flash.display.Stage;
import sge.math.Motion;

import sge.core.Engine;
import sge.collision.AABB;


/**
 * A Drawing Helper
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
	
	public static function debug_drawVelocity( x:Float, y:Float, motion:Motion, scale:Float = 0.25, camera:Camera = null ) {
		
		if (camera == null) {
			Draw.graphics.moveTo( x, y );
			Draw.graphics.lineTo( x + (motion.vx * scale), y + (motion.vy * scale) );
		} else {
			Draw.graphics.moveTo( x - camera.ix, y - camera.iy );
			Draw.graphics.lineTo( x - camera.ix + (motion.vx * scale), y - camera.iy + (motion.vy * scale) );
		}
		
	}
	
	/// Memory Saving Variables
	private static var _x:Float;
	private static var _y:Float;
	private static var _width:Float;
	private static var _height:Float;
	
}