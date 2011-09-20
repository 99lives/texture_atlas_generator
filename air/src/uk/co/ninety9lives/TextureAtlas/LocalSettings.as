package uk.co.ninety9lives.TextureAtlas
{
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	public class LocalSettings
	{
		public var sharedObject:SharedObject;
		
		public function LocalSettings()
		{
			super();
			sharedObject = SharedObject.getLocal("x2");
			
		}
		
		public  function get sourceDirectory() : File  {
			
			if (sharedObject.data.hasOwnProperty("sourceDirectory")) 
				return new File(sharedObject.data.sourceDirectory) ;
			else 
				return File.userDirectory;
			
			
		}
		
		public  function get outputDirectory() : File  {
			if (sharedObject.data.hasOwnProperty("outputDirectory")) 
				return new File(sharedObject.data.outputDirectory)  ;
			else 
				return File.userDirectory;
			
		}
		
		public  function get localizeDirectory() : File  {
			if (sharedObject.data.hasOwnProperty("localizeDirectory")) 
				return new File(sharedObject.data.localizeDirectory) ;
			else 
				return File.userDirectory;
			
		}
		
		public  function  setValue(id:String, f:File) : void  {
			sharedObject.data[id] = f.nativePath;
			sharedObject.flush();			
			
		}
		

	}
}