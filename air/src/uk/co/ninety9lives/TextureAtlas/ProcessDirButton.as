package uk.co.ninety9lives.TextureAtlas
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import spark.components.Button;
	
	public class ProcessDirButton extends Button
	{
		private var directoryProcessor:DirectoryProcessor;
		public function ProcessDirButton()
		{
			super();
			
			//addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private  function onClick(e:Event) : void {
		
			var file:File = new File();  
			file.addEventListener(Event.SELECT, onSelect);  
			
			file.browseForDirectory("Select a Directory to process");
		}
		
		private function onSelect(e:Event) : void {
			var file:File = e.target as File;	
			
			
		}
	}
}