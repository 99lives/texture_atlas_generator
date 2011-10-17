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
	import flash.utils.ByteArray;
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
		private var savedCanvasWidth:Number;
		private var savedCanvasHeight:Number;
		private var myLoaderContext:LoaderContext
		private var totalFiles:Number;
		private var marmaladeGlobalGroupScripts:MarmaladeGlobalGroupScripts;
		private var marmaladeDerbhScripts:MarmaladeDerbhScripts;

		private var bytes:ByteArray;
		//default scales to output to 
		//public var scales:Array = [{name:"hi", scale:1},{name:"med", scale:.5}];
		public var scales:Array = [{name:"hi", scale:1}];

		
		public function DirectoryProcessor(target:IEventDispatcher=null)
		{
			super(target);
					
			_swfLoader= SWFFileLoader.sharedInstance;			
			_swfLoader.addEventListener(TextureAtlasEvent.SWF_PROCESSED, newSWFLoaded);					
		}
		
		//start point.  read a direcotry of swfs and combine with localized xml
		public function processPath() : void {
			
			myLoaderContext = new LoaderContext();
			myLoaderContext.allowLoadBytesCodeExecution = true;
			
			loader= new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, clipLoaded);
			
			var localSettings:LocalSettings = new LocalSettings();
			basePath = localSettings.outputDirectory.nativePath+File.separator;	
			
			marmaladeGlobalGroupScripts = new MarmaladeGlobalGroupScripts(localSettings.outputDirectory);
			marmaladeDerbhScripts = new MarmaladeDerbhScripts(localSettings.outputDirectory);
			//find all swfs
			files = FileUtils.GetAllFilesFromDir(localSettings.sourceDirectory, false);
			totalFiles = files.length;
			Log.progress({current:0, total:100});
			
			//set up localizer
			localizer = new Localizer();			
			localizer.discoverLocales(localSettings.localizeDirectory);					
			
			//begin process
			processNextFile();	
			
		}
		
		//Only process swf files
		private function processNextFile(): void  {
			Log.progress({current:totalFiles-files.length, total:totalFiles});
			if (files.length > 0) {
				currentFile = files.pop();
				if (currentFile.extension=="swf") {
					_swfLoader.loadedEvent = TextureAtlasEvent.SWF_LOADED;
					_swfLoader.setFileReferenceFromFile(currentFile);
				}
				else
					processNextFile();
			}else {
				postProcess();
			}		
		}
		

		//A swf has finished loading and is ready to be processed
		private function newSWFLoaded(e:Event):void
		{
			Log.msg("loaded new File :" + currentFile.nativePath);	
			//check for too large a size
			if (Settings.sharedInstance.canvasWidth > 99920480) {				
				var localSettings:LocalSettings = new LocalSettings();
				var f:File = new File(localSettings.sourceDirectory.nativePath+"/rejected/"+currentFile.name);
				currentFile.moveTo(f,true);
				processNextFile();
			} else {
				//copy the loaded byte array
				bytes = new ByteArray();
				bytes.writeObject(_swfLoader.fr.data);
				bytes.position=0;
				bytes = bytes.readObject()
				createJobs();
				nextJob();
			}
		}
		
		//a job represents a specific operation on a swf - may localize text fields into a specific locale
		//and/or scale the output.
		private function createJobs():void  {
			jobs=[];
			for each (var locale:String in localizer.getLocalesListForSwf(_swfLoader.swf)) {				
				for each (var scale:* in scales) {
					var job:Object = {}
					job.locale = locale;
					job.scale = scale;
					jobs.push(job);		
					trace("creating job", job.locale, job.scale.name, _swfLoader.swf.name);
				}				
			}			
		} 
		
		//Determine if the current swf has outstanding processing jobs to complete
		private function nextJob(): void {
			if (jobs.length == 0) {
				processNextFile();
			}else {
				currentJob = jobs.pop();				
				if (hasJobAlreadyRun()) {
					trace("skipping job!!!");
					nextJob();					
				}else {
					loadSwf();
				}
			}			
		}
		
		//determine if the current job has already been run (source older then output) 
		private function hasJobAlreadyRun() : Boolean {
			var baseName:String = currentFile.name;
			baseName = baseName.substr(0,baseName.lastIndexOf('.'));
						
			var imgFile:File = new File(outputPath+baseName+".png");
			if (imgFile.exists)
				return (currentFile.creationDate < imgFile.creationDate);
			else 
				return false;
		}
		
		
		var times:Number = 0;
		///reload a fesh copy of the swf data for each individual job
		//yes non optimal - but a good way of removing weird inconsistancys of flash 
		private function loadSwf() : void  {	
			trace("load swf start");
			//if (times++ < 2)
				//loader.loadBytes(_swfLoader.fr.data, myLoaderContext);
			myLoaderContext = new LoaderContext();
			myLoaderContext.allowLoadBytesCodeExecution = true;
			
			loader= new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, clipLoaded);
				loader.loadBytes(bytes, myLoaderContext);
			trace("load swf end");
		}
		
		// per job swf is loaded, perfom job specific operations 
		private function clipLoaded(e:Event):void{
			trace("clipLoaded start");
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
			
			trace("clipLoaded end");
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
			
			var baseName:String = currentFile.name;
			baseName = baseName.substr(0,baseName.lastIndexOf('.'));
			_textureLayout.saveLocal(baseName, outputPath);
	
			Settings.sharedInstance.canvasWidth  = savedCanvasHeight;
			Settings.sharedInstance.canvasHeight = savedCanvasWidth;
			
			marmaladeGlobalGroupScripts.generateFiles(new File(outputPath));
			marmaladeDerbhScripts.generateFiles(new File(outputPath));
			nextJob();
			
		}
		
		//Once all swf inputs have been processed 
		//this stage will prepare glbal level scripts 
		//desinged to smooth processing of the assets into 
		//marmalade
		private function postProcess() : void {
			for each (var item:* in scales) {
				
				marmaladeDerbhScripts.generateXMLderbh(marmaladeDerbhScripts.oDir.resolvePath(item.name+"/xml"))
			}
			marmaladeGlobalGroupScripts.writeIncludeFile();
			
			
		}
	
	}
}