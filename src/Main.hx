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

		stage.align = nme.display.StageAlign.TOP_LEFT;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		
		// Start the SGE
		var inst = Engine.instance = new Game(root);		
		// Hook the SGE to the Added To Stage event
		inst.stageSprite.addEventListener(Event.ADDED_TO_STAGE, function(_) Engine.instance.init() );
		// Push the SGE to the Stage.
		stage.addChild( Engine.instance.stageSprite );
	}
	
}