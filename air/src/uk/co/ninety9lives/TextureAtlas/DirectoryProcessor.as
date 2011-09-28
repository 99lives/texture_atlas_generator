package uk.co.ninety9lives.TextureAtlas
{
	import com.btbStudios.air.utils.FileUtils;
	import com.kerb.utils.KerbUtils;
	import com.pixelrevision.textureAtlas.SWFFileLoader;
	import com.pixelrevision.textureAtlas.Settings;
	import com.pixelrevision.textureAtlas.events.TextureAtlasEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.system.LoaderContext;
	import flash.text.engine.Kerning;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	

	
	public class DirectoryProcessor extends EventDispatcher {
	
		private var _swfLoader:SWFFileLoader;
		private var _textureLayout:TextureLayout;
		private var files:Array
		private var currentFile:File;			
		private var loader:Loader;		
		private var basePath:String;
		private var jobs:Array;
		private var currentJob:Object;			
		private var localizer:Localizer;
		private var savedCanvasWidth;
		private var savedCanvasHeight;
		
		
		//default scales to output to 
		public var scales:Array = [{name:"hi", scale:1},{name:"med", scale:.5},{name:"low", scale:.25}];

		
		public function DirectoryProcessor(target:IEventDispatcher=null)
		{
			super(target);
					
			_swfLoader= SWFFileLoader.sharedInstance;			
			_swfLoader.addEventListener(TextureAtlasEvent.SWF_LOADED, newSWFLoaded);					
		}
		
		//start point.  read a direcotry of swfs and combine with localized xml
		public function processPath() : void {
			var localSettings:LocalSettings = new LocalSettings();
			basePath = localSettings.outputDirectory.nativePath+File.separator;	
			
			//find all swfs
			files = FileUtils.GetAllFilesFromDir(localSettings.sourceDirectory, false);
			
			//set up localizer
			localizer = new Localizer();			
			localizer.discoverLocales(localSettings.localizeDirectory);					
			
			//begin process
			processNextFile();	
			
		}
		
		//Only process swf files
		private function processNextFile(): void  {
			if (files.length > 0) {
				currentFile = files.pop();
				if (currentFile.extension=="swf") {
					_swfLoader.loadedEvent = TextureAtlasEvent.SWF_LOADED;
					_swfLoader.setFileReferenceFromFile(currentFile);
				}
				else
					processNextFile();
			}			
		}
		

		//A swf has finished loading and is ready to be processed
		private function newSWFLoaded(e:Event):void
		{
			Log.msg("loaded new File :" + currentFile.nativePath);		
			createJobs();
			nextJob();
		}
		
		//a job represents a specific operation on a swf - may localize text fields into a specific locale
		//and/or scale the output.
		private function createJobs() {
			jobs=[];
			for each (var locale:String in localizer.getLocalesListForSwf(_swfLoader.swf)) {				
				for each (var scale:* in scales) {
					var job:Object = {}
					job.locale = locale;
					job.scale = scale;
					jobs.push(job);					
				}				
			}			
		} 
		
		//Determine if the current swf has outstanding processing jobs to complete
		private function nextJob() {
			if (jobs.length == 0) {
				processNextFile();
			}else {
				currentJob = jobs.pop();
				loadSwf();
			}			
		}
		
		///reload a fesh copy of the swf data for each individual job
		//yes non optimal - but a good way of removing weird inconsistancys of flash 
		private function loadSwf() {						
			var myLoaderContext:LoaderContext = new LoaderContext();
			myLoaderContext.allowLoadBytesCodeExecution = true;
			loader= new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, clipLoaded);
			loader.loadBytes(_swfLoader.fr.data, myLoaderContext);				
		}
		
		// per job swf is loaded, perfom job specific operations 
		private function clipLoaded(e:Event):void{
			savedCanvasWidth  = Settings.sharedInstance.canvasWidth;
			savedCanvasHeight =	Settings.sharedInstance.canvasHeight;	
			
			var _swf:MovieClip = MovieClip(loader.content);
			_swf.gotoAndStop(1);
			for(var i:uint=0; i<_swf.numChildren; i++){
				MovieClip(_swf.getChildAt(i)).gotoAndStop(1);
			}
									
			Settings.sharedInstance.canvasWidth  *=currentJob.scale.scale;
			Settings.sharedInstance.canvasHeight *=currentJob.scale.scale;	
			
			_textureLayout = new TextureLayout();
			localizer.localize(currentJob.locale, _swf);
			_textureLayout.addEventListener(Event.COMPLETE, onLayoutComplete);
			_textureLayout.scale=currentJob.scale.scale;
			_textureLayout.processSWF(_swf);			
			
		}
		
		//obtain the output path for the current job
		private function get outputPath() : String {
			var s:String = basePath;
			s += currentJob.scale.name;
			s += File.separator;
			s += currentJob.locale;
			s += File.separator;				
			return  s;
		}

		//callback to let us know the swf has been processed
		//write the local files and reset the canvas size
		public function onLayoutComplete(event:Event): void  {
			Log.msg("writing job :" + currentFile.name + outputPath);
			_textureLayout.saveLocal(currentFile.name, outputPath);
	
			Settings.sharedInstance.canvasWidth  = savedCanvasHeight;
			Settings.sharedInstance.canvasHeight = savedCanvasWidth;
			nextJob();
			
		}
		


	
	}
}