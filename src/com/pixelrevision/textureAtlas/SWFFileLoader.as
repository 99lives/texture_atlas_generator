package com.pixelrevision.textureAtlas{
	
	import com.pixelrevision.textureAtlas.events.TextureAtlasEvent;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.system.LoaderContext;
	
	import uk.co.ninety9lives.TextureAtlas.Log;
	

	
	public class SWFFileLoader extends EventDispatcher{
		
		private static var _sharedInstance:SWFFileLoader;
		
		private var _fr:FileReference;
		private var _loader:Loader;
		private var _swf:MovieClip;

		
		public var loadedEvent:String;
		
		
		public static function get sharedInstance():SWFFileLoader{
			if(!_sharedInstance) _sharedInstance = new SWFFileLoader();
			return _sharedInstance;
		}
		
		public function SWFFileLoader(){
			if(_sharedInstance){
				throw new Error("SWFFileLoader is a singleton.  Please use sharedInstance.");
			}
			loadedEvent = TextureAtlasEvent.SWF_LOADED;
			_loader = new Loader();

			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, clipLoaded);
		}
		
		public function loadData():void{
			_fr = new FileReference();
			_fr.addEventListener(Event.SELECT, onSelected);
			var arr:Array = [];
			arr.push(new FileFilter("SWF Files", "*.swf"));
			_fr.browse(arr);
		}
		
		private function onSelected(evt:Event):void{
			_fr.addEventListener(Event.COMPLETE, onLoaded);
			_fr.removeEventListener(Event.SELECT, onSelected);
			_fr.load();
		}
		
		private function onLoaded(evt:Event):void{
			_fr.removeEventListener(Event.COMPLETE, onLoaded);
			processData();
		}
		
		public function processData():void{
			var myLoaderContext:LoaderContext = new LoaderContext();
			myLoaderContext.allowLoadBytesCodeExecution = true;
			_loader.loadBytes(_fr.data, myLoaderContext);
			
		
		}
		
		private function clipLoaded(e:Event):void{
			_swf = MovieClip(_loader.content);
			_swf.gotoAndStop(1);
			for(var i:uint=0; i<_swf.numChildren; i++){
				if (_swf.getChildAt(i) is MovieClip) 
					MovieClip(_swf.getChildAt(i)).gotoAndStop(1);
				else 
					Log.msg("NOT A MOVIECLIP "+_fr.name + " " + _swf.getChildAt(i));
			}
			
			this.dispatchEvent(new TextureAtlasEvent(loadedEvent) );
		}
		
		public function setFileReferenceFromFile(file:File):void  {
			_fr = file;
			onSelected(null)		}
		
		public function get swf():MovieClip{
			return _swf;
		}
		public function get loader():Loader{
			return _loader;
		}
		
		public function get fr():FileReference{
			return _fr;
		}
		
	}
}