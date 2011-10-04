package uk.co.ninety9lives.TextureAtlas
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class Log extends EventDispatcher
	{
		public static var LOGGER_TRACE:String = "LOGGER_TRACE";
		public static var LOGGER_PROGRESS:String = "LOGGER_PROGRESS";
		
		public static function get instance() :Log {
			if (_instance == null) {
				_instance = new Log();
			}	
			return _instance;
			
		}
		private static var _instance:Log;
		public static var lastTrace:String;
		static public function msg(message:String) : void
		{
			trace(message);
			lastTrace=message;
			//instance.dispatchEvent (new Event(Log.LOGGER_TRACE));
		}
		
		public static var lastProgress:Object;
		static public function progress(message:Object) : void
		{
			trace(message);
			lastProgress=message;
			instance.dispatchEvent (new Event(Log.LOGGER_PROGRESS));
		}
	}
}