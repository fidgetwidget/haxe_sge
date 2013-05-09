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
	private static var g:Graphics;	
	private static var bmp:Bitmap;
	private static var graphicsData:Vector<IGraphicsData>;
	private static var bitmapData:Array<IBitmapDrawable>;
	
	public static var graphics(get_graphics, null):Graphics;
	
	
	public static function init( graphics ) {
		
		g = graphics;
		bmp = new Bitmap();
		//bmp.bitmapData = new BitmapData(1, 1, true, 0xFFFFFF33);
	}
	
	public static function setBmpSize(width:Int, height:Int) {
		
		//bmp.width = width;
		//bmp.height = height;
	}
	
	public static function batchBmp() :BitmapData {
		// Draw the bitmap drawables to the bitmap data		
		//bmp.bitmapData.fillRect(bmp.bitmapData.rect, 0xFFFFFF); // clear the bitmap data
		for (bd in bitmapData) {
			bmp.bitmapData.draw(bd);
		}
		return bmp.bitmapData;		
	}
	
	public static function batchGraphics() :Graphics {
		// Draw the graphics data to the graphics
		g.clear();
		g.drawGraphicsData(graphicsData);
		return g;
	}
	
	/** Add graphic data to the graphic draw data to be drawn this frame
	 * 
	 * @param	gd				the graphics data to be added to the draw data
	 * NOTE: the Graphics data will be drawn ontop of all bitmap data, and in order of being added
	 * TODO: change the way the drawing works to allow bitmap data to be drawn above some portion (or all) graphics data
	 */
	public static function drawGraphics( gd:IGraphicsData ) :Void {
		
		graphicsData.push(gd);
	}
	
	/** Add a bitmap drawable to the bitmap draw data to be drawn this frame
	 * @param bd 				the bitmap image to be added to the draw data
	 * @param orderIndex		the draw order to place the image in
	 * 						DEFAULT: 0 - draw on top of the rest of the image
	 * 
	 */
	public static function drawBitmap( bd:IBitmapDrawable, orderIndex:Int = 0 ) :Void {
		
		bitmapData.insert(orderIndex, bd);	
	}
	
	/**
	 * Getters & Setters
	 */	
	
	private static function get_graphics() :Graphics { return g; }
	
	
	/**
	 * Debug Drawing Helper Calls
	 */
	
	
	public static function debug_drawAABB( aabb:AABB, camera:Camera = null ) {
		Draw.graphics.drawRect(
		camera != null ? aabb.x - camera.x : aabb.x, 
		camera != null ? aabb.y - camera.y : aabb.y, 
		aabb.width, 
		aabb.height );
	}
	
}