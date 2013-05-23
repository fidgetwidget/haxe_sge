package ;

import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

import sge.core.Engine;

/**
 * ...
 * @author fidgetwidget
 */

class Main
{		
	
	public function new() {}
	
	public static function main() {
		
		var root = Lib.current;
		var stage = root.stage;
		stage.frameRate = 61; // set to 61 so that it doesn't wiggle around 59~60

		/// These should maybe be set by the engine, and not in main... but not sure yet how I want to handle that...
		stage.align = nme.display.StageAlign.TOP_LEFT;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		
		// Start the SGE
		// This is using a custom Engine extension (called Game) that has all of the "Games" scenes
		var inst = Engine.instance = new Game(root);		
		
		/// TODO: find a better way to call init once the stage is ready...
		// Hook the SGE to the Added To Stage event
		inst.stageSprite.addEventListener(Event.ADDED_TO_STAGE, function(_) Engine.instance.init() );
		// Push the SGE to the Stage.
		stage.addChild( Engine.instance.stageSprite ); 
	}
	
}
