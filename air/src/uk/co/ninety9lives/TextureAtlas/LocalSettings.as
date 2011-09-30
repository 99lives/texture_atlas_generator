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
			
			if (sharedObject.data.hasOwnProperty("sourceDirectory_output")) 
				return new File(sharedObject.data.sourceDirectory_output) ;
			else 
				return File.userDirectory;
			
			
		}
		
		public  function get outputDirectory() : File  {
			if (sharedObject.data.hasOwnProperty("outputDirectory_output")) 
				return new File(sharedObject.data.outputDirectory_output)  ;
			else 
				return File.userDirectory;
			
		}
		
		public  function get localizeDirectory() : File  {
			if (sharedObject.data.hasOwnProperty("localizeDirectory_output")) 
				return new File(sharedObject.data.localizeDirectory_output) ;
			else 
				return File.userDirectory;
			
		}
		
		public  function  setValue(id:String, f:File) : void  {
			sharedObject.data[id] = f.nativePath;
			sharedObject.flush();			
			
		}
		

	}
}