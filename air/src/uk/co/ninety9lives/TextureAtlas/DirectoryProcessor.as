package uk.co.ninety9lives.TextureAtlas
{
	import com.btbStudios.air.utils.FileUtils;
	import com.pixelrevision.textureAtlas.SWFFileLoader;
	import com.pixelrevision.textureAtlas.Settings;
	import com.pixelrevision.textureAtlas.events.TextureAtlasEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	public class DirectoryProcessor extends EventDispatcher {
	
		private var _swfLoader:SWFFileLoader;
		private var _textureLayout:TextureLayout;
		private var files:Array
		private var currentFile:File;
	

		
		public function DirectoryProcessor(target:IEventDispatcher=null)
		{
			super(target);
			_swfLoader= SWFFileLoader.sharedInstance;			
			_swfLoader.addEventListener(TextureAtlasEvent.SWF_LOADED, newSWFLoaded);
			
		}
		
		public function processPath() : void {
			var localSettings:LocalSettings = new LocalSettings();

			files = FileUtils.GetAllFilesFromDir(localSettings.sourceDirectory, false);
			processNextFile();
	
			
		}
		
		private function processNextFile() {
			if (files.length > 0) {
				currentFile = files.pop();
				if (currentFile.extension=="swf") 
					_swfLoader.setFileReferenceFromFile(currentFile);
				else
					processNextFile();
			}
			
		
		}
		
		
		private function newSWFLoaded(e:Event):void
		{
			var localSettings:LocalSettings = new LocalSettings();
			var localizer:Localizer = new Localizer();
			
			localizer.discoverLocales(localSettings.localizeDirectory);			
			localizer.findTextFields(_swfLoader.swf);
			localizer.saveLocales(this);
			
			processNextFile();
		}
		
		public function write(locale:String): void  {
			var localSettings:LocalSettings = new LocalSettings();
		
			var basePath:String = localSettings.outputDirectory.nativePath+File.separator;
			
			var c_width: Number = Settings.sharedInstance.canvasWidth;
			var c_height: Number = Settings.sharedInstance.canvasHeight;
			
			_textureLayout = new TextureLayout();
			_textureLayout.processSWF(_swfLoader.swf);
			_textureLayout.saveLocal(currentFile.name, basePath+"hi"+File.separator+locale+File.separator);
			
			Settings.sharedInstance.canvasWidth *=0.5;
			Settings.sharedInstance.canvasHeight *=0.5;			
					
			
			_textureLayout = new TextureLayout();
			_textureLayout.scale=0.5;
			
			_textureLayout.processSWF(_swfLoader.swf);
			_textureLayout.saveLocal(currentFile.name, basePath+"lo"+File.separator+locale+File.separator);			
		
			Settings.sharedInstance.canvasWidth =c_width;
			Settings.sharedInstance.canvasHeight = c_height;
		}

	
	}
}