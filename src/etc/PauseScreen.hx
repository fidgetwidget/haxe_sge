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
	
	static var WIDTH:Int;
	static var HEIGHT:Int;
	
	public var text(never, set):String;
	
	var pauseTxtFld:TextField;
	var _isShowing:Bool = false;
	
	public function new( parent:Scene ) 
	{
		super(parent);
		id = "PauseScene";
		
		WIDTH = cast(Engine.properties.getValue("_STAGE_WIDTH"), Int);
		HEIGHT = cast(Engine.properties.getValue("_STAGE_HEIGHT"), Int);
		
		pauseTxtFld = new TextField();
		pauseTxtFld.selectable = false;
		pauseTxtFld.width = WIDTH;
		pauseTxtFld.defaultTextFormat = new TextFormat("_sans", 24, 0xEEEEEE, null, null, null, null, null, TextFormatAlign.CENTER);
		pauseTxtFld.text = "Paused";		
		pauseTxtFld.x = 0;
		pauseTxtFld.y = HEIGHT * 0.5 - pauseTxtFld.height * 0.5;
		
		if (_isShowing) {
			show();
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
			Draw.graphics.beginFill( 0x000000, 0.6 );
			Draw.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			Draw.graphics.endFill();
		}
	}
	
	private function set_text( text:String ) :String  { return pauseTxtFld.text = text; }
	
}