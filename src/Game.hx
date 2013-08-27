package ;

import demos.shmupTest.TestScene;
import flash.display.MovieClip;
import flash.display.Graphics;

import sge.core.Engine;
import sge.core.Scene;
import sge.core.SceneManager;

/**
 * ...
 * @author fidgetwidget
 */
class Game extends Engine
{
	
	private var testScene:TestScene;

	public function new() 
	{
		super();		
	}
	
	override public function init(root:MovieClip):Void 
	{
		super.init(root);
		
		testScene = new TestScene();
		addScene(testScene, true);
	}
	
	
	override private function _render() :Void {
		// Clear the Screen
		_graphics.clear();
		_graphics.beginFill(0xFFFFFF);
		_graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
		
		// Draw the active Scene
		_scene = SceneManager.currentScene;
		if (_scene != null)
			_scene.render();
		
	}
	
}