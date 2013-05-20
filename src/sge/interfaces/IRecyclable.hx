package sge.interfaces;

/**
 * WIP: a way to know if an object is recycleable, and can be pooled for better memory use...
 * @author fidgetwidget
 */

interface IRecyclable 
{

	function free() :Void;
	function get_free() :Bool;
	function set_free( free:Bool ) :Bool;
	
}