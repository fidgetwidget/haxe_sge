package etc;

import flash.display.Stage;
import flash.display.Graphics;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import sge.core.Engine;
import sge.core.Scene;
import sge.graphics.Draw;

/**
 * ...
 * @author fidgetwidget
 */
class PauseScreen extends Scene
{
	
	static var POSITION_TOP:String = 'TOP';
	static var POSITION_BOTTOM:String = 'BOTTOM';

	static var SCREEN_WIDTH:Int;
	static var SCREEN_HEIGHT:Int;
	static var HEIGHT:Float;

	
	public var text(never, set):String;
	
	var pauseTxtFld:TextField;
	var _position:String;
	var _isShowing:Bool = false;
	
	public function new( parent:Scene, position:String = 'TOP' ) 
	{
		super(parent);
		id = "PauseScene";
		
		SCREEN_WIDTH = cast(Engine.properties.getValue("_STAGE_WIDTH"), Int);
		SCREEN_HEIGHT = cast(Engine.properties.getValue("_STAGE_HEIGHT"), Int);
		
		pauseTxtFld = new TextField();
		pauseTxtFld.selectable = false;
		pauseTxtFld.width = SCREEN_WIDTH;
		pauseTxtFld.defaultTextFormat = new TextFormat("_sans", 24, 0xEEEEEE, null, null, null, null, null, TextFormatAlign.CENTER);
		pauseTxtFld.text = "Paused";
			
		_position = position;
		set_position();		
		HEIGHT = pauseTxtFld.height + 32;
		
		if (_isShowing) {
			show();
		}
	}

	private function set_position() :Void {
		pauseTxtFld.x = 0;
		if (_position == POSITION_BOTTOM) {
			pauseTxtFld.y = SCREEN_HEIGHT - 16 - pauseTxtFld.height;
		} else 
		if (_position == POSITION_TOP) {
			pauseTxtFld.y = 16;
		}
	}
	
	public function show() :Void
	{
		_isShowing = true;
		Engine.stage.addChildAt(pauseTxtFld, Engine.stage.numChildren);
	}
	
	public function hide() :Void
	{
		_isShowing = false;
		Engine.stage.removeChild( pauseTxtFld );
	}
	
	override public function render():Void 
	{
		if (_isShowing) {		
			Draw.graphics.lineStyle( 0, 0x000000 );
			Draw.graphics.beginFill( 0x000000, 0.5 );
			if (_position == POSITION_BOTTOM) {
				Draw.graphics.drawRect(0, SCREEN_HEIGHT - HEIGHT, SCREEN_WIDTH, HEIGHT);
			} else
			if (_position == POSITION_TOP) {
				Draw.graphics.drawRect(0, 0, SCREEN_WIDTH, HEIGHT);
			}
			Draw.graphics.endFill();
		}
	}
	
	private function set_text( text:String ) :String
	{ 
		pauseTxtFld.text = text; 
		HEIGHT = pauseTxtFld.height + 32; 
		set_position();

		return pauseTxtFld.text; 
	}
	
}