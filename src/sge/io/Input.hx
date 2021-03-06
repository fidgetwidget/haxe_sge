package sge.io;

import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.ui.Mouse;

import openfl.events.JoystickEvent;
import openfl.display.Tilesheet;

/**
 * Concept Taken from Flixel
 * Uses .ui.nme.ui.Keyboard enum instead of strings for value checking
 * @author fidgetwidget
 */

typedef InputState = { 
	var current:Int;
	var last:Int;
}

class Input 
{

	public static function init( stage:Stage ) 
	{
		_keys = new Array();		
		initKeys();		
		_mouse = { current:0, last:0 };
		_mouseCursor = new Point();		
		_stage = stage;
		
		_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
#if (cpp || neko || display)
		_btns = new Array();		
		_lAxis = new Point();
		_rAxis = new Point();
		_hat = new Point();
		initBtns();

		_stage.addEventListener(JoystickEvent.AXIS_MOVE, onAxisMove);
		_stage.addEventListener(JoystickEvent.HAT_MOVE, onHatMove);
		_stage.addEventListener(JoystickEvent.BUTTON_UP, onButtonUp);
		_stage.addEventListener(JoystickEvent.BUTTON_DOWN, onButtonDown);
#end

	}
	
	public static function update() : Void {
		
		// nme.ui.Keyboard
		for ( i in 0..._keys.length ) {
			
			var o = _keys[i];
			if (o == null) continue;
			
			if ( (o.last == -1) 
			  && (o.current == -1 ) ) {
				o.current = 0;
			}			
			else 
			if ( (o.last == 2) 
			  && (o.current == 2) ) {
				o.current = 1;
			}
			
			o.last = o.current;
		}
		
		// Mouse
		if ( (_mouse.last == -1) 
		  && (_mouse.current == -1 ) ) {
			_mouse.current = 0;
		}			
		else 
		if ( (_mouse.last == 2) 
		  && (_mouse.current == 2) ) {
			_mouse.current = 1;
		}
		
		_mouse.last = _mouse.current;
		
		_mouseCursor.x = _stage.mouseX;
		_mouseCursor.y = _stage.mouseY;
		
#if (cpp || neko || display)
		// Joystick
		for ( i in 0..._btns.length ) {
			var o = _btns[i];
			if (o == null) continue;
			
			if ( (o.last == -1) 
			  && (o.current == -1 ) ) {
				o.current = 0;
			}			
			else 
			if ( (o.last == 2) 
			  && (o.current == 2) ) {
				o.current = 1;
			}
			
			o.last = o.current;
		}
#end
	}
	
	public static function reset() : Void {
		
		for ( i in 0..._keys.length ) {
			
			var o = _keys[i];
			if (o == null) continue;
			
			o.current = o.last = 0;
		}
		
		_mouse.current = _mouse.last = 0;
		
#if (cpp || neko || display)
		for ( i in 0..._btns.length ) {
			
			var o = _btns[i];
			if (o == null) continue;
			
			o.current = o.last = 0;
		}
#end
	}
	
	
	/* --- nme.ui.Keyboard --- */
	
	public static function isKeyDown( keyCode:Int ) :Bool {
		return _keys[keyCode].current > 0; // 1 or 2
	}
	public static function isKeyUp( keyCode:Int ) :Bool {
		return _keys[keyCode].current < 1; // 0 or -1
	}
	public static function isKeyPressed( keyCode:Int ) :Bool {
		return _keys[keyCode].current == 2;
	}
	public static function isKeyReleased( keyCode:Int ) :Bool {
		return _keys[keyCode].current == -1;
	}
	
	private static function onKeyDown( e:KeyboardEvent ) :Void {
		
		var keyCode = e.keyCode;
		var o = _keys[keyCode];
		if ( o == null ) return;
		
		if ( o.current > 0 ) {
			o.current = 1; // is down
		}
		else {
			o.current = 2; // just pressed
		}
		
	}
	
	private static function onKeyUp( e:KeyboardEvent ) :Void {
		
		var keyCode = e.keyCode;
		var o = _keys[keyCode];
		if ( o == null ) return;
		
		if ( o.current > 0 ) {
			o.current = -1; // just released
		}
		else {
			o.current = 0; // is up
		}
		
	}
	
	private static function addKey( KeyCode:Int ) :Void {
		
		_keys[KeyCode] = { current:0, last:0 };
		
	}
	
	
	// Add all of the nme.ui.Keyboard values to the map
	private static function initKeys() :Void {
		
		addKey(Keyboard.A); // 65
		addKey(Keyboard.B); // 66
		addKey(Keyboard.C); // 67
		addKey(Keyboard.D); // 68
		addKey(Keyboard.E); // 69
		addKey(Keyboard.F); // 70
		addKey(Keyboard.G); // 71
		addKey(Keyboard.H); // 72
		addKey(Keyboard.I); // 73
		addKey(Keyboard.J); // 74
		addKey(Keyboard.K); // 75
		addKey(Keyboard.L); // 76
		addKey(Keyboard.M); // 77
		addKey(Keyboard.N); // 78
		addKey(Keyboard.O); // 79
		addKey(Keyboard.P); // 80
		addKey(Keyboard.Q); // 81
		addKey(Keyboard.R); // 82
		addKey(Keyboard.S); // 83
		addKey(Keyboard.T); // 84
		addKey(Keyboard.U); // 85
		addKey(Keyboard.V); // 86
		addKey(Keyboard.W); // 87
		addKey(Keyboard.X); // 88
		addKey(Keyboard.Y); // 89
		addKey(Keyboard.Z); // 90
		addKey(Keyboard.BACKSPACE); // 8
		addKey(Keyboard.CAPS_LOCK); // 20		
		addKey(Keyboard.CONTROL); // 17
		addKey(Keyboard.DELETE); // 46
		addKey(Keyboard.DOWN); // 40
		addKey(Keyboard.END); // 35
		addKey(Keyboard.ENTER); // 13		
		addKey(Keyboard.ESCAPE); // 27
		addKey(Keyboard.F1); // 112
		addKey(Keyboard.F2); // 113
		addKey(Keyboard.F3); // 114
		addKey(Keyboard.F4); // 115
		addKey(Keyboard.F5); // 116
		addKey(Keyboard.F6); // 117
		addKey(Keyboard.F7); // 118
		addKey(Keyboard.F8); // 119
		addKey(Keyboard.F9); // 120
		addKey(Keyboard.F10); // 121
		addKey(Keyboard.F11); // 122
		addKey(Keyboard.F12); // 123
		addKey(Keyboard.F13); // 124
		addKey(Keyboard.F14); // 125
		addKey(Keyboard.F15); // 126
		addKey(Keyboard.HOME); // 36
		addKey(Keyboard.INSERT); // 45
		addKey(Keyboard.LEFT); // 37		
		addKey(Keyboard.NUMPAD_0); // 96
		addKey(Keyboard.NUMPAD_1); // 97
		addKey(Keyboard.NUMPAD_2); // 98
		addKey(Keyboard.NUMPAD_3); // 99
		addKey(Keyboard.NUMPAD_4); // 100
		addKey(Keyboard.NUMPAD_5); // 101
		addKey(Keyboard.NUMPAD_6); // 102
		addKey(Keyboard.NUMPAD_7); // 103
		addKey(Keyboard.NUMPAD_8); // 104
		addKey(Keyboard.NUMPAD_9); // 105
		addKey(Keyboard.NUMPAD_ADD); // 107
		addKey(Keyboard.NUMPAD_DECIMAL); // 110
		addKey(Keyboard.NUMPAD_DIVIDE); // 111
		addKey(Keyboard.NUMPAD_ENTER); // 108
		addKey(Keyboard.NUMPAD_MULTIPLY); // 106
		addKey(Keyboard.NUMPAD_SUBTRACT); // 109
		addKey(Keyboard.PAGE_DOWN); // 34
		addKey(Keyboard.PAGE_UP); // 33		
		addKey(Keyboard.RIGHT); // 39		
		addKey(Keyboard.SHIFT); // 16		
		addKey(Keyboard.SPACE); // 32
		addKey(Keyboard.TAB); // 9
		addKey(Keyboard.UP); // 38
		
		// not supported in html5 build (old nme rule... might not be true anymore)
#if !js
		addKey(Keyboard.ALTERNATE); // 18
		addKey(Keyboard.BACKQUOTE); // 192
		addKey(Keyboard.BACKSLASH); // 220
		addKey(Keyboard.COMMA); // 188
		addKey(Keyboard.COMMAND); // 15
		addKey(Keyboard.EQUAL); // 187
		addKey(Keyboard.LEFTBRACKET); // 219
		addKey(Keyboard.MINUS); // 189
		addKey(Keyboard.NUMBER_0); // 48
		addKey(Keyboard.NUMBER_1); // 49
		addKey(Keyboard.NUMBER_2); // 50
		addKey(Keyboard.NUMBER_3); // 51
		addKey(Keyboard.NUMBER_4); // 52
		addKey(Keyboard.NUMBER_5); // 53
		addKey(Keyboard.NUMBER_6); // 54
		addKey(Keyboard.NUMBER_7); // 55
		addKey(Keyboard.NUMBER_8); // 56
		addKey(Keyboard.NUMBER_9); // 57
		addKey(Keyboard.NUMPAD); // 21
		addKey(Keyboard.RIGHTBRACKET); // 221
		addKey(Keyboard.SEMICOLON); // 186
		addKey(Keyboard.PERIOD); // 190
		addKey(Keyboard.QUOTE); // 222
		addKey(Keyboard.SLASH); // 191	
#end
	}
	
	/* --- Mouse --- */
	
	public static var mouseX(get, never):Float;
	public static var mouseY(get, never):Float;
	
	public static function get_mouseX() :Float { return _mouseCursor.x; }
	public static function get_mouseY() :Float { return _mouseCursor.y; }
	
	public static function getMousePoint() :Point { return _mouseCursor; }
	
	public static function isMouseDown( ) :Bool {
		return _mouse.current > 0; // 1 or 2
	}
	public static function isMouseUp( ) :Bool {
		return _mouse.current < 1; // 0 or -1
	}
	public static function isMousePressed( ) :Bool {
		return _mouse.current == 2;
	}
	public static function isMouseReleased( ) :Bool {
		return _mouse.current == -1;
	}
	
	private static function onMouseDown( e:MouseEvent ) :Void {
		
		if ( _mouse.current > 0) {
			_mouse.current = 1; // is down
		} 
		else {
			_mouse.current = 2; // just pressed
		}
		
	}
	
	private static function onMouseUp( e:MouseEvent ) :Void {
		
		if ( _mouse.current > 0) {
			_mouse.current = -1; // just released
		} 
		else {
			_mouse.current = 0; // is up
		}
	}
	
	private static var _total 		: Int = 256;
	private static var _keys 		: Array<InputState>;		
	private static var _mouse 		: InputState;
	private static var _mouseCursor : Point;
	private static var _stage 		: Stage;
	
	
	
#if (cpp || neko || display)
	/* --- Joystick --- */
	
	public static var lAxisX(get, never):Float;
	public static var lAxisY(get, never):Float;
	public static var rAxisX(get, never):Float;
	public static var rAxisY(get, never):Float;
	public static var lTrigger(get, never):Float;
	public static var rTrigger(get, never):Float;
	public static var hatX(get, never):Float;
	public static var hatY(get, never):Float;
	
	public static function get_lAxisX() :Float { return _lAxis.x; }
	public static function get_lAxisY() :Float { return _lAxis.y; }
	public static function get_rAxisX() :Float { return _rAxis.x; }
	public static function get_rAxisY() :Float { return _rAxis.y; }
	public static function get_lTrigger() :Float { return _lTrigger; }
	public static function get_rTrigger() :Float { return _rTrigger; }
	public static function get_hatX() :Float { return _hat.x; }
	public static function get_hatY() :Float { return _hat.y; }
	
	public static function get_leftAxis() :Point { return _lAxis; }
	public static function get_rightAxis() :Point { return _rAxis; }
	public static function get_hatPoint() :Point { return _hat; }
	
	public static function isButtonDown( btnCode:Int ) :Bool {
		return _btns[btnCode].current > 0; // 1 or 2
	}
	public static function isButtonUp( btnCode:Int ) :Bool {
		return _btns[btnCode].current < 1; // 0 or -1
	}
	public static function isButtonPressed( btnCode:Int ) :Bool {
		return _btns[btnCode].current == 2;
	}
	public static function isButtonReleased( btnCode:Int ) :Bool {
		return _btns[btnCode].current == -1;
	}	
	
	private static function onAxisMove( e:JoystickEvent ) :Void {
		_lAxis.x = e.axis[0];
		_lAxis.y = e.axis[1];
		_rAxis.x = e.axis[3];
		_rAxis.y = e.axis[4];
		_lTrigger = e.axis[2] > 0 ? e.axis[2] : 0;
		_rTrigger = e.axis[2] < 0 ? -e.axis[2] : 0;
	}
	private static function onHatMove( e:JoystickEvent ) :Void {
		_hat.x = e.x;
		_hat.y = e.y;
	}
	
	private static function addButton( btnCode:Int ) :Void {
		_btns[btnCode] = { current:0, last:0 };
	}	
	
	private static function onButtonDown( e:JoystickEvent ) :Void {
		var btnCode = e.id;		
		var o = _btns[btnCode];
		if ( o == null ) return;
		
		if ( o.current > 0 ) {
			o.current = 1; // is down
		}
		else {
			o.current = 2; // just pressed
		}
	}
	
	private static function onButtonUp( e:JoystickEvent ) :Void {
		var btnCode = e.id;
		var o = _btns[btnCode];
		if ( o == null ) return;
		
		if ( o.current > 0 ) {
			o.current = -1; // just released
		}
		else {
			o.current = 0; // is up
		}
	}
	
	public static function initBtns() :Void {
		
	}
	
	private static var _btns 		: Array<InputState>;
	private static var _lAxis 		: Point;
	private static var _rAxis 		: Point;
	private static var _lTrigger	: Float;
	private static var _rTrigger	: Float;
	private static var _hat 		: Point;
	
#end
	
}