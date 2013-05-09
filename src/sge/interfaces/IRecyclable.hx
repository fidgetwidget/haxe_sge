package sge.interfaces;

/**
 * ...
 * @author fidgetwidget
 */

interface IRecyclable 
{

	function free() :Void;
	function isFree() :Bool;
	function use() :Void;
	
}